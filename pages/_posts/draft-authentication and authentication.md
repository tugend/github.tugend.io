---
title: A look at authorization and authentication category: security tags:
programming C# .NET
---

I often confuse the two very similar looking words; Authorization and
Authentication. In this post I'll dig into what they mean and what I feel is
relevant to know about them, I'll close the blog by having a look into some
implementation details when working with security in .NET.

## Definitions

### Authentication

What does it mean? If you authenticate an identity, you verify someone is who
they claim they are. In layman's terms, you can authenticate by presenting 'proof
of identity', for example by showing your passport. If an identity has been
authenticated, it means someone has accepted the given 'proof'.

As another example, you can authenticate a piece of art, is it as old as claimed
 or is it a fake?

Authentication or the act of determining if something is authentic, really just
means figuring out whether or not you should believe a given claim.

In security and programming, authentication often concern how a user can prove
his identity, for example to get access to restricted resources. In the
literature, they often break such proofs of identity into three 'authentication
factors'.

1) Something you know and a fraud would not, e.g. a password
2) Something you have, which a fraud would not, e.g. a key or a phone
3) Something you are, which a fraud is not, e.g. like a fingerprint

The term 'multi-factor authentication' or strong authentication relates to the
above by requiring two or more different factors of authentication, such as
presenting a card and a PIN code. Using multiple factors is assumed to increase
the difficulty of cheating the system.

A common case, is digital authentication where the burden is put on some
trustworthy third agency. This is generically described as digital
authentication using a credential service provider or CSP. Typically you prove
your identity by having actual contact with a representative of the CSP, who
would then offer you a digital authenticator in such as a physical key-generator
or an app on your phone. Now you can use this CSP authenticator along with
typically a password and registered username to prove who you are using
multi-factor authentication.

Finally, the antagonist side of authentication is the intent to forge, i.e. a
forger would try to create a fake identity proof to cheat the authentication of
the system, for example, by sending emails that look like they come from your
bank, by claiming they are someone else, or printing fake bills.

Source: [Wikipedia](https://en.wikipedia.org/wiki/Authentication)

### Authorization

Authorization is the act of determining if access physically or digitally is
should be allowed, here it naturally follows that if not everyone should have
access, we need to authenticate the claim of the requesting<> that they are part
of the group who should have access.

Given an 'access policy' and an authentication scheme, you can determine if
someone is authorized to access a resource. For example, an access policy could
simply be a list of identities who should be allowed access and the scheme could
be to trust anyone with the username and password.

The notion of authentication and authorization is more common than one might
initially believe. As a very trivial example, think of the imple locked door
that allow access for people with the right key.

## ----

## The most common digital authentication schemes

### Basic Authentication

Basic access authentication, more commonly referred to as just basic
authentication, is perhaps the most simple form of web authentication that's
standardized.

Each HTTP request contains an authorization header with a base64 encoded string
consisting of your username and password separated by ':'.

Since the header is not encrypted in anyway, anyone can decode the
authentication and read the username and password. Therefore basic
authentication is often used together https to ensure confidentiality.

To avoid requesting the password all the time, the browser will typically cache
the headers for some amount of time. There is in fact no standardized way to
'log out' of a web browser with a cached basic authentication header.

#### Example

A website that with basic access authorization for a resource for example
www.pictures.com/pencils, would return HTTP Status 401 Unauthorized with the
the following header.

```http
WWW-Authenticate: Basic realm="User Visible Realm".
```

Then a browser would by default popup and ask the user to enter his or her
credentials and add the required header.

Given a username `'user1234'` and password `'pass1234'` would become the string
`'user1234:pass1234'` and encoded to `'dXNlcm5hbWU6cGFzc3dvcmQ='`, finally
yielding a header header key-value pair like `Authorization: Basic
dXNlcm5hbWU6cGFzc3dvcmQ=`.

Source: https://en.wikipedia.org/wiki/Basic_access_authentication


### Json Web Tokens (JWTs)

