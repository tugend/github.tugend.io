---
category: "HTTP Services" 
tags: http open-api dotnet
layout: post--technical
title: "Exampled Api (OpenApi 3/3)"
---

Diverging from my previous approach, I'll try to begin each section,
by stating my learning goals followed by a commentary and implementation details.

- [Level 1: The basics](#level-1-the-basics)
  - [Write a simple API for auctioning rice](#write-a-simple-api-for-auctioning-rice)
  - [Document the API with meaningful descriptions](#document-the-api-with-meaningful-descriptions)
  - [Support namespaced model output for OpenAPI](#support-namespaced-model-output-for-openapi)
  - [Public never-used parameters should not yield warnings](#public-never-used-parameters-should-not-yield-warnings)
  - [Should I use records, structs or classes for my API types?](#should-i-use-records-structs-or-classes-for-my-api-types)
- [Level 2: Meaningful example values](#level-2-meaningful-example-values)
- [Level 3 Leverage C# nullable types](#level-3-leverage-c-nullable-types)
- [Level 4 Code Generation from OpenApi documents](#level-4-code-generation-from-openapi-documents)
- [Sources](#sources)
- [My Code](#my-code)

## Level 1: The basics

* ✔️ Write a simple API for auctioning rice.
    * ✔️ Get list of items on auction including item id, minimum bid, batch quantity and batch quality.
    * ✔️ Post an item for auction.
    * ✔️ Put a bid for a selected item.
* ✔️ Document the API with meaningful descriptions.
* ✔️ Support namespaced type-schemas in the OpenApi docs.
* ✔️ Public never-used parameters should not result in warnings.
* ✔️ Should I use records, structs or classes for my API types?

### Write a simple API for auctioning rice

I implemented a basic AspNet Core WebApi and added swagger support (see previous
posts), very much straightforward boilerplate code. 

I've had some issues with big controllers lately, so I opted to experiment a bit
with a 'vertical slice' implementation where each endpoint has it's own class
and namespace together with any specific response and request types. In my
opinion it turned out rather well. I'm very happy with how clearly separate each
endpoint is, while at the same time all related classes are nicely grouped
together. Definitely something to try out in a bigger project at some point. =)

![File Hierarchy](/assets/open-api/part-3-exampled-api/endpoint-file-hiearachy.png "File Hierarchy")  
*File Hierarchy*


### Document the API with meaningful descriptions

OpenAPI/Swagger plays well with the common C# XML comments, so I added these
first. You just have to enable generation of documentation files in the
associated csproj file. I primarily used the `summary`, `remarks` and `example` tags,
which I think mesh nicely in the swagger UI output.

```c#
 <PropertyGroup>
    <GenerateDocumentationFile>true</GenerateDocumentationFile>
    <NoWarn>$(NoWarn);1591</NoWarn>
</PropertyGroup>
```

As a side note, I will recommend using `ActionResult<List<Response>>` rather
than just `ActionResult` for your controller methods. This will produce a
documented return type automatically. 

I could also have added annotations for documenting error code and error types,
but in my opinion, I think documenting the typical http error codes everyone
knows will just be noise in the documentation. Any decent integrator should be
able to handle 404 HTTP status codes without it being explicit in the
documentation.

Regarding the generic AuctionResult<> though, it defaults to 200 OK, so if you
are documenting a method that return a different success status code, you have
to add it explicitly like shown below. You still don't need to state the type
this way though.

```csharp
[ProducesResponseType(StatusCodes.Status201Created)]
[HttpGet("items")]
public ActionResult<List<Response>> GetAuctionedItems(Guid auctionId)
{
    ...
    
    return new CreatedResult(newPath, newItem);
}
```

![Auction API](/assets/open-api/part-3-exampled-api/auction-api-top-view.png "Auction API")  
*Auction API*

![Exampled request](/assets/open-api/part-3-exampled-api/auction-api-exampled-request.png "Exampled request")  
*Exampled request*

### Support namespaced model output for OpenAPI

Since I opted for a namespaced, vertical sliced implementation of my controller,
it fell naturally to also allow duplicate model names, i.e. `Response` and
`Request` for the top most types per endpoint. I really like to preserve the
freedom of naming here, because I often see some weird naming decisions and very
long names to avoid name clashes otherwise. In my opinion this is simple,
nice and easier to work with.

To allow duplicate names, we can use 'pseudo' namespacing in our OpenApi output.
It's just a one-liner, easy peasy. In this case and at my own peril, I even
truncated the namespace a bit to avoid it being longer than necessary.

```csharp
services.AddSwaggerGen(c =>
{
    ...
    // Use limited name spacing, show full name from the third '.'
    // E.g. ExampledApi.Controllers.Auction.GetAuctionedItems.Response -> GetAuctionedItems.Response
    c.CustomSchemaIds(x => x.FullName?.StripUntil('.', 3));
    ...
}
```

![Name-spaced schemas](/assets/open-api/part-3-exampled-api/namespaced-schemas.png "Name-spaced schemas")  
*Name-spaced schemas*

### Public never-used parameters should not yield warnings

For a long time I've been really annoyed by the `MemberCanBePrivate` and
`UnusedAutoPropertyAccessor` warnings which I also didn't want to disable
entirely, and maintaining suppression annotations per class felt ugly. 

I don't want to disable them entirely, because usually they add value,
but on the other hand it's an annoyance, because it's common to have public
settable properties for API types which are never read or instantiated due to
them being just flat serializables for your API.

To my happy surprise, JetBrains have package `JetBrains.Annotations` with a
`PublicAPI` tag that nicely documents your classes as part of a public API and
disable the warnings. Yes! A similar use case and solution apply for the
`[UsedImplicitly]` tag.

```csharp
// Annoying, ambiguous and verbatim suppressions
[SuppressMessage("ReSharper", "MemberCanBePrivate.Global")]
[SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global")]
public class Request
{
    /// <example>250</example>
    public int MinimumBidDkk { get; init; }
```

```csharp
// Clean and self-documenting single annotation
[PublicAPI]
public class Request
{
    /// <example>250</example>
    public int MinimumBidDkk { get; init; }
```

### Should I use records, structs or classes for my API types?

I think this
[answer](https://stackoverflow.com/questions/64816714/when-to-use-record-vs-class-vs-struct)
on StackOverflow was nice and to the point. There's a lot more to it, but I like
the notion of using the record type for data-transfer like purposes, classes to
carry logic and do side effects, and structs for primitives if any.

Basically, **structs** are *pass by value* and should be used to represent
single value primitives less than 16 byte sizes, comparable to int, double,
point ect. 

**Records** are *pass by reference*, by default immutable and a good value type
to carry data without any added behavior logic.

**Classes** should be used if you want to encapsulate mutable behavior and
inheritance.

> #### On Records, immutability and nullability <!-- Side Note -->
>
> I really appreciate immutable types as well as nullable reference types, so I
> tried to use record types and enabled nullable reference types, though I'm a bit
> on the fence whether I would prefer init properties or an explicit constructor,
> the point being how forced a user is to respect the non-nullable reference
> types. 
> 
> For example, a record with a constructor and a `string` field will yield a
> warning if you assign null explicitly to the field. It does not produce a
> warning if you initialize the record without a value for the same field. Yet
> again on the other hand, Init allow for a nice and short syntax. 
> 
> I remain a bit undecided on preference but for now, I've opted let requests be
> records with init properties and responses records with an explicit constructor.


```csharp
var value = new MyRecordType(); // No warning
var value = new MyRecordType() with { Title = null }; // warning due to assignment
var value = new MyRecordTypeWithCtor(null); // warning due to null value
var value = new MyRecordType() { Title = null };
```

```csharp
public record Request
{
    public Guid ItemId { get; init; }
}

public record Response
{
    public Guid ItemId { get; }

    public Response(Guid itemId)
    {
        ItemId = itemId;
    }
}
```

## Level 2: Meaningful example values

* ✔️ Extend the API with meaningful example values.  
* ✔️ Example values should apply in swagger UI when trying an endpoint.  
  
The package(s) from `Matt Frear`, `Swashbuckle.AspNetCore.Filters` gives a lot
more control for generating OpenAPI examples and other fun stuff.

Initially I though this was necessary to control example values in my openAPI
output, but I later discovered that the xml comment `<example>` really does it
all.

If you have an advanced need, for example, if you want to support multiple
different examples, or for some reason want to generate randomized values for
your examples, this could still be a good solution for you. For good measure
I've included a couple of screenshots, but in the use cases I had imagined, this
is overkill, and I will not comment further on this topic here.

![Multiple examples dropdown](/assets/open-api/part-3-exampled-api/multiple-examples.png)  
*Multiple examples dropdown*

## Level 3 Leverage C# nullable types
* ✔️ Leverage C# nullable reference types for documentation
    * ✔️ Nullable value types by default are nullable optional.
    * ✔️ Non-Nullable value types by default are non-nullable and required.
    * ✔️ Nullable reference types by default are nullable optional.
    * ✔️ Non-Nullable reference types by default are non-nullable and required.

* ✔️ Leverage C# nullable reference types for model validation such that 
    * ✔️ Nullable value types by default are nullable optional.
    * ✔️ Non-Nullable value types by default are non-nullable and required.
    * ✔️ Nullable reference types by default are nullable optional.
    * ✔️ Non-Nullable reference types by default are non-nullable and required.

I'm very thrilled about nullable reference types and the support for strict
intellisense/errors when you misbehave regarding null values. I've debugged a
lot of null pointer exceptions, and seen the terrible headaches you risk when
the code does not naturally lend it self to clearly documenting when something
can be null.

Examples include APIs where consumers are never really sure if values can be
null or not, and null checks everywhere in the domain because you're never
really sure internally in the team either. Leveraging the IDE to help you with
static checks for whether or not to handle null cases seems awesome.

Assuming our domain and API implementation on our end is written with nullable
reference types and configured strict wrt. null checks, it follows naturally
that if a field in a response or request model is nullable, it should also be
optional and nullable in the generated OpenApi file. Further more, if it's NOT
nullable, it should be required and non-nullable. 

It turns out we can actually enforce this in such a way that we no longer need
to annotate our public types with `[Required]` tags, and we can even setup the
model validation to follow the same rules! Huzza!

#### Leverage nullable types for documentation

Given a type defined as follows, notice that we have both nullable and
non-nullable reference and value types in the example.

```csharp
[PublicAPI]
public record Request
{
    /// <example>606</example>
    [RegularExpression(".{3}.*", ErrorMessage = "Seller id must be at least three characters.")]
    public string SellerId { get; init; } = null!;

    /// <example>250</example>
    public int? MinimumBidDkk { get; init; }
    
    /// <example>5</example>
    public decimal QuantityKg { get; init; }
    
    /// <example>Johnson Groceries VA</example>
    public string? SellerName { get; init; }
}
```

Off the bat, the generated document defaults to making everything optional, and
all reference types nullable as evident from the following example. Nullable
values types are correctly marked as nullable.

![Request v1](/assets/open-api/part-3-exampled-api/request-v1.png)  
*Request v1*

If we enable `SupportNonNullableReferenceTypes();` in swagger generator, the
nullable flags in the output follow as expected when a reference type is
nullable, i.e. `string?` remain nullable and `string` types are now
not-nullable.
 
```csharp
services.AddSwaggerGen(c =>
{
    c.SupportNonNullableReferenceTypes(); // Sets Nullable flags appropriately.  
})
```

To take it a step further, we can add a schema-filter to the swagger generator
that adds a required attribute to all non-nullable fields and voilá.

```csharp
public class AddSwaggerMakeNonNullableTypesRequiredSchemaFilter : ISchemaFilter
{
    /// <summary>
    /// Make all non-nullable properties required.
    /// </summary>
    public void Apply(OpenApiSchema schema, SchemaFilterContext context)
    {
        if (schema.Properties == null)
        {
            return;
        }
        foreach (var (key, value) in schema.Properties.Where(x => !x.Value.Nullable))
        {
            schema.Required.Add(key);
        }
    }
}
```

```csharp
services.AddSwaggerGen(c =>
{
    c.SupportNonNullableReferenceTypes(); // Sets Nullable flags appropriately.  
    c.SchemaFilter<MakeNonNullableTypesRequiredSchemaFilter>();
})
```

![Request v2](/assets/open-api/part-3-exampled-api/request-v2.png)  
*Request v2*

#### Leverage nullable types for model validation

Of course, we also want to automatically have our model validation error
responses pop up whenever a request does not follow our documentation!

By default a required reference type is handled as expected, we get an error if
it's not included or set to null in the request. Required **value types** on the
other hand are always deserialized to their default value, for example any
missing, non-nullable integer values are set to 0.

If we want to fix this, we get into trouble since it appears unsupported with
the default json serializer from `System.Text.Json` as we can't change it's
behavior before values are bound to the model (and assigned a default value).
The best we can do is to throw a validation error if any value types are set to
their default values - which might be a meaningful workaround, but in my opinion
somewhat unexpected behavior. 

Alternatively we can grab `Microsoft.AspnetCore.Mvc.NewtonstoftJson` and use the
good old Newtonsoft serializer instead. Let's do that!

We also want to set missing members to error, such that any misspelled
properties result in an error which help us avoid issues on breaking changes,
for example when we have renamed a nullable field and someone somewhere updates
to newest version but forgets to update the name.

Finally, we can add a contract resolver that treats non-nullable value types as
required on bind time, giving us a nice model validation error such that our
required value types are validated in the same manner as our reference types! 

It's worth pointing out that even manually marking a non-nullable value types as required
without this added setup, will not produce an error!


```csharp
services
    .AddControllers()
    .AddNewtonsoftJson(c =>
    {
        c.SerializerSettings.MissingMemberHandling = MissingMemberHandling.Error;
        c.SerializerSettings.ContractResolver = new MakeNonNullableValueTypesRequiredResolver();
    });
```

```csharp
public class MakeNonNullableValueTypesRequiredResolver : DefaultContractResolver
{
    protected override JsonObjectContract CreateObjectContract(Type objectType)
    {
        var contract = base.CreateObjectContract(objectType);
        foreach (var contractProperty in contract.Properties)
        {
            // continue if type is nullable
            if (Nullable.GetUnderlyingType(contractProperty.PropertyType!) != null)
            {
                continue;
            }

            // if value type, treat as required
            if (contractProperty.PropertyType!.IsValueType)
            {
                contractProperty.Required = Required.Always;
            }
        }
        return contract;
    }
}
```

## Level 4 Code Generation from OpenApi documents
* ✔️ Generate an easy to use out of the box client stub from the API.
    * ✔️ Without model namespace clashes
    * ✔️ Including transferred nullable types
    * ✔️ Support code generation with selective filtering i.e. only v1, or only for retail api ect.
    * ✔️ Try to apply it in practice on work example json!

I tried out a C\# based, `NSwag` code generation which works more or
less out of the box. Due to my custom fiddling with the 'fake' added namespaces
to the models and my fun with vertically sliced controllers a bit of extra
custom work and maintenance was required, but in my opinion it's easy enough to
work with.

If I should complain about anything, it's the lack of namespacing in OpenApi that
translates to a lack of support in generating types from the OpenApi documents.

My entire setting looks like this. The extra bits of custom work can be found
inside the `CustomNameGenerator` and `CustomTypeGenerator` and needs to match a
similar setup for custom tag names and operation ids on the side generating the
OpenApi input document.

```csharp
var clientSettings = new CSharpClientGeneratorSettings 
{
    OperationNameGenerator = new CustomOperationNameGenerator(), 
    GenerateBaseUrlProperty = false,
    UseBaseUrl = false,
    GeneratePrepareRequestAndProcessResponseAsAsyncMethods = false,
    CSharpGeneratorSettings = 
    {
        Namespace = "ExampledApi",
        GenerateNullableReferenceTypes = true,
        TypeNameGenerator = new CustomTypeNameGenerator()
    }
};

var clientGenerator = new CSharpClientGenerator(document, clientSettings);
```

```csharp
public class CustomOperationNameGenerator : IOperationNameGenerator
{
    public bool SupportsMultipleClients => true;

    public string GetClientName(
        OpenApiDocument document, 
        string path, 
        string httpMethod, 
        OpenApiOperation operation)
    {
        // NOTE: This is only required due to the vertical slicing where each class does not have the classical controller name
        // and is instead all called 'Endpoint'.
        return ConvertToUpperCamelCase(operation.Tags.FirstOrDefault(), false);
    }

    public string GetOperationName(
        OpenApiDocument document, 
        string path, 
        string httpMethod, 
        OpenApiOperation operation)
    {
        // NOTE: this assumes operation id is set to method name when you generate the input OpenApi document,
        // and looks a bit neater rather than the default method+path name
        return operation.OperationId;
    }
}
```

```csharp
public class CustomTypeNameGenerator : ITypeNameGenerator
{
    public string Generate(
        JsonSchema schema, 
        string typeNameHint, 
        IEnumerable<string> reservedTypeNames)
    {
        // I've set this to contain the partial namespace with '.'
        // but '.' is not valid in the generated output.
        return typeNameHint.Replace(".", "");   
    }
}
```

```csharp
// From ExampledApi, the source project for the OpenApi document
public void Configure(SwaggerGenOptions c)
{
    c.CustomOperationIds(api =>
    {
        if (api.ActionDescriptor is ControllerActionDescriptor cad)
        {
            return cad.ActionName;
        }
        throw new Exception("TODO");
    });

    ...

    c.TagActionsBy(api =>
    {
        if (api.ActionDescriptor is ControllerActionDescriptor cad)
            return new[]
            {
                cad.EndpointMetadata
                    .Where(x => x is DisplayNameAttribute)
                    .Cast<DisplayNameAttribute>()
                    .LastOrDefault()?
                    .DisplayName
                    ?? cad.ControllerName
            };
        
        throw new Exception("TODO");
    });
    ...
}
```

As proof the generation works as expected I refer to my unit tests.

```csharp
[Fact]
public async void Generated_Client_Can_Call_Api()
{
    // Remember
    var client = new AuctionClient(_client);
    
    var result = await client.PostItemForAuctionAsync(Guid.NewGuid(), new PostNewItemForAuctionRequest
    {
        QuantityKg = 1,
        RiceQuality = CommonRiceQuality.Bronze,
        SellerId = "seller-id:2001",
        SellerName = "Mr. Foo Trading",
        MinimumBidDkk = 155
    });
    
    Assert.Equal("seller-id:2001", result.SellerId);
    Assert.Equal("Mr. Foo Trading", result.SellerName);
}

[Fact]
public async void GetAuctionedItems_Given_Unknown_Auction()
{
    // Remember
    var client = new AuctionClient(_client);

    var error = await Assert.ThrowsAsync<ApiException>(() => client.GetAuctionedItemsAsync(Guid.NewGuid()));

    Assert.Equal(Status404NotFound, error.StatusCode);
    Assert.Equal("Unknown auction id", DeserializeObject<Error>(error.Response).Message);
}
```

## Sources

* [ActionResult\<T\>](https://docs.microsoft.com/en-us/aspnet/core/web-api/action-return-types?view=aspnetcore-6.0)
* [Enums as strings](https://stackoverflow.com/questions/36452468/swagger-ui-web-api-documentation-present-enums-as-strings)
* [Swashbuckle and ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/tutorials/getting-started-with-swashbuckle?view=aspnetcore-6.0&tabs=visual-studio)
* [Recommended XML tags for C# documentation comments](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/recommended-tags)
* [Name-spacing for Swagger models](https://stackoverflow.com/questions/56475384/swagger-different-classes-in-different-namespaces-with-same-name-dont-work)
* [Custom SwaggerIgnoreFilter](https://newbedev.com/how-to-configure-swashbuckle-to-ignore-property-on-model)
* [Example Requests with SwashBuckle](https://mattfrear.com/2016/01/25/generating-swagger-example-requests-with-swashbuckle/)
* [Example Responses with SwashBuckle](https://mattfrear.com/2015/04/21/generating-swagger-example-responses-with-swashbuckle/)
* [Swashbuckle.Examples](https://github.com/mattfrear/Swashbuckle.Examples)
* [PublicAPI+UsedImplicitly](https://youtrack.jetbrains.com/issue/RIDER-11836)
* [record vs class vs struct](https://stackoverflow.com/questions/64816714/when-to-use-record-vs-class-vs-struct)
* [Configure Non-nullable types as required 1](https://github.com/domaindrivendev/Swashbuckle.AspNetCore/issues/2036)
* [Configure non-nullable types as required 2](https://newbedev.com/asp-net-core-require-non-nullable-types)
* [NSwag ModelNamespaces](https://stackoverflow.com/questions/45241177/nswag-namespace-in-model-names)

## My Code

* [ExampledApi](https://github.com/tugend/OpenApiExamples/tree/main/ExampledApi)
* [ExampledApiTests](https://github.com/tugend/OpenApiExamples/tree/main/ExampledApiTests)
* [NSwag Code Generation](https://github.com/tugend/OpenApiExamples/tree/main/ClientStubGenerator)
* [Code Generation Tests](https://github.com/tugend/OpenApiExamples/tree/main/ClientStubGeneratorTests)
