# NOTES

## level 0
✔️ Write a simple controller for silent auctioning off animals
✔️ GET auction list with animals and starting bid
✔️ Put animal for sale with minimum bid, id, age and weight
✔️ Put bid animal-id, bid, bidder-id
✔️ TODO: screenshot -> marked areas and how to edit them
✔️ C# xml docs (name?)
✔️ Enums as string values, string set

## level 1
✔️ Generate meaningful example values in swagger

## level 3
* Handle name clashing models (also in n-swag..)
✔️ Response and request models with required and optional attributes, default non-nullable validation
✔️ optional+required should also work outside of the documentation

## level 4
✔️ JetBrains annotations
  
## level 5
✔️ Verify previous values match with n-swag generation and tests
* https://docs.microsoft.com/en-us/aspnet/core/tutorials/getting-started-with-nswag?view=aspnetcore-6.0&tabs=visual-studio
* https://aevitas.medium.com/how-to-automatically-generate-clients-for-your-restful-api-fa34a6b408ff

## level 6
* Quick document of how to import into swagger
* Try to use code generation and postman open-api import for work examples
* TODO: figure out how to let example values propagate into postman
* TODO: quick! stabilize!

## Special cases

### How to handle name space clashes
### 
### Authentication via swagger? (meh.. outside of topic)

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


