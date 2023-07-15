---
category: technical
tags: programming csharp openapi
layout: post--technical
title: "Endpoint Versioning (OpenApi 1/3)"
---

What I'd like to address is this post, is some of the ways we can
version our APIs with these tools. Specfically I'll focus on what I would call **'Endpoint Versioning'**.

This is article the first of three blog posts on the subject of OpenApi.
* [Part 1: Endpoint Versioning](http://localhost:4000/technical/2021/09/23/openapi-1-endpoint-versioning.html)
* [Part 2: API Versioning](#) (*Pending*)
* [Part 3: Tips for improving your documentation](#) (*Pending*)

### Table of Contents

- [Initial version](#initial-version)
  - [Tip: 1: Routes should be lower case by convention](#tip-1-routes-should-be-lower-case-by-convention)
  - [Tip 2: Separate your resources into clear 'namespaces'](#tip-2-separate-your-resources-into-clear-namespaces)
- [The first breaking change](#the-first-breaking-change)
  - [How to specify version](#how-to-specify-version)
- [Introducing endpoint versions](#introducing-endpoint-versions)
  - [Model naming and versions](#model-naming-and-versions)
  - [What can we do if the initial endpoint was un-versioned?](#what-can-we-do-if-the-initial-endpoint-was-un-versioned)
- [Final endpoint versioned API](#final-endpoint-versioned-api)
- [Discussion](#discussion)
  - [Pros](#pros)
  - [Cons](#cons)
- [Conclusion](#conclusion)
- [Sources](#sources)
  - [Articles](#articles)
  - [NugetPackages](#nugetpackages)
  - [Code](#code)

### Swagger or OpenApi?

I've been very confused about these terms, so let's recap! 

**OpenApi** is a documentation standard for APIs formerly known as **Swagger**.
So, forget *Swagger*, that's just a cause of confusion. 

**Swashbuckle** is a library that generates 'OpenApi' documents from annotated
code.

**Swagger UI** is a library that generates html from OpenApi documents.

**NSwag** is a library that takes OpenApi documents and generates source code
models and, optionally, clients stubs for calling said endpoints.

## Initial version

Let's say we're doing a nice agile development and that we're building **a
weather forecast app**. We already have other teams waiting for us to publish
the initial version, and so far we've cruised along easy lane and used the
default project generation in DotNet.

Our initial Api looks like below, and right off the bat, there's two thing's
'I''d like to fix for good measure.

```js
GET /WeatherForecast

{
  "date"         : string
  "temperatureC" : number
  "temperatureF" : number
  "summary"      : string
}
```

### Tip: 1: Routes should be lower case by convention

Maybe I'm just old fashioned, but I think routes should be lower case. Let's
fix that ASAP and our documentation will look a little bit more professional.

```csharp
services.Configure<RouteOptions>(options =>
{
  options.LowercaseUrls = true;
});
```

```js
GET /weatherforecast
```

To be even more fancy, we can add a `SlugifyParameterTransformer` class to
automatically convert our routes to slug case. Nice!

```csharp
public class SlugifyParameterTransformer : IOutboundParameterTransformer
{
    public string TransformOutbound(object value)
    {
        // Slugify value
        return value == null
            ? null
            : Regex.Replace(
                value.ToString(),
                "([a-z])([A-Z])",
                "$1-$2").ToLower();
    }
}

services.AddControllers(options =>
{
    options.Conventions.Add(
        new RouteTokenTransformerConvention(
            new SlugifyParameterTransformer()));
});
```

```js
GET weather-forecast
```

### Tip 2: Separate your resources into clear 'namespaces'

No one wants to migrate published resources later on, and since we often end up
hosting both webpages and different APIs at the same root domain, we might as
well avoid the trouble from the get go. 

A typical convention is to start API routes with `api/` to distinquish them from
e.g. `assets/`.

Further more, we might want to add additional weather resources later on, so we
should also refactor our routes to be forecast resources in a weather api. That way we have room for other weather related resources such as an API for looking up historic data.

With these changes our API should be much easier to maintain, since our
resources are now neatly separated in 'namespaces' and can be extended in the
future with minimal fuss.


```js
  GET api/weather/forecast
```

> ### Always start with a versioning scheme <!-- Side Note -->
> 
> My recommendation, and I think this is also a common default, is to start with
> `api/v1`. We'll defer that for a little later to also discuss how to handle
> unversioned resources.
>
>  ```
>  GET api/v1/weather-forecast
>  ```

## The first breaking change

Let's say we have released our initial dummy version because our collaborators
needed to get going. Now we want to make a breaking change as documented in our
changelog. What conventions can we follow to make it easy for our dear
API consumers to keep using our wonderful weather API?

```md
# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2021-08-09
### Added GET /forecast
- Endpoint to fetch the latest 5 day weather forecast data for Aarhus City, Denmark.

## [2.0.0] - 2021-09-09
### Changed GET /forecast
- To fetch forecast data now requires the input <from:datetime>, <to:datetime> 
  specifing the time range. For very good reasons the developers will not share, 
  a default fallback will not be supported, so this is a breaking change.

  ``
  GET api/weather/forecast

  {
    "from": "2017-06-16",
    "to": "2017-07-16"
  }
  ``
```

Since our API is already in use, we could crash the consuming sides' code by
publishing our breaking change out of the blue. On the other hand we'd like to
continue work with the new version as soon as posible. Versioning would be a
good solution here, but how should we implement it?

### How to specify version

There are multiple ways of specifying version from query parameters to a header
value; I like to specify the version in the URL route because that's what I
consider most RESTful, i.e. it's clearly evident for all involved and very readable
by default in both logs, http tools ect.

## Introducing endpoint versions

I define **Endpoint Versioning** as versioning per individual endpoint. This is
a simple and very flexible solution that could work well if we can assume most
endpoints are independent of each other and old versions are quickly deprecated
and removed.

In part 2, I'll compare this approach to API versoining. 

We'll just add a versioned route per endpoint, and keep our current big OpenApi
document with all endpoints for said API. For current unversioned endpoints, we
should also maintain a deprecated, unversioned endpoint to avoid breaking
changes. 

To make it as clear as possible from the routes that each endpoint version is
independent of the others, I would recommend adding the version at the end of
the route.

As a finishing touch, we can write to our API consumers to encourage them to upgrade as soon as possible, unfortunately, this can often take a very long time for them do.


```js
GET api/weather/forecast
GET api/weather/forecast/v1
GET api/weather/forecast/v2
```

> ### Not a well defined term! <!-- Side Note -->
>
> **Endpoint Versioning** is not a well defined term! It is just my personal
> expression, I have not found a formal terminology of the term, but it seems to
> follow intuitively when comparing it to API versioning.

> ### Why not '/api/weather/forecast/2.0.0'? <!-- Side Note -->
>
> Though we use a versioning scheme that includes both major, minor and patch
> version, e.g. 2.0.0 in our change log, our endpoints still only show a 
> version 2. Since API consumers shouldn't worry about breaking changes in minor and
> patch versions, we don't need a higher fidelity in our routes.

### Model naming and versions

I prefer to keep my layers independent, so if I need to change something for a
specific version, or refactor the domain, I don't want to risk cascading changes
throughout the code base accidentally leaking unexpected changes into my API.
For this reason I'd often maintain a seemingly redundant layer of request
response models per version and map my domain to and from these (see Onion
architecture for more).

In this case, we'd have the following models. Notice the version is before the
last name of the type; This is for consistency reasons, if I
also want to version my controllers and use the route naming shorthand `[controller]`
that doesn't work out of the box if my controller name doesn't end in
Controller. This scheme also fit nice and intuitivly to the versioned routs, i.e. `forecast/v1` matches `ForecastV1Request`.

```csharp
ForecastV1Response
ForecastV2Request
ForecastV2Response
```

### What can we do if the initial endpoint was un-versioned?

As mentioned previously, I would recommend including the version in the URL from
the get go. It that wasn't done, and assuming the old routes remain in use, I'd
recommend keeping documentation on both the non-version and a new identical v1
version of the original endpoint.

I think this is the cleanest approach to work with for everybody involved. The
consumers doesn't get confused about which version they are actually using, or
where the appropriate documentation can be found, and the api developers can
also see clearly in the code that version "" and "v1" are the same.

If we had picked a different versioning scheme than URL-versioning, we could
have defaulted the non-versioned calls to e.g. v1, but doing so with url
versioning becomes a bit too complicated to be worth it in my opinion.

## Final endpoint versioned API

Our final endpoint versioned open api documentation ends up looking like this. =)

```csharp
[Obsolete("Please upgrade to v1, this ...in December 2030.")]
[HttpGet("forecast/")]
[HttpGet("forecast/v1")]
public IEnumerable<ForecastV1Response> GetForecastV1()
{
    var from = DateTime.Today;
    var to = DateTime.Today.AddDays(5);
    var forecasts = _forecaster.Get(from, to);
    return ForecastV1Response.From(forecast);
}

[HttpGet("forecast/v2")]
public IEnumerable<ForecastV2Response> GetForecastV2(ForecastV2Request request)
{
    var forecasts = _forecaster.Get(request.From, request.To);
    return ForecastV2Response.From(forecast);
}
```

![Endpoint Versioning](/assets/open-api/endpoint-versioning-v1.png)

## Discussion

<!-- ## API versioning; Can we do better than Endpoint Versioning? -->

<!-- Pros and const of using Endpoint Versioning compared to API Versioning, which
I'll look more into for the next blog post. 

> ### What is API Versioning? <!-- Side Note -->
<!-- >
> Every time we update the change log with a breaking change, we can add an
> entirely new api version and generate a separate open api page to keep our
> documentation clean and cohesive.
>
> You might be concerned that your agile process will suffer from this, since
> you'll be duplicating a lot of endpoints and do a terrible lot of work every
> time you have a tiny breaking change for a single endpoint! Worry not, this
> will in fact be very cheap to do since the standard library offer us a neat
> way to duplicate endpoints per version as you'll see in the following. -->

I'll revisit a comparison after introducing API versioning, but for now, we can
already notice some pros and cons to Endpoint Versioning.

### Pros

* It's easy for consumers when they just need to update the version-bumped
  endpoints as requested in the change log, and if in doubt, they only need to
  make sure not to use a deprecated endpoint.

* If there isn't a new version of an endpoint, then nothing major have changed.
  Consumers doesn't need to update anything, if they are not using any of the
  updated endpoints.

* It's easy for the api developers when they just need to update the version for
  the endpoint they have changed.

* The API documentation might feel a little cluttered if we end up with many
  deprecated versions that can't be removed because of slowly migrating
  consumers, but let's assume we can handle that by adding a html filter to hide
  deprecated versions.

### Cons

* It might be a cause of increased complexity if an API change is NOT endpoint
  independent. That is, if it's not clear from the documentation that a consumer
  must update the use of said endpoints together. 

  Therefore the API maintainers must be careful and specific in writing the
  CHANGELOG.

* For an API consumer that still use the deprecated endpoints, navigating the
  documentation can become tedious.

* You can a mess of models in your documentation that belong to deprecated versions.

* As a minor annoyance; two endpoints versions that depend on each other are not
  neccessarily at the same version, so either you have to accept they are bumped
  to different versions which will be confusing, or you'll have to bump one of
  them several versions to keep them aligned. 
  
  As an example, it could be that you need bump the `GET forecast/v2` with the
  `PUT forecast/v5`.

* A risk of unforseen errors, communication issues and general confusion can
  arrise if by API consumers end up using different combinations of deprecated
  versioned endpoints. You can't really push for much more than 'try to use the
  newest version of all endpoints' and consumers are often not quick to update
  their use of your API.

* Code maintaince and code reuse risk becoming tedious when the API grows. It's
  not neccessarily easy to manage reuse across controllers for different but
  very similar versions, do you go and duplicate entire controllers, refactor
  for some trans-controller reuse, or have your multiple versioned endpoints in
  the same big controller? The most modular and systematic approach might be to
  maintain a controller per endpoint.

* If you want to maintain documentation in your API per endpoint version still
  in use, it can become very tedious to maintain a clear presentable description
  of what general assumptions apply, since your endpoints vary indepdendently of
  each other.

  E.g. imagine having to write "Any monetary amounts will be returned and
  received in minor units (except endpoint /xx/v1, /xx/v2, and yy/v4)".

## Conclusion

I propose Endpoint Versioning is a neat and simple scheme, assuming you're able
to get API consumers to update to the newest version quickly, so you can remove
any deprecated endpoints and keep the API clean and fresh.

If on the other hand, you're working on an API that often has breaking changes
across multiple endpoints and your consumers rarely update their use, you might
want to consider clearly seperating your API by doing API versioning instead.
This becomes even more relevant if you need to maintain documentation for the
different versions! 

## Sources

### Articles
* [Semantic Versioning ~ baeldung](https://www.baeldung.com/cs/semantic-versioning)
* [SlugifyParameterTransformer](https://stackoverflow.com/questions/40334515/automatically-generate-lowercase-dashed-routes-in-asp-net-core)
* [KeepAChangelog](https://keepachangelog.com/en/1.0.0/)
* [Handle fallback version with api-versioning](https://dejanstojanovic.net/aspnet/2020/june/dealing-with-default-api-versions-in-swagger-ui/)

### NugetPackages
* Swashbuckle.AspNetCore

### Code
* [EndpointVersioning](https://github.com/tugend/OpenApiExamples/tree/main/EndpointVersioning)
* [EndpointVersioningTests](https://github.com/tugend/OpenApiExamples/tree/main/EndpointVersioningTests)