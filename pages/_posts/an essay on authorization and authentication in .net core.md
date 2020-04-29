---
title: A look at authorization and authentication
category: security 
tags: programming C# .NET
---

I often confuse the two very similar looking words; Authorization and
Authentication. In this post I'll dig into what they mean and what I feel is
relevant to know about them, I'll close the blog by having a look into some
recommended implementation details when working with security in .NET.

## Definitions

### Authentication

If you authenticate an identity, you verify someone is who they claim they are.
In layman's terms, you can authenticate by presenting proof of identity, by
showing for example your passport. If an identity has been authenticated, it
means someone has accepted the proof of identity. 

You can also authenticate a piece of art and many other things too, usually this
means to authenticate the age of the piece, some properties like what it's made
of, or the identity of artist who is claimed to have made the piece. In all
cases it's really about the same thing, to verify whether a claim is true or
not, to determine if something is authentic.

A user can prove his identity by e.g. presenting a password, item or something
completely different, assumed to only be accessible by said person.

In literature, they say identity can be proved by three 'authentication factors'.
1) something you know, e.g. a password
2) something you have, e.g. a key or a phone
3) something you are, e.g. like a fingerprint

Multi-factor authentication requires two or more of the above to be presented,
E.g. presenting a card and a PIN can be described as a two factor authentication.

Strong authentication is apparently defined a bit varying, but basically,
it boils down to authentication using at least two authentication factors.

An example of digital authentication where the burden is put on some trustworthy
third agency, is generically described as digital authentication using a
credential service provider (CSP). Typically you prove your identity by having
actual contact with a representative of the CSP, who would then offer you a
digital authenticator in the form of a physical key-generator or an app on your
phone. Now you can use this CSP authenticator along with typically a password
and registered username to prove digitally who you are.

The opposition of authentication is the intent to forge, i.e. a forger would try
to forge an identity that fools what ever authentication schemes are used, e.g.
by sending emails that look like they come from your bank, by claiming they are
someone else, or printing fake bills.

Source: [Wikipedia](https://en.wikipedia.org/wiki/Authentication)

### Authorization

Authorization is the act of determining if access physically or digitally is
allowed for someone. I.e. given an access policy, you can determine if someone
is authorized to access a resource. Often given an access policy, you also want
to authenticate the identity of the person whom is requesting access, at least
if the access policy is based on identity or something similar.

Often the term is used for computer programs where some digital policy for
example categorizes users in the category 'managers' a different level of access
than the category 'employee', or 'guest'. In a military base you'd expect to
have a similar non-digital system restricting access to certain part of the base
to individuals of a certain rank and clearance.

Authorization naturally occur in the reflection of access restriction, i.e. some
kinds of access are restricted to a subset of the users who could possible try
to gain access. One of the simplest cases of authorization is of course a door
that only allow access for people with a key (one factor authentication)


## ----

.NET Core User Secrets
Git credentials manager
Using Google as a csp.
Basic Authentication.
JWT Tokens.
Setting up Firebase? with a authentication scheme


## Implementation details

### Authentication
### Authorization