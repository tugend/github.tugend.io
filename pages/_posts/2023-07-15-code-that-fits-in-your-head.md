---
layout: post--technical
category: methodologies 
tags: book heuristics code-quality c++
title: "Code that fits in your head (⭐)"
published: true
---

![Code That Fits in Your Head](/assets/2023/code-that-fits-in-your-head.jpg "Code That Fits in Your Head")
> Code That Fits in Your Head; Heuristics for Software Engineering -- Mark Seemann.

A book that worked as a basis for discussion, but I don't feel it's really
that well put together. The book seems a bit too unstructured and messy for my
tate, and I often find his references lazy and frustrating; for example he
mentions a '*Humble Object [66]*' which can be looked up in the back of the book
for a reference to another book '*xUnit Test Patterns ...*'. So what, to
understand your point I need to buy a different book? In general his style of
writing is meandering and a lot of his points could have been explained better
with 30% of the space.

Several of his points and most of the code examples he shares I find somewhat
disagreeable. Most of the book appear to be re-iterated arguments for functional
programming, buzz-sentences borrowed from other authors or describing somewhat common knowledge at length - like how to use Git.

I took some points to heart though. The book has a lot of other points, these
are just the ones that non-trivially resonated with me.

### Complexity

I appreciated the description of software engineering in part as a *'deliberate
process of preventing complexity from growing*', and the notion of a complex
code base requiring an increasing amount of time spent working from long term
memory. The inverse also applies, well structured code should allow a programmer
to work from short-term memory, simply because each component can be understood
in separation. This is an imagery of technical debt that I really like. :)

*The goal is not to write code fast. The goal is sustainable software.* [Seemann, Mark]

To reduce complexity he suggests measures of complexity and elimination by
decomposition. Measures include cyclomatic complexity analysis and simply
counting the number of 'concepts' per code block and/or the number of code
lines. The point boils down to **small, well named methods that do only one
thing**.

*Abstraction is the elimination of the irrelevant and the amplification of the
essential* [Robert C. Martin]

Decomposition is done by refactoring code into sub-components of abstractions
where each piece 'fits in your head' ('**fractal architecture**').

*.. Good programmers write code that humans can understand.* [Martin Fowler]

### Treat warnings as errors

I agree with the statement, but I will adamantly insist that one should do this
in the pipeline and leave warnings as warnings when developing the code locally.
I want to be able to run my tests even if I have an unused using or a newline
too many!

### Other points (paraphrased)

* Refactor or change, don't do both in the same commit.
* Log all impure actions, nothing more; A very neat guideline in my opinion. :) 
* Parse, don't validate; Use static factory methods that only return valid
  models for strong encapsulation and protection of invariants.
* Make sure to have a measurable driver for the code you write, do not add code
  that does not make a measurable difference (e.g. in your tests, static
  analysis, ect.).
* Write your tests outside-in, start at the highest level (acceptance tests) and
  shift down in gear when the combinatorial complexity drives a need for lower
  level tests (unit tests).