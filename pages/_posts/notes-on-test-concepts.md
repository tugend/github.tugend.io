# Notes on test terminology

There seems to be a lot of competing terms concerning software tests in the industry.
What's what? Let's try to do a summary overview and finish with a recommendation. 

The following descriptions are my personal opinions and may differ from established definitions.

## Why test at all

* To refactor with confidence
* To drive implementation
* To prove code is correct
* To document code behavior

## Writing tests bottom up vs. top down

Having tried the classic Test Driven Development approach multiple times, where one works bottom up,
creates a single class, writes unit tests, then compose the classes, write some
more tests, ect. works terrible in my opinion. The main problem to the approach
is the assumption that each components boundary is unchanging. The truth is that
often you end up changing said boundary multiple times during the implementation
resulting in very tedious and repeated refactorings of all tests too.

In my experience the bottom-up approach has absolutely failed to be feasible in
practice and I would strongly recommend a top down approach instead where you
prioritize writing acceptance tests from the point of view of the actual
behavior the system should exhibit and only when the high level tests become a
challenge due to the number of combinations should you shift gear down towards
unit tests.

'You can never have to many tests', well if you 75% of development time is used
to write tests you might have a problem - and no, it's not a matter of just
making a more elaborate custom testing framework.
  
## Unit testing

An unit test asserts on a 'unit' of code in isolation. This does not need to be
per class level, but often is.

**Recommended for**; Boundary tests.
**Recommended for**; Combinatorial tests. 
**Avoid**; Testing non-branching behavior (Cover these with Acceptance Tests).

```csharp
[Theory]
[InlineData(1, 2, 2)]
[InlineData(2, 2, 4)]
[InlineData(3, 2, 6)]
public void Multiply(int a, int b, int expected)
{
    sut
      .Multiply(a, b)
      .ShouldBe(expected);
}
```

## Integration testing

An integration test asserts behavior between two components and as such
represents a more complex setup and criteria compared to a unit test. I often
see the term used for database tests, i.e. when commands and queries are
verified by executing  against an actual database.

```csharp
[Fact]
public void GetPerson()
{
    var id = await sut.Save("John", 46);

    var result = await sut.Get(id);

    result.ShouldBe(new Person(id, "John", 46))
}
```

## System testing and acceptance testing

High level tests that asserts from outside of the system or program, for
example, actual HTTP requests hitting a locally running service. Will usually
require a complex domain specific language and fixture for setting system state
up to verify - since all invariants ect. applies here.

The acceptance part emphasizes tests that verify business criteria are
fulfilled, and as such should focus on the important parts of the system, i.e.
not necessarily that all error messages are correctly formatted ect.

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

## End to end tests and regression testing

Tests that verify the software runs as expected after deployment, i.e. automated
tests running against a browser displaying the actual website, or http requests
hitting the deployed services running in a sandbox environment. Usually rather
tedious, and often seen as very simple tests that's used mostly to verify
stability and availability, i.e. did the deploy itself break something, did one
of our actual dependencies break due to breaking changes in a dependency API.

For example, having a cron job run a Postman suite of requests verifying
expected http response codes every 10 minutes.


## Honorable mentions

Compiler errors, compiler warnings, static analysis and code reviews are all
in my opinion also important parts of code quality assurance too. 

---- 

Regression testing, the act of writing a test to make sure the bug you just fixed isn't re-introduced.
TDD, the good parts, write tests to make sure the behavior you just introduced isn't accidentally broken later.

https://testsigma.com/blog/the-different-software-testing-types-explained/
https://www.javatpoint.com/software-testing-tutorial
https://www.techtarget.com/whatis/definition/software-testing
## Smoke testing
## Regression testing
## Performance and load testing
## UAT

TODO: revisit with references and reasonable documented definitions