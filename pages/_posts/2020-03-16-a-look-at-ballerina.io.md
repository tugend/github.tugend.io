---
title: A look at the Ballerina language 
category: architecture notes 
tags: language structure 
---

# Ballerina.io

![ballerina.io](/assets/ballerina-io.jpg "ballerina.io")

## Introduction and expectations

Ballerina is a language from 2015 that claims to compile to some kind of custom
bytecode. Version 1.0.0 was released September 2019. It describes itself as "an
open source programming language and platform for cloud-era application
programmers to easily write software that just works".

One of the compiler developers further add to the description in a [blog
post](https://medium.com/@sameerajayasoma/ballerina-runtime-evolution-f82305e4ab8e)
that "Ballerina is an event-driven, parallel programming language for networked
applications."

Given such a description, I immediately think of REST based micro-services and
expect a language that makes structure and typical tedious tasks less error
prone and easier to get right on the first go.

Going in, I didn't expect the next big thing, but had a hope that trying it out
might help build a stronger understanding for well structured cloud programming.
Like coding in a pure functional language is a somewhat accepted approach to
becoming better at applying functional concepts in other languages such as Java
or C#.

Source [ballerina.io](https://ballerina.io/).

In the following I will first present what issues I've experienced working with
REST based micro-services, then I'll share my impression of Ballerina, finally
ending with my personal and subjective conclusion.

## The top typical issues I've noticed programming in 'cloud-based' environments

The following are the top issues I experienced working in Java and C#. Each
issue can, of course, be solved and relatively easy so, but imagine large multi
team projects that is already under way and you may begin to understand the
difficulties.

Micro-services are often a tool chosen to handle scalability and to allow
multiple autonomous teams to work along each other in parallel. [Sam Newman;
Monolith to
Microservices](https://samnewman.io/books/monolith-to-microservices/). The less
opinionated the language, tools, project-generators and core documentation are,
the more likely it is that the projects will degrade over time into some sort of
brown, confused copy pasta soup. At least that's my experience from multiple
teams. The issue is especially true if the project has a relatively high
turnover.

Specific examples I've experienced are;

* Lack of easy ways to keep contracts up to date. Models are manually copied
  between each project and documenting breaking-changes rely on developers
  actually knowing when they introduce breaking changes as well as on everyone
  else actually keeping track of said change logs.

  Often I've tried to update a library only to notice it breaks the service in a
  completely undocumented way at runtime. Sigh.

  In comparison, I've also seen auto-generation of clients and models, or
  applied build constraints that parse the api and breaks on any obvious
  breaking changes. The latter case was yielded an immensely improved workflow
  compared to the former.

* A tendency for http primitives to leak into other layers. It could be a
  repository method that ends up being called `patchAddress` because it's
  introduced to initially to serve a patch endpoint, models that represent
  response or requests that, inconsistently, float all the way into the domain
  or repository layer or vice versa or several different layers of abstraction
  that all need to be aware of some necessary http headers. The old motto of
  "high cohesion and low coupling" comes to mind here.

* Tedious and error prone, duplicated, but slightly changed configurations of
  clients, such as how json is parsed, ect. spread throughout services as well
  randomly duplicated inside individual services.

* Often occurring lack of documentation of null, i.e. since we're often
  communicating across the wire using json, it can become difficult to keep
  track of which properties are nullable and which are not. I might add here,
  I'm really, really happy about the new C\# nullable reference types feature!
  ^_^

* Widespread confusion in respect to the language that is used to describe the
  different abstractions. For example I've worked on a project where a service
  (micro-service) contained several services (collection of endpoints) which
  delegated computation to various services (either clients to other APIS or
  strict domain functionality). No one knew what you where talking about when
  e.g. the EstateService failed.

* A lack of understanding and indeed difficulty getting any actually information
  or overview of the distributed system in question, i.e. how to handle loss of
  connection, complicated manual attempts at doing retries, difficulties in
  navigating the logs, and endless various on how to test a feature and at which
  levels. (See [Fallacies of Distributed
  Computing](https://en.wikipedia.org/wiki/Fallacies_of_distributed_computing))

Once again, yes, these issues properly represents other issues within the
organization or teams, such a lack of experience, but it is my interpretation
that these issues where repeated across companies, teams and projects, and that
they seemed to be somewhat connected to the tech choice of using
micro-services.lot

## Analysis

It was a walk in the park to get started; The language was straightforward to
install and get working on both Windows and Ubuntu. The Visual Studio Code
plugin for syntax highlighting and static syntax checking installed easily. The
first sample files compiled and ran without a hitch. The language documentation
was also very convincing.

Then I tried to actually code something that was nontrivial, and the pressure
was on!

I rather quickly ended up having problems and they just seemed to keep piling
up. That in it self wouldn't be much of an issue if I had just managed to find
something that impressed. Instead the language just kept feeling like a
well-meaning, but ultimately failed attempt at reinventing the wheel.

Some of the issues I encountered was;

* Handling files; you have to work with channels, explicit file-length and
  characters. I'm used to Node, Java and C#, and in comparison it quick felt
  like a rather big step down to some esoteric low level language (I'm looking
  at you, C and C++ guys).

* I've always been somewhat annoyed by Java's insistence to make all variable
  declarations explicitly typed as compared to C#s `var` keyword, in Ballerina
  long namespaced types seem to be common too; such as `io:WritableCSVChannel
  csvChannel`. I assume the general style of the documentation indicate the
  somewhat recommended style of writing here.

* The documentation and sample code is unfortunately not quite in sync, for
  example some of the given sample code failed to compile because the built-in
  parser didn't yet support backticks in method documentation, even though there
  where a entry about that specific feature. In the same way, the visual code
  plugin I used kept warning about multiple code errors when I just copied
  sample projects which was a bit disappointing. I'm sure they'll fix these this
  in time though.

* With respect to "Code that is easy to write and just works", I still needed to
  recompile multiple times and debug the runtime errors to make a simple
  endpoint accept a typed json body and print the request as a string. So,
  again, a little disappointed there.

* Readability, again, the language seemed a bit half baked and low-level
  compared to what else it out there. Have a look at their code sample for
  writing a file. I've removed comments and the definition for `closeRc` and
  `closeWc` which was also required,
  [sample](https://ballerina.io/learn/by-example/character-io.html)

  ```ballerina
  public function main() returns error? {
      io:ReadableByteChannel readableFieldResult =
          check io:openReadableFile("./files/sample.txt");

      io:ReadableCharacterChannel sourceChannel =
          new(readableFieldResult, "UTF-8");

      io:WritableByteChannel writableFileResult =
          check io:openWritableFile("./files/sampleResponse.txt")

      io:WritableCharacterChannel destinationChannel =
          new(writableFileResult, "UTF-8");

      io:println("Started to process the file.");

      var result = process(
        sourceChannel,
        destinationChannel);

      if (result is error) {
          log:printError("error occurred while processing chars ", err = result);
      } else {
          io:println("File processing complete.");
      }
  }
  ```

## Conclusion

I have to say that the idea is nice, but Ballerina just feels doesn't feel that
promising wrt. what it promises. I'm sad to say, it just feel like their ideas
might as well be expressed as a framework in any existing high-level language
and custom linter, and you'd be better off at a much lower cost.

The idea's I liked the most was the notion of introducing a library of
primitives for doing cloud based computing aka micro-services, and their notion
of automatically generating documentation was really neat. In practice the
latter seems to just be the same using as OpenApi annotations though.

In respect to performance, ease of writing and reading I didn't manage to find
anything that spoke of a competitive edge compared to most established languages
in the marked. Ballerina just felt worse on all accounts. Maybe I'm just not
putting in enough of an effort, or maybe the language just needs to mature a lot
more, but personally I'm just not convinced.

I'd recommend staying with a well-tested and strongly typed language and look
into more specific solutions to whatever actual issues your project could have.

Cheers

---

**PS**: *I have huge respect for the challenges of designing a language and the
effort required to produce something like Ballerina. My criticism ought to be
seen in the light of the very strong, strongly backed and competitive language
alternatives out there.*
