---
category: technical 
tags: programming books
layout: post--technical
title: "Code that fits in your head (Book)"
published: true
---

## BETA publish

Content is subject to change until beta tag is removed.

## Code That Fits in Your Head by Mark Seemann ⭐⭐⚫⚫⚫

![Code That Fits in Your Head by Mark Seemann](/assets/2023/code-that-fits-in-your-head.jpg "Code That Fits in Your Head by Mark Seemann")

A book that worked well as a basis for discussion, but I don't feel it's really
that well put together. The author seems to be fumbling a bit and I often find
his references lazy and frustrating; for example he mentions a '*Humble Object
[66]*' which can then be looked up in the back of the book for a reference to
'*xUnit Test Patterns ...*'. So what, to understand your point I need to buy a
different book? In general his style of writing is meandering and a lot of his
points could have been explained better with 30% of the space.

Several of his points and most of the code examples he shares I find somewhat
disagreeable. Most of the book seems to me to be re-iterated arguments for
functional programming, buzz-sentences borrowed from other authors or somewhat
trivial, common consensus work-flows in the business.

I took some points to heart though. The book has a lot of other points, these
are just the ones that non-trivially resonated with me.

### Complexity

I appreciated the description of software engineering in part as a *'deliberate
process of preventing complexity from growing*', and the point that a complex
code base requires an increasing amount of time spent on 'storing' an
understanding in long term memory. This is an imagery of technical debt that I
really like. :)

*The goal is not to write code fast. The goal is sustainable software.* [Mark
Seemann]

To reduce complexity he suggests measures of complexity and elimination by
decomposition. Measures include cyclomatic complexity analysis and simply
counting the number of 'concepts' per code block and/or the number of code
lines. More or less boils down to **small, well named methods that do only one
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

* Refactor OR change; Avoid doing both in the same commit.
* Do not get used to flaky tests.
* Log all impure actions, nothing more; A very neat guideline in my opinion. :) 
* Parse, don't validate; Use static factory methods that only return valid
  models.
* X-driven development; Make sure to have a measurable driver for the code you
  write, do not add code that does not make a measurable difference (e.g. in
  your tests, static analysis, ect.).
* Write your tests outside-in, start at the highest level (acceptance tests) and
  shift down in gear when the combinatorial complexity drives a need for lower
  level tests (unit tests).