---
layout: post--technical
title: Domain-Driven Design with .NET Core (⭐⭐⭐)
category: methodologies
tags: event-sourcing domain-driven-design books
published: true
---

![Domain-Driven Design with .NET Core](/assets/hands-on-domain-driven-design-book-front.jpg "Domain-Driven Design with .NET Core")
> Hands-On: Domain-Driven Design with .NET Core -- Zimarev, Alexey.

## Don't jump to conclusions

Be aware of the difference between **problem space** and **solution space**. It
can be compelling to jump directly to discussing solutions when faced with a
problem in software. Zimarev advices to understand the problem i.e. the problem
space first, then to look at solutions. The story of the two sisters and the
orange, is an example of a potential win-win scenario if one first tries to
understand the problem/requirements before jumping to conclusions.

```text
    Two sisters quarreled over a single orange that they both wanted.  

    Neither of  them would budge until their mother intervened and decided that
    the only way to resolve the dispute was to cut the orange straight down the
    middle and give each sister one half each.  

    The first sister then squeezed her orange half to make a drink of fresh orange
    juice while the second sister grated her orange half for peel to add to orange
    scones.  

    As a result, the sisters only got half of what they wanted.  

    -- managetrainlearn.com/page/win-win-deals
```

## Reduce accidental complexity, but accept essential complexity

**Accidental complexity;** The complexity of the code caused by the solution,
which often can be reduced. For example caused by technical debt or an badly
chosen framework.

**Essential complexity;** The complexity inherent in the problem domain. Can by
definition only be reduced by changing the problem.

## KISS before SOLID and DRY

When solving a problem, try to do so fast and simple first - then
improve. It often happens that, without the trivial approach to compare, we
'over-engineer' the solution, or even worse, never finish a task that could have
been solved less prettily within the deadline.

For example, don't optimize for performance, before you have a measurable need.
Do not create a point of variability before you have a need of variability.

## A comment on bounded contexts

Development should be handled as a collaboration between the users, the client,
the designers, the programmers, and so forth. To avoid playing the "broken
telephone" game, work together to build a **ubiquitous language**. This will
reflect in the dialog throughout the project as well as reflect on both the
implemented code and the thoughts behind.

Be also aware that a domain will often need to be split into multiple contexts,
each _may_ have it's own language. For example a problem concerning a criminal
system that integrates with lawyers, convicts, accused, the government ect. will
have different 'facades' or **bounded contexts**. Creating a single cohesive
world of domain concepts could result in confusion and a solution not fitting
anyone.

An ubiquitous language should be explicit, unambiguous, context-specific.

## Event Storming

Event storming is a workshop technique that aims to define the domain model,
i.e. the initial contexts and the core domain concepts captured in events e.g.
"Payment order created", "Payment order signed" ect. Post-its are traditional
used.

## The purpose of Domain Driven Design

```text
    The software we design and implement has only one primary purpose - to solve
    a domain problem. Understanding the domain, and the problem space, is crucial
    for the journey of finding proper solutions and satisfying users.
```

**Domain model**; An object model of the domain that incorporates both behavior
and data. Zimarev references
[Martin Fowler](martinfowler.com/bliki/AnemicDomainModel.html) commenting on the
anti-pattern of anemic models, when the data model strictly focus on data, e.g.
_without a cohesive encapsulation of behavior_.

A data centric domain model is often a bad idea, because you have to keep a
mental mapping from behavior to models.

For example; the method 'updatePrice' could represent the client is registering
a sale, correcting a mistake og changing his regular prices.

## Command-Query responsibility segregation (CQRS)

Coined by Greg Young, the concept can be applied to varying degrees, but at it's
core it concerns separating code that changes state from code that reads state.

Command-query separation (CQS) by Bertrand Mayer,
partitioned object methods into Commands and Queries. Young takes it a step
further and suggests creating two distinct and separate systems; One for handling
commands and one optimized for handling queries. The purpose is twofold, the
obvious one has to do with optimization, the second has to do with
maintainability, readability and ease of modification.

There is also an implicit anti-pattern which deserves mention; the case where
commands and queries are combined can result in a great confusion, and make code
reuse annoyingly difficult throughout the system, as well as the API it self.
For example; when each method in the API makes additional queries on a command because
the initial call also needed some unrelated additional data.

Zimarev argues that one should consider commands and queries as first-class
domain objects, i.e. the design of the domain model should include queries for
read models, and commands. In general making the system easier to build an
maintain.

Finally, I personally think CQRS will result in stronger abstractions and
easier testable, and reusable code.

Zimarev suggests that the detailed domain model should account for the
following concepts; Domain Events, Commands which ensures business rule
constraints are respected, read models, users/agents that interacts with the
system, and policies, which represents business rules that can be eventually
consistent and may cross boundaries, such as "deactivate when marked as sold".
Policies are often usually synonymous with process managers in an event sourced
system.

```bash
    Command         --generates-----------> Domain Event
    Policy          --invokes-------------> Command
    Domain Event    --translates-into-----> Read Model
    Domain Event    --triggers------------> Policy
    Actor           --invokes-------------> Command
    External System --generates-----------> Domain Event
```

## Code concepts and patterns

**Entities**  
Identified by id, encapsulate behavior and carries state

**Value Objects**  
Identified purely as primitive data values, e.g. address, userid, money

**Validation**  
Put validation in a single constructor, keep concepts that must be considered
together in the same class.

**Test names**  
Zimarev uses a convention of underscore, like
"Money_objects_with_the_same_amount_should_be_equal", which would improve
readability. In practice this if really annoying to write. It might be possible
to find a plugin to help with the issue.

Zimarev ends test class names with \_Spec e.g. Money_Spec.

**ToString**  
Use ToString as a means to create readable names for debugging. Often we forget
what we learn in programming 101.

**Nullable**  
Use explicit nullable types instead of null for reference types, e.g. Option\<T\>
or T? depending on language.

**EnsureValidState**  
Contract programming tip; Given an entity with multiple update methods, dry the
code for validation by reusing a single EnsureValidState method in all methods.

I strongly disagree with Zimarev on this one, it's much better if possible, to
add a layer of abstraction that guarantees these invariants are always
respected, i.e. it's easy to forget or accidentally remove an optional call to
some validation method.

**Events should not be validated after the fact**  
Events represent something that has happened, hence there is no reason to further
validate correctness.

**Aggregates**  
Sample code for Zimarevs aggregates.

```c#
public class UserAggregate
{
    /// executes command which stores the resulting event,
    /// updates the state and ensures invariants are respected
    Apply(CreateUser event) {
        // updates aggregate state
        When(event);
        EnsureValidState();
        _events.Add(event); // magically persists events
    }

    /// update aggregate state
    When(CreateUser event) {
        this.firstName = event.firstName;
        this.lastName = event.lastName;
    }
}
```

**Ids**  
It's recommended to generate ids  within the domain, rather than using
database controlled ids. Controlling ids from the domain may avoid some
issues wrt. testability, and migration issues later on.

<style>
/* Indent chapter image and subtext */
article > p:nth-child(1),
article > blockquote:nth-child(2) {
    text-align: center;
    border: 0px;
}
</style>
