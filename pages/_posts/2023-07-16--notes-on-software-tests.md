---
title: Notes on Software Tests
category: methodologies
tags: software-tests
published: true
---

![](/assets/notes-on-software-tests--1.png)

## Introduction

There are conflicting terms and guidelines on software tests out there. To great
frustration in the workplace where conversations can become quite confusing.
I'll start with the why, and then down into core terms, methodology and
definitions including my recommendations on the subject.

- [Introduction](#introduction)
- [The purpose of software testing](#the-purpose-of-software-testing)
- [Core layers of testing](#core-layers-of-testing)
  - [Unit testing](#unit-testing)
  - [Integration testing](#integration-testing)
  - [System testing](#system-testing)
  - [Implicit tests](#implicit-tests)
- [Methodology](#methodology)
  - [Writing tests bottom up](#writing-tests-bottom-up)
  - [Writing tests top down](#writing-tests-top-down)
- [Complete example of a test stack](#complete-example-of-a-test-stack)
- [Additional terms](#additional-terms)
  - [Regression Testing](#regression-testing)
  - [Black box testing](#black-box-testing)
  - [White box testing](#white-box-testing)
  - [Functional tests](#functional-tests)
  - [Non-functional tests](#non-functional-tests)
  - [Smoke testing](#smoke-testing)
  - [Acceptance testing (User story based testing)](#acceptance-testing-user-story-based-testing)
  - [System testing](#system-testing-1)
  - [End to End testing (E2E)](#end-to-end-testing-e2e)
  - [Contract testing](#contract-testing)
  - [Load testing or performance testing](#load-testing-or-performance-testing)


## The purpose of software testing

I'd argue the main point of software development is to produce code that
performs well while keeping the cost of development down for current and future
development amortized over the life time of the code, while maintaining a high
velocity and low rate of defects.

To support this, I present the five pillars of value I think can be gained by
writing tests in support of this.

✅ **Refactor**      : To refactor with confidence  
✅ **Driver**        : To drive implementation  
✅ **Correctness**   : To prove code is correct  
✅ **Stability**     : To verify the code is stable  
✅ **Documentation** : To document code behavior  

Mind you, I don't think one should be religious with respect to tests, a test
should be written if it adds *enough* value, and inversely, it should be deleted
if it no longer is worthwhile to maintain and keep.  

## Core layers of testing

### Unit testing

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

### Integration testing

An integration test asserts behavior between two components and as such
represents a more complex setup and criteria compared to a unit test. I often
see the term used for database tests, i.e. when commands and queries are
verified by executing against an actual database. 

**Recommended for**; Database queries and not much else.  

```csharp
[Fact]
public async Task GetPerson()
{
    var id = await sut.Save("John", 46);
    
    var result = await sut.Get(id);
      
    result.ShouldBe(new Person(id, "John", 46))
}
```

### System testing

System testing concern high level tests that asserts from 'outside' of the
system, for example dispatching actual HTTP requests against the program Will
usually require a complex domain specific language and fixtures for setting
system state. As such system tests are also know to be the more difficult to
write and maintain.

**Recommended for**; Happy day path scenarios for features and functionality.  
**Be careful with**; Error path tests at this level since the tests bloats easily. Consider not
testing or unit testing these most of these instead.

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

### Implicit tests

Aside from actual tests, there are other tools which are just as important to
leverage, this includes **compiler warnings**, **static analysis** and **code
reviews**, all of which can help us avoid common mistakes, anti-patterns and bad
mannerisms.

## Methodology

### Writing tests bottom up

The **bottom up approach** is often how classic test driven development (TDD) is
interpreted, and aims to write a test for the smallest software component
possible first and in a step-wise fashion adding tests for compositions all the
way up the hierarchy of the program, each test followed by an incremental bit of
production code.

A major downside of this approach is that you'll often end up with a lot of
redundant tests. For example, it's common to have detailed system tests that
will test the exact same branches of logic as multiple unit, and integration
tests. 

Why is this bad? Because writing and maintaining tests takes time and effort.

Additionally, outside of school, one rarely have a clear design of
implementation mind when developing a feature and developer tends to change code
structure often - which results in a somewhat tedious feedback loop where you
often cycle back and refactor unit tests all the time due to changes in
implementation even though the required behavior hasn't changed.

### Writing tests top down

The **top down approach**, goes the other way and recommends starting to write
top-level system tests expressing the end result behavior we want to achieve. 

This approach will often allow you to avoid test redundancy since you'd be able
to skip writing unit tests for the parts of code that would be covered
adequately by any higher level tests - so same code coverage, but fewer tests to
write and maintain.

I'd advice writing system tests from the point of view of the actual behavior
the system should exhibit and only when the high level tests become a challenge
to write due to for example a large number of possible combinations should you
shift gear down towards lower level tests.

'*You can never have too many tests*', well if 75% of your development time is
used to write and rewrite tests you may now have a bigger problem.

## Complete example of a test stack 

In my opinion, a fully fledged test stack could consist of the following.

* A well polished **system tests** suite that mostly describe the critical,
  positive behavior of the entire system (see Acceptance Tests).
* **Integration tests** for SQL queries against an actual database, controller
  validations and similar multi-component fixture setups.
* **Unit tests** mostly for input combinations and behavior thresholds.

* **Automated tests** that protects the main branch integrated in your
  deployment pipeline, including compilation, static analysis, acceptance tests,
  integration tests and unit tests.

* A **continuously running test suite** with simple assertions to catch breaking
  changes to other services (requires a test environment) and platform
  instability (see Smoke Tests).

* **Visual diff end to end test suite** (also a system test) can be recommended
  for complex websites too and may overlap with other needs for system tests.

* **Performance test suite**, periodically running a batch of tests to simulate
  high system load and automatically alert on any performance issues, and to
  have benchmark data for performance improvements.

* **Manual verification**, of new features in both test environment and production,
  as well as production monitoring and alerts, because there's always something
  that slips by all the automated tests or that breaks after deployment.

---

## Additional terms

There's a lot of competing definitions in the industry and depending on
framework and context; from the manual quality assurance process of the
usability and likability of a website to the automated software tests written by
API developers. The abstracts and notes below are simply my current reference
definitions of the terms. 

### Regression Testing
*A type of testing in the software development cycle that runs after every
change to ensure that the change introduces no unintended breaks.*

👉 [BrowserStack](https://www.browserstack.com/guide/regression-testing)

I sometimes hear the term 'regression test', but as far as I know that's not
actually a meaningful term, part of regression testing is to write tests of
different types, but those tests does not as such become 'regression tests'.

### Black box testing

*Black-box testing is a method of software testing that examines the
functionality of an application without peering into its internal structures or
workings.*

👉 [Wikipedia](https://en.wikipedia.org/wiki/Black-box_testing)

A robust testing method that allow internal implementation to change without
breaking the test coverage or requiring refactoring of tests.

### White box testing

*.. a method of software testing that tests internal structures or workings of
an application, as opposed to its functionality (i.e. **black-box testing**). In
white-box testing, an internal perspective of the system is used to design test
cases. The tester chooses inputs to exercise paths through the code and
determine the expected outputs.*

👉 [Wikipedia](https://en.wikipedia.org/wiki/White-box_testing)

White box testing is fragile since creating tests based on how the
implementation is made results in tests that may become irrelevant when the
internal implementation change.

### Functional tests

*.. a type of **black-box testing** that bases its test cases on the
specifications of the software component under test. Functions are tested by
feeding them input and examining the output, and internal program structure is
rarely considered (unlike **white-box** testing)*

*Functional testing usually describes what the system does.*

👉 [Wikipedia](https://en.wikipedia.org/wiki/Functional_testing)

In other words, functional testing is just writing tests that verify the
behavior of the system, given this setup and these inputs, this should be the
result.

### Non-functional tests

*Non-functional testing is the testing process of a software application, web
application or system for its non-functional requirements: the way a system
operates, rather than specific behaviors of that system.*

👉 [Wikipedia](https://en.wikipedia.org/wiki/Non-functional_testing)

For example, load testing, tests that targets race conditions and security
tests.

### Smoke testing

*Smoke tests are a subset of test cases that cover the most important
functionality of a component or system, used to aid assessment of whether main
functions of the software appear to work correctly.*

👉 [Wikipedia](https://en.wikipedia.org/wiki/Smoke_testing_(software))

Named from the practice of blowing smoke into pipes to spot any leakages.
Relevant irt. manual testing or slow builds and tests - where smoke tests can be
a curated subset of tests intended to short circuit on a tedious or slow process
as soon as possible on the most often occurring error types.

I've also used the term to cover 'early warning' tests, where a test suite runs
on a timer against in a given (test) environment to simply spot if dependant
APIs remain live with unchanged contracts - since it's often not worthwhile to
reimplement or re-use  more complex full coverage tests for this purpose -
either we get a 200 OK response or we get an error response.

### Acceptance testing (User story based testing)

Has many different definitions depending on context, but at it's core it covers
whether the software is 'acceptable' by the business and end-user. This can
include all sorts of different processes involving live users, business
representatives and overlaps concepts of 'beta-testing' and
'usability testing'.

In practice I've usually experienced it being used to cover software tests that
verify business relatable, functional requirements are fulfilled, tests such as
'when user clicks these buttons in sequence x happens'. Often such kind of
'scenario-based' or 'user-story' based tests require a dedicated domain specific
language and fixture to avoid heavy duplication when writing tests.

*Acceptance testing is a term used in agile software development methodologies,
particularly extreme programming, referring to the functional testing of a user
story by the software development team during the implementation phase.*

*The customer specifies scenarios to test when a user story has been correctly
implemented. A story can have one or many acceptance tests, whatever it takes to
ensure the functionality works. Acceptance tests are black-box system tests.
Each acceptance test represents some expected result from the system.*

👉 [Wikipedia](https://en.wikipedia.org/wiki/Acceptance_testing)

### System testing

In my opinion this is a subset of acceptance testing and end-to-end testing
since those are usually on a system level depending on the definition of
'system'.

*System testing examines every component of an application to make sure that
they work as a complete and unified whole.*

👉 [TechTarget](https://www.techtarget.com/searchsoftwarequality/definition/system-testing)

### End to End testing (E2E)

*End-to-end testing is a type of testing that verifies the entire software
application from start to finish, including all the systems, components, and
integrations involved in the application’s workflow. It aims to ensure that the
application functions correctly and meets the user requirements. E2E testing may
involve various types of testing, such as GUI testing, integration testing,
database testing, performance testing, security testing, and usability testing.
Automated testing tools like Selenium, Cypress, and Appium are commonly used for
E2E testing to improve efficiency and accuracy.*

👉 [BrowserStack](https://www.browserstack.com/guide/end-to-end-testing)

In practice the term is mostly used in relation to GUI based browser tests of
which the highest fidelity includes visual comparison tests.

### Contract testing

*Contract testing is a methodology for ensuring that two separate systems (such
as two microservices) are compatible and can communicate with one other. It
captures the interactions that are exchanged between each service, storing them
in a contract, which then can be used to verify that both parties adhere to it.*

👉 [PactFlow](https://pactflow.io/blog/what-is-contract-testing/)

*Contract testing is the process of defining and verifying (testing) a contract
between two services, dubbed the “Provider” and the “Consumer”. The service
owner is the “Provider” while entities that consume the service are called
"Consumers".*

*There are two types of contract testing: consumer-driven and provider-driven.*

*In **consumer-driven contract testing**, the consumer creates a test suite that
specifies the expected behavior of the service provider. These tests are called
"consumer contracts". The service provider then implements the necessary
functionalities to pass these tests, i.e to meet them. The service provider's
implementation is verified against the consumer contracts to ensure that it
meets the expected behavior.*

*In **provider-driven contract testing**, the service provider defines the
contracts that the consumer (i.e., the client) must adhere to when consuming the
service. These contracts are usually defined in a format that can be shared
between the service provider and the client, like **OpenAPI**.*

*Once the contracts are defined, the service provider generates tests that verify
that the client adheres to the contracts. These tests are called "provider
contracts". The service provider runs the producer contract tests against the
client's implementation to ensure that it meets the expected behavior defined in
the contracts.*

👉 [BlazeMeter](https://www.blazemeter.com/blog/contract-testing)

Having some kind of controls to continuously keep track of whether or not
dependant systems introduce breaking changes seems sensible enough, but I have
to admit I don't really get contract tests as such. 

From the provider point of view, I think the term becomes synonymous with
acceptance tests. It's a nice thought that the consumer can define some tests and then have them included in the test suite of the produce, but I have never seen that work in practice.

And if the open api specs are generated from the source code and versioned and
automatically published, there is little reason to test that the generated specs
follow the code - they will do so by definition.

In my experience the actual, un-expected breaking changes that occur in
contracts are due to unexpected behavior that's difficult to define in tests
that doesn't run on a live system. 

Here I would recommend having a continuously running job that run a simple smoke
test suite in a test environment with all systems deployed instead - i.e.
complete a payment for a test user every 10 minutes with some degree of
monitoring in place - which can incidentally also help test out production
monitoring and alerts and be a segway to performance testing.

### Load testing or performance testing

*Load testing is the process of putting demand on a structure or system and
measuring its response.*

[Wikipedia](https://en.wikipedia.org/wiki/Load_testing)

Has the added benefit of producing benchmark data that allow quantitative
comparison when introducing performance improvements such as caching. It's
surprisingly common for developers to introduce code changes that 'should'
improve performance but definitely increase code complexity and risk of
introducing new bugs.