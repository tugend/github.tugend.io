---
state: needs proofing, but otherwise ready to publish
published: false
---

# Ballerina.io

## Introduction and expectations

Ballerina is a language from 2015 that claims to compile to ballerina bytecode
but have obvious strong inheritance from java. It describes itself as "an open
source programming language and platform for cloud-era application programmers
to easily write software that just works".

One of the compiler developers further add to the description in a [blog
post](https://medium.com/@sameerajayasoma/ballerina-runtime-evolution-f82305e4ab8e)
that "Ballerina is an event-driven, parallel programming language for networked
applications."

Given such a description I expect a language that make the structure and typical
tedious tasks associated with REST based micro-services to easier to get right
the first time, as well as improve the ease of writing and maintaining such.

I don't expect Ballerina to become a widespread language, but trying it out
might help getting a strong understanding for well structured cloud programming.
Like coding in a pure functional language can help you become better using
functional concepts in other languages such as Java or C#.

Source [ballerina.io](https://ballerina.io/).

## The top typical issues I've noticed programming in 'cloud-based' environments

The following are the top issues have I experienced working in Java and .NET
with microservices (which in my interpretation is the same as what the compiler
developers are targeting). Every point can of course be solved and relatively
easy so, but imagine a large micro-service project that is already under way. 

First of all, microservices are often a tool chosen to handle scalability and to
allow multiple autonomous teams to work along each other in parallel. The less
opinionated the language, tools, project-generators and core documentation are,
the more likely it is that the projects will degrade over time into some sort of
brown confused, copy pasta soup. At least that's my experience from multiple projets. 
The issue is especially true if the company has a relatively high turnover.

Concrete examples I've experienced are;

* Lack of easy ways to keep contracts upto day. That is, if models are manually
  copied between each project and documenting breaking changes rely on
  developers actually knowning when they do so and everyone else actually
  keeping track of said information. 

  Often I've tried to update a library only to notice it breaks the service in a
  completely undocumented way on runtime. Sigh.

  In comparison, what I've also seen are auto-generation of clients and models,
  or an actual build constraint that parse the api and breaks on any obvious
  breaking changes.

* A tendency for http primitives to leak into other layers. It could be a
  repository method ends up being called `patchAddress` because it's initially
  used to serve a patch endpoint, models that represent response or requests
  that, inconsistenly, float all the way into the domain or repository layer or
  vice versa or several different layers of abstraction that all need to be
  aware of neccessary http headers.

* Several tedious duplicated but slightly changed configurations of clients,
  such as how json is parsed, ect.

* Often occurring lack of documentation of null, i.e. since we're often
  communicating across the wire using json using the classical protocol which
  makes it difficult to keep track of which properties can be null, and which
  can't. I might add, I'm really, really happy about the new C\# nullable
  reference types feature!

* Widespread confusion in respect to the language used to describe the different
  abstractions. For example I've worked on a project where a service (micro
  service) contained several services (collection of endpoints) which delegated
  computation to various services (either clients to other APIS or strict domain
  functionality).

* A lack of understanding and indeed difficulty getting any actually information
  about the distributed system in question, i.e. how to handle loss of
  connection, complicated manual attempts at doing retries, difficulties in
  navigating the logs, and endless various on how to test a feature and at which
  levels. (See [Fallacies of Distributed
  Computing](https://en.wikipedia.org/wiki/Fallacies_of_distributed_computing))

## Analysis

It was a walk in the park to get started; The language was straightforward to
install and get working on both Windows and Ubuntu, as well as the Visual Studio
Code plugin for syntax highlighting and static syntax checking. The first sample
files complied and ran without a hitch. The language documentation was also
convincing and adequate.

Then I tried to actually code something that was nontrivial, and the preassure
came on.

I quickly ended up having problems which seemed to just keep piling up. That in
it self would be much of an issue if I had just managed to find something that
impressed. Instead the language just kept feeling like a well-meaning, but
ultimatedly failed attempt at reinventing the wheel.

Some of the issues I encountered was;

* Handling files; you have to work with channels, filelength and characters. I'm
  used to Node, Java and C\#, and in comparison it quick felt like a rather low
  level language. 

* I've always been somewhat annoyed by Java's requirement that all variable
  declarations must be explicitly types (compared to C\#s var keyword), in
  Ballerina you even see long namespaced types seem to be common such as
  'io:WritableCSVChannel csvChannel'. This might be solvable, but I assume the
  general style of the documentation indicate the somewhat recommended style of
  writing.
  
* It quickly became obvious that the documentation and sample code is not quite
  in sync, i.e. trying to actually build their own sample of how to document
  code fails to parse because the built-in parser does not support backticks in
  method documentation, and the plugin warns about multiple code errors in the
  same samples.
  (here)[https://ballerina.io/v1-1/learn/how-to-document-ballerina-code/]).

* With respect to "Code that is easy to write and just works", I still needed to
  recompile multiple times and debug the runtime errors to make a simple
  endpoint taking a record as body and print it as a string. 

* Readability, again, it seems somewhat halfbaked and low-level compared to what
  else it out there. Have a look at their code sample for writing a file. I've removed comments and the definition for `closeRc` and `closeWc` which is also included. [sample](https://ballerina.io/learn/by-example/character-io.html) 

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
      
      closeRc(sourceChannel);
      closeWc(destinationChannel);
  }
  ```

## Conclusion

I have to say that the idea is nice, but basically it feels like a completely
unneccessary layer ontop of java that might as well be implemented easier and
simpler as a framework in any existing high-level language. I'd say they
are trying to hard to do everything at once.

The idea's I liked the most was the notion of introducing library of primitives
for doing cloud based computing aka microservices, and their notion of
automatically generating documentation is also neat. In practice the latter
seems to just be the same using as OpenApi annotations though.

In respect to performance, easy of writing or reading I didn't manage to find
anything that spoke of a competitive edge compared to most established languages
in the marked. 

I'd recommend staying with a well-tested and strongly typed language and look
into more specific solutions to whatever actual issues your project could have. 