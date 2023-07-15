---
category: technical 
tags: programming csharp openapi 
layout: post--technical
title: "Api Versioning (OpenApi 2/3)"
---

This is the second part about HTTP based API versioning in .Net Core. In the
following I'll describe what I consider to be good practice approach to API
versioning.

Let us first assume a fairly complex API with a long lifetime and active
development. In such a case I'd claim it's reasonable to expect a certain
periodicity of breaking changes, and a need to support previous versions for
some time, requiring long-lived maintenance of legacy versions.

I suggest that the best approach to such a situation, is to include a major
version number in the route endpoints, and for each breaking change, to add a
new complete OpenApi document essentially copying all unchanged endpoints from
the previous version. 

Benefits would include a much cleaner API documentation compared to e.g. a
single document that mix all versions in one way or another, as well as enable a
smoother maintenance and support due a reduced risk and incentive for building
implementations that span multiple versions.

The major drawback of the approach would seem to be, that we repeat and must
maintain the same documentation across the multiple versions, but fortunately,
we can do this with minimal effort as we're only required to annotate which
endpoints should exist in which versions!


### Table of Contents

- [Implementation Details](#implementation-details)
- [Special cases](#special-cases)
  - [Transition from a non-versioned API by configuring a fallback version](#transition-from-a-non-versioned-api-by-configuring-a-fallback-version)
  - [Squared complexity, how to support multiple APIs and API-versions?](#squared-complexity-how-to-support-multiple-apis-and-api-versions)
- [Sources](#sources)
  - [Articles et. al.](#articles-et-al)
  - [My Code](#my-code)

## Implementation Details

I will explain how to implement API versioning in the following steps,
by semi-automatically adding a major version number to all annotated routes.
A working implementation is referenced in the [Sources Section](#Sources).

First we need to install the following NuGet Packages;
`Microsoft.AspNetCore.Mvc.Versioning` and
`Microsoft.AspNetCore.Mvc.Versioning.ApiExplorer`. Versioning allow us to extend
our controllers to produce versioned endpoints, and ApiExplorer adds support for
communicating this information to swagger via `IApiVersionDescriptionProvider`.

SubstituteApiVersionInUrl is used to define we want to automatically include the
api version in the url. If you prefer to control versioning via a header
instead, that's also an option.


```csharp
// Startup.cs

services
    .AddApiVersioning()
    .AddVersionedApiExplorer(options => options.SubstituteApiVersionInUrl = true });
```

The hookup with Swagger is straightforward. Set up your swagger generator to
output an OpenApi document per version using the ApiVersionDescriptionProvider,
and configure Swagger UI to combine and display each version document in a
webpage with an drop-down to easily switch version.

```csharp
// ConfigureSwaggerGen.cs

public void Configure(SwaggerGenOptions options)
{
    foreach (var description in _provider.ApiVersionDescriptions)
    {
        options.SwaggerDoc(description.GroupName, ApiDescriptions.CreateInfoForApiVersion(description));
    }
}
```

```csharp
// ConfigureSwaggerUi.cs

public void Configure(SwaggerUIOptions options)
{
    options.RoutePrefix = "swagger";
    
    foreach (var description in _provider.ApiVersionDescriptions)
    {
        var url = $"/swagger/{description.GroupName}/swagger.json";
        var documentName = description.GroupName;
        options.SwaggerEndpoint(url,  documentName);
    }        
}
```

To actually use versions in our controller, we need to update the route
definitions per controller by adding the version in the route, and annotate each
endpoint to clearly mark which version(s) it belongs and voila.

```csharp
// WeatherController.cs

[ApiController]
[Route("api/v{version:apiVersion}/[controller]")]
public class WeatherController : ControllerBase
{

    [ApiVersion("2")]
    [ApiVersion("1")]
    [Obsolete("Please upgrade to v3, this version will be removed in December 2030.")]
    [HttpGet("forecasts")]
    public IEnumerable<ForecastV1Response> GetV1Forecast()
    {
        var from = DateTime.Today;
        var to = DateTime.Today.AddDays(5);
        var forecasts = _forecaster.Get(from, to);
        return ForecastV1Response.From(forecasts);
    }

    [ApiVersion("3")]
    [HttpGet("forecasts")]
    public IEnumerable<ForecastResponse> GetForecast(ForecastRange range)
    {
        var forecasts = _forecaster.Get(range.From, range.To);
        return ForecastResponse.From(forecasts);
    }
}

```

Let's see how the final output looks like. =)

![Version 3 selected](/assets/open-api/api-versioning-v3-doc.png)
*Weather API Version 3*

## Special cases

I experienced a few special cases that I found interesting and dug a bit further into.

### Transition from a non-versioned API by configuring a fallback version

Let us assume your team was a bit quick to publish their first API and they
didn't include a versioning scheme in the first endpoints, how can you make a
soft transition to a versioned API scheme?

Imagine someone outside the company is using the API already, and you can't be
sure how many months(years?) it will take for them to transition to your new and
better way of making endpoints. You could be forced to preserve an explicit
documentation for the legacy 'non-versioned' version until the legacy endpoints
could be safely removed!

We can solve this case at the cost a bit of extra complexity.
This issue also nicely showcases how versatile the OpenApi integration can be by
allowing us to directly change the generated documents on the fly.

The code below will support and document a non-versioned set of endpoints from
the controller that matches the same set of endpoints in version 1. Since
version 1 and the legacy non-versioned endpoints will be identical I've opted to
keep them in the same document for clarity, but one could also add a separate
'Legacy' version instead.

First we add the versioned route to our controller, but keep the non-versioned
route. Then we configure the ApiExplorer options to default to version 1.0 if
not specified. The result is a non-versioned API document in our generated output 
that exactly match the endpoints marked under version 1.0.

We're left with another issue though, since now we have our legacy endpoints
documented in every single api version, which of course isn't what we want.

```csharp
// WeatherController.cs

[ApiController]
[Route("api/v{version:apiVersion}/[controller]")]
[Route("api/[controller]")]  
public class WeatherController : ControllerBase
```

```csharp
// ConfigureApiVersioning.cs

public void Configure(ApiVersioningOptions options)
{
    options.DefaultApiVersion = new ApiVersion(1, 0);
    options.ReportApiVersions = true;
    options.AssumeDefaultVersionWhenUnspecified = true; 
}   
```

We can solve this final issue by adding a pre-processing step to our OpenApi
generation that remove the legacy endpoints from all but the document for
version 1 by adding a custom DocumentFilter implementation.

```csharp
// ConfigureSwaggerGen.cs
public void Configure(SwaggerGenOptions options)
{
    foreach (var description in _provider.ApiVersionDescriptions)
    {
        options.SwaggerDoc(description.GroupName, ApiDescriptions.CreateInfoForApiVersion(description));
    }

    options.DocumentFilter<RemoveDefaultApiVersionRouteDocumentFilter>();
}

// RemoveDefaultApiVersionRouteDocumentFilter.cs
public class RemoveDefaultApiVersionRouteDocumentFilter : IDocumentFilter  
{  
    public void Apply(OpenApiDocument swaggerDoc, DocumentFilterContext context)  
    {  
        // For each API document we want to generate 
        foreach (var apiDescription in context.ApiDescriptions)  
        {  
            var isVersionedApi = apiDescription
                .ParameterDescriptions  
                .All(p => p.Name != "api-version");

            var isDefaultVersion = swaggerDoc.Info.Version.Equals("1");

            // Remove 'required' api version parameter from un-versioned endpoints
            // from swagger (it's not required by the api since we've set AssumeDefaultVersionWhenUnspecified = true)
            swaggerDoc
                .Paths
                .SelectMany(x => x.Value.Operations.Values)
                .ToList()
                .ForEach(operation =>
                    operation.Parameters = operation
                        .Parameters
                        .Where(param => param.Name != "api-version")
                        .ToList());

            // api/v2/weather/forecasts
            if (isVersionedApi)
            {
                continue;
            }
            
            // version 1 api document: api/v1/weather/forecasts and api/weather/forecasts
            if (isDefaultVersion)
            {
                continue;
            }
                
            // Remove un-versioned endpoint from generated documents unless
            // it's the initial version. Note: this affects which routes can be called!
            
            // api/weather/forecasts (for v2+ api documents)
            var route = "/" + apiDescription.RelativePath.TrimEnd('/');
            swaggerDoc.Paths.Remove(route);
        }  
    }  
}  

```

The final output we get now looks like this, in our sample API; two deprecated versions of the same endpoints.

![Sample documentation with fallback version](/assets/open-api/api-versioning-v1-doc-with-removed-api-version-parameter.png)
*Sample documentation with fallback version*

### Squared complexity, how to support multiple APIs and API-versions?

Now, say we want each combination of API and version in a *separate open api
document*. Jikes! For example, let's assume we want to have both a versioned
report- and a weather-API in multiple versions. 

Turns out you can actually man-handle the libraries to do this. I based my
implementation on the discussion and referenced code in this
[thread](https://github.com/dotnet/aspnet-api-versioning/issues/516).
Admittedly, this is clearly going orthogonal to the intended use, on the other
hand I think it's rather nice option for some specific use cases even though
you might typically prefer to have multiple groupings per document instead.

The core idea is to generate group name combinations, in this case version and
controller name and then output an open api document per such combination. 

To plot the course, we can start by adding a custom `IApiDescriptionProvider` that overrides the 'group
name' used to determine which endpoint belongs to which open api document. Since
the group name is used for both display name and the swagger document url (at
least that's the case in my implementation) we have to make sure the value is
url-friendly, hence the '_' part.

```csharp
public class SubgroupDescriptionProvider : IApiDescriptionProvider
{
    ...

    public void OnProvidersExecuted(ApiDescriptionProviderContext context)
    {
        foreach (var result in context.Results)
        {
            var versionName = result
                .GetApiVersion()
                .ToString(_options.Value.GroupNameFormat);

            var controllerName = (result.ActionDescriptor as ControllerActionDescriptor)?
                .ControllerName
                .ToLowerInvariant()
                ?? throw new Exception("TODO");
        
            result.GroupName = $"{controllerName}_{versionName}";
        }
    }
}
```

```csharp
services
    ...
    .AddTransient<IApiDescriptionProvider, SubgroupDescriptionProvider>()
    .AddSwaggerGen();
```

Since the group name is reused as a display name, I've made the following
somewhat disappointing compromise to reformat the value in both `SwaggerGen`,
and `SwaggerUI`. 

Worth noting too, is also the order-by clause in the second code block, which
makes sure the document selector dropdown is nicely ordered.

```csharp
public void Configure(SwaggerGenOptions options)
{
    ...

    var info = new OpenApiInfo
    {
        Title = FormatSwaggerGroupNameForDisplay(endpointDescription.GroupName),
        ...
    };
    ...
}

public void Configure(SwaggerUIOptions options)
{
    var endpointDescriptions = _provider.ApiDescriptionGroups.Items;
    
    // Order alphabetically
    foreach (var item in endpointDescriptions.OrderBy(x => x.GroupName))
    {
        var whereToFindSwaggerJson = $"/swagger/{item.GroupName}/swagger.json"; 
        var documentSelectorDropdownName = FormatSwaggerGroupNameForDisplay(item.GroupName);
        options.SwaggerEndpoint(whereToFindSwaggerJson, documentSelectorDropdownName);
    }
}
```

![Api groups x versions](/assets/open-api/square-api-v1.png)

*Api groups x versions*

And that's really it, surely it can be improved further but I would be
comfortable using something like this in a professional setting. I'm quite happy
to know this is an option for future larger-scale projects.

A neat by-product of the solution is also that it becomes easier to cleanly
generate smaller and distinct OpenApi documents for generating code stubs, i.e.
I can avoid generating any code for other versions or APIs than those I want,
which I imagine could make the code generation setup and output much neater to
work with. =)


## Sources

### Articles et. al.
* [Api Versioning](https://github.com/dotnet/aspnet-api-versioning)
* [How to version your service](https://github.com/dotnet/aspnet-api-versioning/wiki/How-to-Version-Your-Service)
* [Versioning guidelines](https://github.com/Microsoft/api-guidelines/blob/master/Guidelines.md#12-versioning)
* [Discussion on combining APIs and versions in Swagger](https://github.com/dotnet/aspnet-api-versioning/issues/516)
* [Pedro Faustinos POC on Github](https://github.com/pfaustinopt/SwaggerPoC)

### My Code
* [ApiVersioning](https://github.com/tugend/OpenApiExamples/tree/main/ApiVersioning)
* [ApiVersioningTests](https://github.com/tugend/OpenApiExamples/tree/main/ApiVersioningTests)