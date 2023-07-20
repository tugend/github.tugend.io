---
title: Notes on Software Tests
category: methodology
tags: programming process terminology
published: false
---

![](/assets/notes-on-software-tests--1.png)

## Introduction

There seems to be a lot of competing terms concerning software tests in the
industry. What's what? I'll try to do a personal summary of definitions and finish with a recommendation. 

- [Introduction](#introduction)
- [Why write tests](#why-write-tests)
- [Unit testing](#unit-testing)
- [Integration testing](#integration-testing)
- [System testing](#system-testing)
- [Writing tests bottom up](#writing-tests-bottom-up)
- [Writing tests top down](#writing-tests-top-down)
- [Summary](#summary)
- [Other Definitions](#other-definitions)
  - [Regression Testing](#regression-testing)
  - [Black box testing](#black-box-testing)
  - [White box testing](#white-box-testing)
  - [Functional tests](#functional-tests)
  - [Non-functional tests](#non-functional-tests)
  - [Smoke testing](#smoke-testing)
  - [Acceptance testing (User story based testing)](#acceptance-testing-user-story-based-testing)
  - [System testing](#system-testing-1)
  - [End to end testing](#end-to-end-testing)
  - [Contract testing](#contract-testing)
- [Load testing or performance testing](#load-testing-or-performance-testing)

## Why write tests

These are my five pillars of what value I think can be gained by writing tests. Mind you, I don't think one should be religious with respect to tests, a test should be written if it adds -enough- value, and deleted if it no longer is worthwhile to maintain and keep.

✅ **Refactor**      : To refactor with confidence  
✅ **Driver**        : To drive implementation  
✅ **Correctness**   : To prove code is correct  
✅ **Stability**     : To verify the code is stable  
✅ **Documentation** : To document code behavior  

Aside from actual software tests, it's also worth mentioning that often we use a
lot of 'implicit tests' to ensure code quality and correctness too; this
includes **compiler checks** and **warnings**, **static analysis** and **code
reviews** which in my opinion are no less important. 

## Unit testing

An unit test asserts on a 'unit' of code in isolation. This does not need to be
per class or function level, but often is.

**Recommended for**; Boundary tests.  
**Recommended for**; Combinatorial tests.  
**Avoid**; Testing non-branching behavior (Often these will be covered by these with System Tests).

```csharp
[Theory]
[InlineData(1, 2, 2)]
[InlineData(2, 2, 4)]
[InlineData(3, 2, 6)]
public void Multiply(int a, int b, int expected)
{
    var result = sut.Multiply(a, b);
      
    result.ShouldBe(expected);
}
```

## Integration testing

An integration test asserts behavior between two components and as such
represents a more complex setup and criteria compared to a unit test. I often
see the term used for database tests, i.e. when commands and queries are
verified by executing against an actual database. 

```csharp
[Fact]
public async Task GetPerson()
{
    var id = await sut.Save("John", 46);
    
    var result = await sut.Get(id);
      
    result.ShouldBe(new Person(id, "John", 46))
}
```

**Recommended for**; Database queries and not much else.  

## System testing

System testing concern high level tests that asserts from 'outside' of the
system, for example dispatching actual HTTP requests against the program Will
usually require a complex domain specific language and fixtures for setting
system state. As such system tests are also know to be the more difficult to
write and maintain.

```csharp
[Fact]
public void CancelPayment()
{
    var state = await factory.AfterInitiatedPayment();

    await httpClient
        .Cancel(state.UserId, state.PaymentId)
        .ShouldBeOk();

     await httpClient
        .Get(state.PaymentId)
        .ShouldBeCancelled();
}
```

**Recommended for**; Happy day path scenarios for features and functionality.  
**Be careful with**; Error path tests at this level since the tests bloats easily. Consider not
testing or unit testing these most of these instead.


## Writing tests bottom up

The **bottom up approach** is often how classic test driven development (TDD) is
interpreted, and is usually to write a test for the smallest software component
possible first and then adding tests for compositions all the way up the
hierarchy of code each test followed by an incremental bit of production code.

For example given we want to implement a calculator, one could write a tests for
each math function, then write a test for the composition of functions all the
way up to system tests of the calculator program API itself. This can be likened
to 'growing' the software from the bottom only writing tests for fully
functional pieces of code - where the design of each 'level' can be driven and
supported by tests.

A potential major downside of this approach is that you'll often have a lot of
redundant tests, i.e. a set of unit tests often end up covering the same as your
acceptance tests, in other words very rarely will a broken feature result in
just one failing test. Why is this bad? Because writing and maintaining tests
takes time and effort.

Additionally, outside of school, one does rarely have a clear design of
implementation and the developer will change the structure of the code as he
learns how it can be best to implement - which results in a somewhat tedious
feedback loop where you often cycle back and refactor unit tests all the time
due to changes in implementation though the required behavior hasn't changed.

## Writing tests top down

The **top down approach**, go the other way and starts by writing top-level
tests expressing the end result behavior we want to achieve. 

For example, one could start with writing a walking skeleton of a test our
calculator by asserting 1+1 works as expected through the UI. 

This approach will often allow you to avoid test redundancies since you'd be
able to skip writing unit tests for the parts of code that would be covered by
acceptance tests - so same code coverage, but fewer tests to write and maintain.


Because of the tendency of redundancies in test code and the frustration of
constantly having to do major refactor of the unit tests due to implementation
changes, I would strongly recommend a top down approach.

I'd advice writing acceptance tests from the point of view of the actual
behavior the system should exhibit and only when the high level tests become a
challenge due to the number of combinations should you shift gear down towards
unit tests.

'You can never have too many tests', well if you 75% of development time is used
to write tests you have a different problem - and no, it's not a matter of just
making a more elaborate custom testing framework.

## Summary 

In my opinion, a fully fledged test stack could consist of the following.

* A complex and well polished **system tests** suite that mostly
  describe the critical, positive behavior of the entire system (acceptance tests).
* **Integration tests** for SQL queries against an actual database, controller
  validations and similar multi-component fixture setups.
* **Unit tests** mostly for input combinations and behavior thresholds.

* **Automated tests** that protects the main branch integrated in your
  deployment pipeline, including compilation, static analysis, acceptance tests,
  integration tests and unit tests.

* A continuously running **smoke test suite** with simple assertions to catch
  breaking changes to other services (requires a test environment) and platform
  instability.

* **Visual diff end to end test suite** (also a system test) can be recommended
  for complex websites too and may also cover the need for acceptance tests.

* **Performance test suite**, periodically running a batch of tests to simulate
  high system load to notice any performance issues, and to have benchmark data
  for performance improvements.

* Manual verification of new features in both test environment and production,
  as well as production monitoring and alerts, because there's always something
  that slips by all the automated tests or that breaks after deployment.

---

## Other Definitions

There's a lot of competing definitions in the industry and depending on
framework and context from a manual quality test process of the usability and
likability of a website to the less-well defined automated software tests
written by API developers. The abstracts and notes below are simply my current
definitions of the topic. 

### Regression Testing
*A type of testing in the software development cycle that runs after every
change to ensure that the change introduces no unintended breaks.*

👉 [browserstack](https://www.browserstack.com/guide/regression-testing)

### Black box testing

*Black-box testing is a method of software testing that examines the
functionality of an application without peering into its internal structures or
workings.*

👉 [wikipedia](https://en.wikipedia.org/wiki/Black-box_testing)


A robust testing method that allow internal implementation to change without
breaking the test coverage or requiring refactoring of tests.

### White box testing

*.. a method of software testing that tests internal structures or workings of
an application, as opposed to its functionality (i.e. **black-box testing**). In
white-box testing, an internal perspective of the system is used to design test
cases. The tester chooses inputs to exercise paths through the code and
determine the expected outputs.*

👉 [wikipedia](https://en.wikipedia.org/wiki/White-box_testing)

White box testing is a bit fragile since creating tests based on how the
implementation is made results in tests that may become irrelevant when the
internal implementation change.

### Functional tests

*.. a type of** black-box testing** that bases its test cases on the
specifications of the software component under test. Functions are tested by
feeding them input and examining the output, and internal program structure is
rarely considered (unlike **white-box** testing)*

*Functional testing usually describes what the system does.*

👉 [wikipedia](https://en.wikipedia.org/wiki/Functional_testing)

I.e. testing system behavior wrt. input/output treating the system as a
'function'.

### Non-functional tests

*Non-functional testing is the testing process of a software application, web
application or system for its non-functional requirements: the way a system
operates, rather than specific behaviors of that system.*

👉 [wikipedia](https://en.wikipedia.org/wiki/Non-functional_testing)

I.e. load testing, security testing, et. al. 

### Smoke testing

*Smoke tests are a subset of test cases that cover the most important
functionality of a component or system, used to aid assessment of whether main
functions of the software appear to work correctly.*

👉 [wikipedia](https://en.wikipedia.org/wiki/Smoke_testing_(software))

From the practice of blowing smoke into pipes to spot any leakages. Often not
relevant as a concept due to automated tests that cover the same purpose, but
might be relevant irt. manual testing or slow builds and tests - here smoke
tests would be a subset of tests intended to  short circuit the process as soon
as possible.

### Acceptance testing (User story based testing)

Has a lot of different definitions depending on the specific context, but in my
opinion, but at it's core it covers whether the software is 'acceptable' by the
business and users. This can include all sorts of different processes involving
live users, business representatives and such kinda overlapping with
'beta-testing' and 'usability testing' such as 'can the user actually figure out
how to navigate on the site'.

In practice I've usually experienced it simply being used to cover tests that
verify business relatable, functional requirements are fulfilled, i.e. 'when
user clicks these buttons in sequence that happens'. Often such kind of
'scenario-based' or 'user-story' based tests require a dedicated domain specific
language and fixture to avoid heavy duplication when writing tests.

*Acceptance testing is a term used in agile software development methodologies,
particularly extreme programming, referring to the functional testing of a user
story by the software development team during the implementation phase.*

*The customer specifies scenarios to test when a user story has been correctly
implemented. A story can have one or many acceptance tests, whatever it takes to
ensure the functionality works. Acceptance tests are black-box system tests.
Each acceptance test represents some expected result from the system.*

👉 [wikipedia](https://en.wikipedia.org/wiki/Acceptance_testing)

### System testing

In my opinion this is kinda like acceptance testing and end-to-end testing since
those are usually on a system level depending on the definition of 'system'.

*System testing examines every component of an application to make sure that
they work as a complete and unified whole.*

👉 [techtarget](https://www.techtarget.com/searchsoftwarequality/definition/system-testing)

### End to end testing

*End-to-end testing is a type of testing that verifies the entire software
application from start to finish, including all the systems, components, and
integrations involved in the application’s workflow. It aims to ensure that the
application functions correctly and meets the user requirements. E2E testing may
involve various types of testing, such as GUI testing, integration testing,
database testing, performance testing, security testing, and usability testing.
Automated testing tools like Selenium, Cypress, and Appium are commonly used for
E2E testing to improve efficiency and accuracy.*

👉 [browserstack](https://www.browserstack.com/guide/end-to-end-testing)

In my opinion, this is synonymous with system testing but less ambiguous. Often
used in relation to GUI based browser tests that include visual comparisons.

### Contract testing

*Contract testing is a methodology for ensuring that two separate systems (such
as two microservices) are compatible and can communicate with one other. It
captures the interactions that are exchanged between each service, storing them
in a contract, which then can be used to verify that both parties adhere to it.*

👉 [pactflow](https://pactflow.io/blog/what-is-contract-testing/)

*Contract testing is the process of defining and verifying (testing) a contract
between two services, dubbed the “Provider” and the “Consumer”. The service
owner is the “Provider” while entities that consume the service are called
"Consumers".

There are two types of contract testing: consumer-driven and provider-driven.

In **consumer-driven contract testing**, the consumer creates a test suite that
specifies the expected behavior of the service provider. These tests are called
"consumer contracts". The service provider then implements the necessary
functionalities to pass these tests, i.e to meet them. The service provider's
implementation is verified against the consumer contracts to ensure that it
meets the expected behavior.

In **provider-driven contract testing**, the service provider defines the
contracts that the consumer (i.e., the client) must adhere to when consuming the
service. These contracts are usually defined in a format that can be shared
between the service provider and the client, like **OpenAPI**.

Once the contracts are defined, the service provider generates tests that verify
that the client adheres to the contracts. These tests are called "provider
contracts". The service provider runs the producer contract tests against the
client's implementation to ensure that it meets the expected behavior defined in
the contracts.*

👉 [blazemeter](https://www.blazemeter.com/blog/contract-testing)

Having some kind of controls to continuously keep track of whether or not
dependant systems introduce breaking changes seems sensible enough, but I have
to admit I don't really get contract tests as such. 

From the provider point of view, I think the term becomes synonymous with
acceptance tests. 

And if the open api specs are generated from the source code and versioned and
automatically published, there is little reason to test that the generated specs
follow the code.

Finally, in my experience the actual, un-expected breaking changes that occur in
contracts are due to unexpected behavior that's difficult to define in tests
that doesn't run on a live system. Here I would recommend having a continuously
running job that run a simple smoke test suite in a test environment with all
systems deployed instead - i.e. complete a payment for a test user every 10
minutes with some degree of monitoring in place - which can incidentally also
help test out production monitoring and alerts.

## Load testing or performance testing

*Load testing is the process of putting demand on a structure or system and
measuring its response.* https://en.wikipedia.org/wiki/Load_testing

Has the added benefit of producing benchmark data that allow quantitative
comparison when introducing performance improvements such as caching. It's
surprisingly common for developers to introduce code changes that 'should'
improve performance but definitely increase code complexity and risk of
introducing new bugs. 