---
title: Authentication and authorization in .NET
category: "HTTP Services" 
tags: http api security dotnet csharp
---

## Challenges

I set for myself the following challenges for this project. The theoretical
basis can be found in the previous post [authorization and
authentication](https://tugend.github.io/security/2020/12/20/authorization-and-authentication.html),
and the code is available at [code samples for
authentication](https://github.com/tugend/code-samples--authentication/tree/master/SecureWebApi).

### Core Challenges

- Implement Basic authentication to protect an endpoint.

- Implement JSON-Web-Token based authentication to protect an endpoint.

- Support combined Basic _and_ JWT authenticated user authorization for an
  endpoint.

- Support nuanced authorization to allow restricted access for some subset of
  authenticated users via policies and claims.

### Bonus Challenges

- Find and implement a recommendable way to test a web api.

- Use nullable reference types.

- Document the sample API using basic Swagger and Swagger UI.

  - Customize the generated documents to name-spaces, which avoid
    name clashes when multiple same name classes exists.

  - Customize the document generation to output multiple separate documents that's
    selectable via the Web UI.

### Auxiliary learnings of note

- The specification for JWTs seems long and difficult. I found it especially
  troublesome to figure out what each key-value pair defined in the spec meant
  and should be used for. Definitely something I'd recommend looking further
  into.

- JWT tokens should expire after a set amount of time to reduce misuse if a
  token is stolen. In the sample implementation, it is set to 7 days. To avoid
  prompting the user to reenter credentials, one can implement a system for
  refreshing tokens which allow an app to renew the given access token
  automatically. An interesting subject in itself, which could be subject for
  further exploration.

- I experienced some cases where I have to admit annoyance at the .NET Core
  standard documentation and libraries as they are now.

  - On the IApplicationBuilder interface in the Startup.Configure method, the
    order you call UseAuthentication and UseAuthorization matters! The
    application will fail on runtime if you change the order, the authorize
    attribute will simply not work for your endpoints.     I don't see any
    reason why this should be the case, it's plain confusing and seems like a
    bad implementation detail in an otherwise nicely made library.

  - I'm a fan of immutable data types. I think they reduce errors, improve
    readability and avoid some common pit-falls of bad coding.

    I'm also rather excited about the new nullable reference types coupled
    with nullability warnings.

    Combining these two favorites of mine, I'd like to use them when I define
    the request and response models for the controllers, and here I run into
    a frustrating dilemma.

    - The System.Text.Json converter that's used by default, i.e. the new one
      from the standard .NET library, does not support deserialization for
      immutable objects. You have to have public setters and an empty
      constructor (it's on their backlog right now to support it). Alas the fix
      is simple, just use the ever steadfast converter from Newtonsoft instead.

    - I'm a fan of the IOptions pattern coupled with validation of data
      annotations. That's a nifty feature. This allow the annotations in our
      option settings like one might do for the request and response models for
      web API controllers . No more runtime debugging when some property is
      misspelled!

      Sadly, a similar issue occur here. They currently force you to create
      options classes with public setters and a parameterless constructor. Why
      Microsoft, why? I ended up silencing my warnings by adding explicit meta
      comments in each file. I guess we'll all just have to agree, not to write
      to our configs and keep them mutable - I don't expect it to be a problem,
      as much as I just find it inelegant. The alternatives I know of doesn't
      seem better either.

      I must admit though, it is really cool to add validation by annotation to
      the configuration class fields like many already do with the models for
      endpoints.

    - I discovered ISystemClock which is simple, but a nice to have built-in.

    - I'm very happy how the api tests ended up. This way to test, I think is
      very appropriate. The Rider IDE can even still figure out how to compute
      coverage on the tests! I'm also quite happy with the fluid extension
      methods for writing the tests, the style seems both easy to use, read -
      and to maintain.

    - I had some fun experimenting with folder structures, and I'm quite partial
      to the following. All three of the bullet points below seemed to work
      well for me.

      - Keep controllers small by splitting them up per route. This also helps
        keeping your test files manageable.

      - Ideally one controller per. endpoint and in a folder with the
        non-shared models it references.

      - When possible, try to use names that makes sense given the context and
        namespace. Why call a request type GetJwtTokenRequest or even worse
        UsersAuthenticateGetJwtTokenRequest rather than just Request given a
        namespace like Authentication.Jwt?

        I've seen it plenty of times where various parts of a namespace and type
        is put into the class names and I think it's terrible to work with. Yes,
        you need to figure out how to handle the name clash in Swagger (for
        example by introducing partial or fully qualified namespaces) and yes,
        you need to be careful not to use the wrong 'Request' object.

        But in my experience it becomes easy when you get used to working with
        your language namespaces and your IDE rather than against it. Same as
        when we have name clashes because we use two libraries that both define
        something of the same name.

    - There's really a lot of documentation out there, both for theory,
      implementations, frameworks and libraries.

      I try to keep in mind that when it concerns security, it may seem
      straightforward to get right, but I'll guarantee you there is a lot hidden
      in the details to be careful of.

## Sources

The sources I felt was useful on the various subject matter.

### Tests

- [How to test your csharp web api |
  timdeschryver.dev](https://timdeschryver.dev/blog/how-to-test-your-csharp-web-api)

## Authentication

- [ASP.NET Core 3.1 - Basic Authentication Tutorial with Example API |
  jasonwatmore.com](https://jasonwatmore.com/post/2019/10/21/aspnet-core-3-basic-authentication-tutorial-with-example-api)
- [Overview of ASP.NET Core authentication |
  docs.microsoft.com](https://docs.microsoft.com/en-us/aspnet/core/security/authentication/?view=aspnetcore-3.1)
- [Basic Authentication |
  docs.microsoft.com](https://docs.microsoft.com/en-us/aspnet/web-api/overview/security/basic-authentication)
- [Policy-based authorization in ASP.NET Core |
  docs.microsoft.com](https://docs.microsoft.com/en-us/aspnet/core/security/authorization/policies?view=aspnetcore-3.1)
- [Claims-based authorization in ASP.NET Core |
  docs.microsoft.com](https://docs.microsoft.com/en-us/aspnet/core/security/authorization/claims?view=aspnetcore-3.1)

## Swagger

- [Swashbuckle.AspNetCore Docs |
  github.com/domaindrivendev](https://github.com/domaindrivendev/Swashbuckle.AspNetCore)
- [Get started with Swashbuckle and ASP.NET Core |
  docs.microsoft.com](https://docs.microsoft.com/en-us/aspnet/core/tutorials/getting-started-with-swashbuckle?view=aspnetcore-3.1)

## Other

- [Issue with deserializing of reference types without parameterless constructor
  for System.Text.Json |
  stackoverflow.com](https://stackoverflow.com/questions/59198417/deserialization-of-reference-types-without-parameterless-constructor-is-not-supp)

## Potential Future Subjects of Interest

- [NSwag ~ generating client stubs from Swagger docs|
  docs.microsoft.com](https://docs.microsoft.com/en-us/aspnet/core/tutorials/getting-started-with-nswag?view=aspnetcore-3.1)
- [Refresh Tokens |
  auth0.com](https://auth0.com/docs/tokens/refresh-tokens)
- [App Service authentication and authorization |
  azure.microsoft.com](https://azure.microsoft.com/en-us/blog/announcing-app-service-authentication-authorization/)
- [Azure Identity management best practices |
  docs.microsoft.com](https://docs.microsoft.com/en-us/azure/security/fundamentals/identity-management-best-practices)
