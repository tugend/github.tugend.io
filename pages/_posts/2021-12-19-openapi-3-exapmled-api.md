---
category: technical 
tags: programming C# OpenApi 
layout: post--technical
title: "Api Versioning (OpenApi 3/3)"
---

Diverging from my previous approach, I'll try to start this post,
by stating which learning goals I had, followed by a commentary on
how I reached the given goals.

## Goals

### Level 0

* ✔️ Write a simple API for auctioning rice.
    * ✔️ Get list of items on auction including item id, minimum bid, batch quantity and batch quality.
    * ✔️ Post an item up for auction.
    * ✔️ Put a bid for a selected item.
* ✔️ Document the API with meaningful descriptions.
* ✔️ Public never-used parameters should not result in warnings or require disabling-warning annotations.
* 📦 Determine whether request and responses should be records, structs or classes.



### Level 1
* ✔️ Support multiple models with same names, e.g. Request, Response

### Level 2
* ✔️ Extend the API with meaningful example values
* ✔️ Example values should apply in swagger when trying an endpoint
* 📦 Example values should be randomized?

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

### Level 4
* ✔️ Generate an easy to use out of the box client stub from the API.
    * ✔️ Without model namespace clashes
    * ✔️ Including transferred nullable types

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


