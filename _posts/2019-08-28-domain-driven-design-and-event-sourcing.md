---
layout: post
title: "Domain driven design and event sourcing"
description: "Custom written post descriptions are the way to go... if you're not lazy."
category: misc
tags: books, video
published: false
---

# Domain driven design and event sourcing
    28 august 2019
    * Ovesdal 20, Mårslet
    * Notes of interest from "Hands-On, Domain-Driven Design with .NET Core", Zimarev, Alexey, chapters 1-5.

## Nuggets of advice

### Nugget #1: Jumping to conclusions
Be aware of the diffeerence between problem space and solution space. It can be compelling to jump directly to discussing solutions when faced with a problem in software. Zimarev advices to understand the problem i.e. the problem space first, then to look at solutions. The story of the two sisters and the orange, is an example of a potential win-win scenario if one first tries to understand the problem/requirements before jumping to conclusions.

### Nugget #2: Complexity
**Accidental complexity;** The complexity of the code caused by the solution, which often can be reduced. E.g. a case of technical depth or an badly choosen framework.

**Essential complexity;** The complexity inherent in the problem domain. Can by definition only be reduced by changing the problem. 

### Nugget #3: KISS before SOLID DRY (personal note)
Strive to solve the problem the fastest and simplest way possible first, then improve. It often happens that without the trivial approach to compare, we overengineer the solution, or even worse, never finish a task that could have been solved less prettily within the deadline.

E.g. don't optimize for performance, before you have the need. Don't create a variability point before you have a need ect.

### Nugget #4: Domain knowledge

How do yo understand the solution space, i.e. how do you understand the need of the user. Start by learning the domain language and the domain concepts. Do not underestimate this task. Code implemented with a vauge understanding of the problem it solves will cause anyone grief. 

Development should be seen as a collaboration between the users, the client, the designers, the programmers, ect. avoid the "broken telephone" trap and work together to build an unbequitous language. This will reflect in the dialog througout the project as well as reflect on both the implemented code and the thoughts behind.

Be also aware that a domain will often need to be split into multiple contexts, each *may* have it's own langugage. E.g. a problem concerning a criminal system that integrates with lawers, convicts, accused, the goverment ect. will have different 'facades' or **bounded contexts**. Creating a single cohesive world of domain concepts could result in confusion and a solution not fitting anyone. Another example of multiple bounded contexts; product => sales, inventory, purchasing, warehouse.

An ubiquitous language should be explicit, unambigious, context-specific

### Nugget #4: Event Storming

Event storming is a workshop technique that aims to define the domain model, i.e. the initial contexts and the core domain concepts captured in events e.g. "Payment order created", "Payment order signed" ect. Post-its are very traditional. 

Consider staring with "Once upon a time" and "Happily ever after", to avoid affecting the participants with horror vacui.

### Nugget #5: The purpose of Domain Driven Design

"The software we design and implement has only one primary purpose - to solve a domain problem. Understanding the domain akka the problem space is crucial for the journey of finding proper solutions and satisfying the users. 

Domain model; An object model of the domain that incorporates both **behavior** and data. Zimarev references Martin Fowler commenting on the anti-pattern of anemic models. The trap where the data model is modelled with a strict focus on the data, e.g. classic CRUD resulting in an object model consisting of data models but _without a cohesive encapsulation of behavior_. 

A data centric domain model is often a bad idea, because you have to keep a mental mapping from behavior to models, i.e. updatePrice could mean the client is registering a sale, correcting a mistake og changing his regular prices. 

### Nugget #6: Command-Query responsibility segragation (CQRS)

Coined by Greg Young, the concept can be applied to varying degress, but at it's core it concerns seperating code that changes state from code that reads state. 

The original concept; Command-query seperation (CQS) by Bertrand Mayer, partitioned object mehtods into Commands and Queries. Young takes it a step further and suggests creating to distinct seperate systems, one for handling commands and one optimized for handling queries. The purpose is twofold, the obvious one has to do with optimization, the second has to do with maintainability, readability and ease of modification. 

There is also an implicit anti-pattern which deserves mention; the case where commands and queries are combined can result in a great confusion, and make code reuse annoyingly difficult throughout the system, as well as the API it self. E.g. when each method in the API makes additional queries on a command because the initial call also needed some unrelated additional data... 

Zimarev argues that one should consider commands and queries as first-class domain objects, i.e. the design of the domain model should include queries for read models, and commands. In general making the system easier to build an maintain.

Finally, I personally claim CQRS will result in stronger abstraktions and easierly tested, and resuable code.


    Zimarev argues that the detailed domain model should consist of the following concepts;
    * Domain Event
    * Commands; Ensures business rule constraints are respected
    * Read models
    * Users/agents
    * Policies; Business rules that can be eventually consistent and may cross boundaries, e.g. "deactivate when marked as sold". (see process managers)

    Command         -generates-----------> Domain Event
    Policy          -invokes-------------> Command
    Domain Event    -translates into-----> Read Model
    Domain Event    -triggers------------> Policy
    Actor           -invokes-------------> Command
    External System -generates-----------> Domain Event


### One-line #7: Use GUIDs over database controlled ids

### Code

* Entities: Identified by id, encapsulate behavior and carries state
* Value Objects: Identified purely as primitive data values, e.g. address, userid, money
* Keep validation in a single constructor
* Test names "Money_objects_with_the_same_amount_should_be_equal"
* Test class names should end with _Spec e.g. Money_Spec.
* Use ToString as a means to create readable names for debugging.
* Use Option<T> type instead of null for reference types. 
    * http://codinghelmet.com/articles/custom-implementation-of-the-option-maybe-type-in-cs, 
    * https://stackoverflow.com/questions/16199227/optional-return-in-c-net)
* Contract programming trick; Given an entity with multiple update methods, dry the validation by reusing a single EnsureValidState method.
* Events represent something that has happend, hence there is no reason to further validate correctness

* Aggregate { Apply(event) { when(event); EnsureValidState(); _events.Add(event); }}
  * When updates the aggregate state. 
  * Apply executes the command which stores the resulting event, update the state, ensures invariants are respected


