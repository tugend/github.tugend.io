---
published: false
---

# Ballerina.io

## Introduction and expectations

Ballerina is a language from 2015 that compiles to ballerina bytecode, that
describes itself as "an open source programming language and platform for
cloud-era application programmers to easily write software that just works".

One of the compiler developers further add to the description in a [blog post](https://medium.com/@sameerajayasoma/ballerina-runtime-evolution-f82305e4ab8e)
that "Ballerina is an event-driven, parallel programming language for networked
applications."

Given such a description I expect a language that make the structure and typical
tedious tasks associated with REST based micro-services to be more natural, i.e.
easy to get right the first time.

The top typical issues I've noticed programming in such an environment is as
follows. Every point can of course be solved, relatively easy, but imagine a
large micro service project that is already under way. First of all, you have to
respect some existing conventions because changing them would cause a lot of
confusion, sadly, and it takes a significant effort to induct multiple teams
into handling such issues in a practical manner, and often if the language and
platform allows, it will over time degrade unless it's easier to do it the right
way.

* Lack of easy ways to keep contract up to day, i.e. copy-paste models between
  services, with very little automation with respect to breaking changes and API
  updates  in general. I.e. you HAVE to use the documentation or read the
  consumed API code to actually rather than just update some client stub or what
  ever and explore the API as you might do with a classical library (yes, yes,
  of course also read the documentation sometimes)

* A tendency for http primitives to leak into other layers, so sudden a
  repository method is called patchAddress, or having to know of necessary
  headers at several different layers of abstraction.

* A strong lack of support for detecting breaking changes and clearly separating
  communication layer models from e.g. domain models.

* Several tedious duplicated but slightly changed configurations of clients,
  such as the json parsing ect.

* Often occurring lack of documentation of null, i.e. since we're often
  communicating across the wire using json using the classical protocol which
  makes it difficult to keep track of which properties can be null, and which
  cant.

* Widespread confusion in respect to the language primitives used to describe
  the different abstractions, often I hear about a service (micro service) that
  contains several services (collection of endpoints) which may use various
  services (either clients to other APIS or collections domain functionality).

* A lack of understanding and indeed difficulty getting any actually information
  about the distributed system in question, i.e. how to handle loss of
  connection, complicated manual attempts at doing retries, difficulties in
  navigating the logs, and endless various on how to test a feature and at
  which levels. (See [Fallacies of Distributed Computing](https://en.wikipedia.org/wiki/Fallacies_of_distributed_computing))

I don't expect Ballerina to become a widespread language, but using it might
help getting a strong understanding for well structured cloud programming. Like
coding in a pure functional language can help you become better using functional
concepts in other languages such as Java or C#.

Source [ballerina.io](https://ballerina.io/).

## Core abstractions

Client objects:
Services:
Resource functions:
Listeners:

## Takeaways and sample code

* Was super easy to install and get going.
* Can run without creating output files (donno, keeps them in memory I assume?).
* Initial tooling includes static type checking and syntax highlighting, good
  enough to help getting started.
* Nice tooling already just using VS Code, Rider is also supported
* Api Designer is a pretty sleek idea, i.e. api is to some degree equivalent
* Seems like relatively slow compile

## Other notes

The Robustness Principle: Be conservative in what you send, be liberal in what you accept