---
category: technical 
tags: programming C# OpenApi 
layout: post--technical
title: "Api Versioning (OpenApi 3/3)"
---

Diverging from my previous approach, I'll try to start this post,
by stating which learning goals I had, followed by a commentary on
how I reached the given goals.

## Level 1: The basics

* ✔️ Write a simple API for auctioning rice.
    * ✔️ Get list of items on auction including item id, minimum bid, batch quantity and batch quality.
    * ✔️ Post an item up for auction.
    * ✔️ Put a bid for a selected item.
* ✔️ Document the API with meaningful descriptions.
* ✔️ Support namespaced models for OpenAPI
* ✔️ Public never-used parameters should not result in warnings or require disabling-warning annotations.
* ✔️ Should I use records, structs or classes for my API types?

### Write a simple API for auctioning rice

I implemented a basic AspNet Core WebApi, added swagger support (see previous
posts), everything pretty boilerplate. 

I've had some issues with big controllers lately, so I opted to experiment a bit with a 'vertical slice' implementation where each endpoint has it's own class and namespace together with any specific response and request types. In my opinion it turned out rather well, I'm very happy with how clearly separate each endpoint is, while at the same time all related classes are nicely grouped together. Definitely something to try out in a bigger project at some point. =)

![File Hierarchy](/assets/open-api/part-3-exampled-api/endpoint-file-hiearachy.png "File Hierarchy")  
*File Hierarchy*


I really like immutable types, and nullable reference types so I tried to use record types and enabled nullable reference types, though I'm a bit on the fence whether I would prefer init properties or an explicit constructor, the point being how forced a user is to respect non-nullable reference types. 

For example, a record with a constructor and a `string` field will yield a warning if you assign null explicitly to the field but does not produce a warning if you initialize the record without a value for the given field, yet again on the other hand it's a nice and short syntax. I remain a bit undecided on preference but for now I've opted let requests be records without init properties and responses records with an explicit constructor. 

```csharp
var value = new MyRecordType(); // No warning
var value = new MyRecordType() with { Title = null }; // warning due to assignment
var value = new MyRecordTypeWithCtor(null); // warning due to null value
var value = new MyRecordType() { Title = null };
```

### Document the API with meaningful descriptions

OpenAPI/Swagger plays well with the common C# XML comments, so I added these first.
Remember to enable generation of documentation files in the associated csproj file.
I primarily used the summary, remarks and example tags, which I find mesh nicely in the swagger UI output.

```c#
 <PropertyGroup>
    <GenerateDocumentationFile>true</GenerateDocumentationFile>
    <NoWarn>$(NoWarn);1591</NoWarn>
</PropertyGroup>
```

As a side note, I will recommend using `ActionResult<List<Response>>` rather than just `ActionResult` for your controller methods, since the return type will automatically be included in the swagger. Personally, I think adding boilerplate to document the typical http error codes everyone knows is just noise in the documentation so I skipped that on purpose. Any decent integrator should be able to handle 404 HTTP status codes without it being explicit in the documentation. Regarding the generic AuctionResult<> though, it defaults to 200 OK, so if you are documenting a method that return a different success status code, you have to add it explicitly like so, though you still don't need to explicitly state the type;

```csharp
[ProducesResponseType(StatusCodes.Status201Created)]
[HttpGet("items")]
public ActionResult<List<Response>> GetAuctionedItems(Guid auctionId)
{
    ...
    
    return new CreatedResult(newPath, newItem);
}
```

The resulting API looks like this
![Auction API](/assets/open-api/part-3-exampled-api/auction-api-top-view.png "Auction API")  
*Auction API*

![Exampled request](/assets/open-api/part-3-exampled-api/auction-api-exampled-request.png "Exampled request")  
*Exampled request*

### Support namespaced models for OpenAPI

Since I opted for a namespaced vertical sliced implementation of my controller,
it fell naturally to also allow duplicate model names, i.e. `Response` and
`Request` for the top most types per endpoint. I really like to preserve the
freedom of naming here, because I often see some weird naming decisions and very
loooong names otherwise, which otherwise becomes necessary to avoid name
clashes. In my opinion this is simple, nice and easier to work with.

It requires us to use namespaces in our OpenApi output too. It's just a
one-liner, easy peasy. In this case, I even truncated the namespace a bit to
avoid it being longer than necessary.

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

### Public never-used parameters should not result in warnings or require disabling-warning annotations

For a long time I've been really annoyed by some warnings I also didn't want to disable entirely,
and maintaining suppression annotations per class was also ugly. To my happy surprise, JetBrains have a package `JetBrains.Annotations` package with a `PublicAPI` tag that nicely documents the classes and part of a public API and disable the warnings in exactly the right manner. Yes!

The cause of the issue is that it's common to create public settable properties
for API types and then intellisense will think that you don't use those properties.

```csharp
[SuppressMessage("ReSharper", "MemberCanBePrivate.Global")]
[SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global")]
public class Request
{
    /// <example>250</example>
    public int MinimumBidDkk { get; init; }
```

```csharp
[PublicAPI]
public class Request
{
    /// <example>250</example>
    public int MinimumBidDkk { get; init; }
```

## Should I use records, structs or classes for my API types?

I think this
[answer|https://stackoverflow.com/questions/64816714/when-to-use-record-vs-class-vs-struct]
on StackOverflow was nice and to the point. There's a lot more to it, but I like the notion of using the record type for data-transfer like purposes, classes to carry logic and do side effects, and structs for primitives if any.

Basically, **structs** are *pass by value* and should be used to represent single
value primitives less than 16 byte sizes, comparable to int, double, point ect. 

**Records** are *pass by reference*, by default immutable and a good value type to
carry data without any added behavior logic.

**Classes** should be used if you want to encapsulate mutable behavior and
inheritance.


---

### Level 2: Advanced generation example values

* ✔️ Extend the API with meaningful example values.
* ✔️ Example values should apply in swagger UI when trying an endpoint.

The packages from `Matt Frear`, `Swashbuckle.AspNetCore.Filters` and `Swashbuckle.AspNetCore.Filters.Abstractions` gives a lot more control for generating OpenAPI examples and other fun stuff.

Initially I though this was necessary to control example values in my openAPI output,
but I later discovered that the xml comment `<example>` really does it all.

If you have an advanced need, for example if you want to support multiple different examples,
or for some reason want to generate randomized values for your examples, this could still be a good solution for you. For good measure I've included a couple of screenshots, but in the use cases I had imagined, this is overkill, and thus I will not comment further on this topic here.

### Level 3
* ✔️ Leverage C# nullable reference types for documentation
    * ✔️ Nullable value types by default are nullable optional.
    * ✔️ 'Non-Nullable' value types by default are non-nullable and required.
    * ✔️ Nullable reference types by default are nullable optional.
    * ✔️ 'Non-Nullable' reference types by default are non-nullable and required.

* ✔️ Leverage C# nullable reference types for model validation such that 
    * ✔️ Nullable value types by default are nullable optional.
    * ✔️ 'Non-Nullable' value types by default are non-nullable and required.
    * ✔️ Nullable reference types by default are nullable optional.
    * ✔️ 'Non-Nullable' reference types by default are non-nullable and required.

I'm very thrilled about nullable reference types and the support for strict intellisense/errors when you misbehave regarding null values. I've debugged a lot of null pointer exceptions, and seen the terrible headaches you risk when the code does not naturally lend it self to clearly documenting when something can be null.

Examples include APIs where consumers are never really sure if a values can be null or not, and complex domain logic with null checks everywhere because you're never really sure. Leveraging the IDE to help you with static checks for whether or not a null guard is awesome.

Assuming our domain and API implementation on our end is with nullable reference types and configured strict wrt. null checks, it follows naturally that if a field in a response or request model is nullable, it should also be optional and nullable in the generated OpenApi file. Further more, if it's NOT nullable, it should be required and non-nullable. 

It turns out we can actually enforce this in such a way that we no longer need to annotate our public types with `[Required]` tags, and we can even setup the model validation to follow the same rules! Huzza!

#### Leverage nullable types for documentation

Given a type defined as follows, notice that we have both nullable and non-nullable reference and value types in the example.

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

Off the bat, the generated document defaults to making everything optional, and all reference types nullable as evident from the following example. Nullable values types are correctly marked as nullable.

![Request v1](/assets/open-api/part-3-exampled-api/request-v1.png)  
*Request v1*

If we enable `SupportNonNullableReferenceTypes();` in swagger gen, the nullable flags in the output follow as expected when a reference type is nullable, i.e. `string?` remain nullable and `string` types are now not-nullable.
 
```csharp
services.AddSwaggerGen(c =>
{
    c.SupportNonNullableReferenceTypes(); // Sets Nullable flags appropriately.  
})
```

To take it a step further, we can add a schema-filter to the swagger generator that adds a required attribute to all non-nullable fields and voilá.

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

Of course, we also want to automatically have our BadRequest responses pop up when ever a request does not follow our documentation!

By default a required reference type is handled as expected, we get an error if it's not included or set to null in the request. Required value types on the other hand are always deserialized to their default value, for example any missing, required, non-nullable integer values are set to 0.

If we want to fix this, we get into trouble though, since it appears impossible with the default json serializer from `System.Text.Json` since we can't change it's behavior before values are assigned to the model. The best we can do then is to throw an validation error if any value types are set to their default values - which might be a meaningful workaround, but in my opinion somewhat unexpected behavior. 

Alternatively we can grab `Microsoft.AspnetCore.Mvc.NewtonstoftJson` and use the good old Newtonsoft serializer instead. 

Now we want to set missing members to error, such that any misspelled properties result in an error which help us avoid issues on breaking changes for example when we have renamed a nullable field.

Finally, we can add a contract resolver that treats non-nullable value types as required on bind time, giving us a nice model validation error such that our required value types are validated in the same manner as our reference types! As an interesting side-note, even marking a non-nullable value types as required will still not give us an error in a default setup.


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

TODO: cleanup current code base (30 minutes exercise)
TODO: finish code generation
TODO: review and cleanup sources
TODO: review and cleanup text draft
TODO: publish!
---

### Level 4
* ✔️ Generate an easy to use out of the box client stub from the API.
    * ✔️ Without model namespace clashes
    * ✔️ Including transferred nullable types
    * Support code generation with selective filtering i.e. only v1, or only for retail api ect.
    * Try to apply it in practice on work example json!

* https://docs.microsoft.com/en-us/aspnet/core/tutorials/getting-started-with-nswag?view=aspnetcore-6.0&tabs=visual-studio
* https://aevitas.medium.com/how-to-automatically-generate-clients-for-your-restful-api-fa34a6b408ff


## Sources

* auto typed return value: https://docs.microsoft.com/en-us/aspnet/core/web-api/action-return-types?view=aspnetcore-6.0
* enums as strings: https://stackoverflow.com/questions/36452468/swagger-ui-web-api-documentation-present-enums-as-strings
* XML comments: https://docs.microsoft.com/en-us/aspnet/core/tutorials/getting-started-with-swashbuckle?view=aspnetcore-6.0&tabs=visual-studio
* XML comments: https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/recommended-tags
* Conventions: https://docs.microsoft.com/en-us/aspnet/core/web-api/advanced/conventions?view=aspnetcore-6.0
* Fully qualified namespace for models: https://stackoverflow.com/questions/56475384/swagger-different-classes-in-different-namespaces-with-same-name-dont-work
* https://stackoverflow.com/questions/41005730/how-to-configure-swashbuckle-to-ignore-property-on-model
* https://newbedev.com/how-to-configure-swashbuckle-to-ignore-property-on-model
* https://mattfrear.com/2016/01/25/generating-swagger-example-requests-with-swashbuckle/
* https://mattfrear.com/2015/04/21/generating-swagger-example-responses-with-swashbuckle/
* https://github.com/mattfrear/Swashbuckle.Examples
* https://youtrack.jetbrains.com/issue/RIDER-11836
* https://jones.bz/c-8-0-nullable-reference-types-in-web-api-validation/
* https://stackoverflow.com/questions/64816714/when-to-use-record-vs-class-vs-struct

 /// https://newbedev.com/how-to-configure-swashbuckle-to-ignore-property-on-model
        /// https://github.com/domaindrivendev/Swashbuckle.AspNetCore/issues/2036
        ///             // https://newbedev.com/how-to-configure-swashbuckle-to-ignore-property-on-model
// https://newbedev.com/asp-net-core-require-non-nullable-types

// TODO: clear copies should also be included in the sample code

## NOTES

## DOTNET WEB API
1. enable model validation error on { amount: null }, {} for type { amount : non-nullable-int }
2. enable model validation error on { title: null }, {}, for type { title : non-nullable-string }
3. Is there a way to enable (1) and (2) without maintenance of individual request models, a global setting?

NotDefaultAttribute: https://andrewlock.net/creating-an-empty-guid-validation-attribute/

## Open API
A. for (1), non-nullable ints can be marked as required and non-nullable
B. for (2), non-nullable strings can marked as required and non-nullable

## Synthesis
* Can (1)+(A) be combined with nullable reference types, i.e. if int? then nullable?
* Can (2)+(B) be combined with nullable reference types, i.e. if int? then nullable?


