---
title: A look at authorization and authentication
category: security
tags: programming C#
---

I often confuse the two very similar looking words; **Authorization** and
**Authentication**. In this post I'll dig into what they mean and what I feel is
relevant to know about them.

<!-- I'll close the blog by having a look into some
implementation details when working with security in .NET.

Part two can be (here)[authorization and authentication in .NET]. -->

## Definitions

### Authentication

What does it mean? If you authenticate an identity, you verify someone is who
they claim to be. In layman's terms, you can authenticate by presenting 'proof
of identity', for example by showing your passport. If an identity has been
authenticated, it means someone has accepted the given 'proof'.

As another example, you can authenticate a piece of art as the genuine article
or reject it as a forgery.

Authentication or the act of determining if something is authentic, really just
means figuring out whether or not you want to believe the given claim.

In security and programming, authentication often concern how a user can present
proof of his claim identity and right of access. In the literature proof of such
claims are often separated into three different 'authentication factors';

1. Something you know, e.g. a password
2. Something you have, e.g. a key or a phone
3. Something you are, e.g. like a fingerprint

The term 'multi-factor authentication' or strong authentication relates to the
above by requiring two or more different factors of authentication, such as
presenting a card and a PIN code. Using multiple factors is assumed to increase
the difficulty of cheating the system.

A common case, is digital authentication, where the burden of authentication is
delegated to a trustworthy third agency. This is generically described as
digital authentication using a 'credential service provider' or CSP. Typically
you prove your identity by having actual contact with a representative of the
CSP, who would then offer you a digital authenticator such as a physical
key-generator or an app on your phone.

Now you can use this CSP backed authenticator along with a password
and registered username to prove who you are (using multi-factor authentication).

Finally, the antagonist side of authentication is the intent to forge, i.e. a
forger would try to create a fake proof of identity to cheat the authentication.

Main source: [wiki/authentication](https://en.wikipedia.org/wiki/Authentication)

### Authorization

Authorization is the natural dual of authentication; the act of determining if
access, physical or digital, should be allowed. For any restricted resource
we'll of course want to determine whether the identity of the claimant is to be
believed - in other words we need to authenticate the identity to determine if
he or she should be authorized access.

Given an 'access policy' and an 'authentication scheme', you can determine if
someone should be authorized to access a resource. An access policy could simply
be a list of identities, whom should be allowed access and the scheme could be
to trust anyone who present a matching username and password.

---

## Common digital authentication schemes

### Basic authentication

Basic access authentication, or just basic authentication, is perhaps the most
simple form of web authentication that's standardized.

Each HTTP request is sent with an authorization header of your username and
password separated by ':' and base64 encoded.

Since the header is not encrypted though, anyone can decode the header and read
the username and password in clear text. Basic authentication is therefore often
recommend used with https to ensure confidentiality in transit.

To avoid requesting the password all the time, the browser will typically cache
the headers for some amount of time. There is in fact no standardized way to
'log out' of a web browser with a cached basic authentication header.

#### Example

Consider a website, that want to protect the resource at
'tugend.github.io/pencils' with basic access authorization. If one would try to
access said resource without a valid authentication header they would receive a
HTTP Status 401 Unauthorized with the the following header in reply.

```
WWW-Authenticate: Basic realm="User Visible Realm".
```

The browser will by default ask the user to enter his or her credentials and add
the required header for him and request the resource again.

Given the username `'user1234'` and password `'pass1234'`, the clear text string
would be `'user1234:pass1234'` which encodes to `'dXNlcm5hbWU6cGFzc3dvcmQ='`,
finally yielding a header header key-value pair of `'Authorization: Basic
dXNlcm5hbWU6cGFzc3dvcmQ='`.

Main source: [wiki/basic_acess_authentication](https://en.wikipedia.org/wiki/Basic_access_authentication)

### Json Web Tokens (JWTs)

Json Web Tokens are an open source, state-less (usually) open standard which can
be used for both authorization, and information exchange.

A token consists of three base64 encoded values concatenated by '.'; a header, a
payload, and a signature.

The **header** just contain information on which signing algorithm and token
type is used. The **payload** can contain arbitrary information, but when used
for authentication, it would usually contain a set of claims that would give the
user access. The **signature** is basically the header and the payload
cryptographically signed. The signature can for example be made using a RSA
private key, such that and would 'guarantee' the recipient that the token was
issues by a trustworthy party and not changed.

The token should always be sent via https and include a reasonable short expiry
time since anyone can use it if leaked or stolen.

A typical use of JWTs is a single-sign-ons to a web-site. In such a case the user
would send his credentials to some secure third party page/server (CSP) that will then
return a temporary access token or bearer token for the given site. Said token
is then passed as a 'bearer token' in the authorization header for all following
requests to the give web-site. _In my personal opinion it's a mess that everyone
keeps calling it token, jwt, access-token and bearer token while often meaning
the same thing!_

The standardized claim names of jwts are only three letters long, a
decision based on the intent to keep the resulting authorization header small in
size.

The two most important registered claim names worth mentioning are the json
web token id (jti) which can be used to avoid replay attacks, and expiration
time (exp) which indicates when the token should expire. There are many others.

#### Example

The following illustrates the process of acquiring an access token in the form
of a json web token, the creation of one and finally the use in
authentication to access a web-site.

The user, Bob, try to access `tugend.github.io/pencils`. This prompts an
authentication challenge which redirects him to a login page. Entering his
username and password, the page sends a POST request to `/authentication/token`
using Basic Authentication. As the username and password are valid, the endpoint
returns a brand new access token.

This content of the token could look like below.

<style>
.err {
  background-color: transparent !important;
  color: gray !important;
}

</style>

```json
// header example
{
  // the algorithm used to sign the token, in this case RSA with SHA-256.
  "alg": "RS256",
  // the type of token
  "typ": "JWT"
}

// payload example
{
    // json web token id which may be used to avoid replay attacks
    "jti": "94896a03-8c24-4e21-984d-3db2006a86d2",
    // identifies the issuer of the token
    "iss": "tugend.github.io/authentication",
    // identifies the purpose or subject of the token
    "sub": "tugend.github.io/pencils",
    // the expiration time in unix format
    // Sunday the 27 of September 21:33:12+2
    "exp": 1601235192,
    // we can add any additional 'public claims' that we want
    // in this case the name of the user
    "name": "Bob"
}
```

The token is generated by base64 encoding the header and the payload separately,
and then signing the combined value of the two and voila.

```js
content = base64Encode(header) + "." + base64Encode(payload);
signature = sign(content, secret);
token = content + "." + base64(signature);
```

The resulting token would look this this.

<div style='padding:1em 2em 2em 2em;font-family:monospace;width:600px;word-break:break-all;'>
<span style='color:red;'>eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9</span>.<span style='color:orange'>eyJqdGkiOiI5NDg5NmEwMy04YzI0LTRlMjEtOTg0ZC0zZGIyMDA2YTg2ZDIiLCJpc3MiOiJ0dWdlbmQuZ2l0aHViLmlvL2F1dGhlbnRpY2F0aW9uIiwic3ViIjoidHVnZW5kLmdpdGh1Yi5pby9yZXNvdXJjZXMiLCJleHAiOiIxNjAxMjM1MTkyIiwibmFtZSI6IkphbmUgRG9lIiwiYWNjZXNzLWxldmVsIjoiNSJ9</span>.<span style='color:purple'>IGQsU0ZIo8eyuBMNMi_kDpkoIZBRMY5iUi804ICqQD0aF_CtvbV8gkCx7xaGi-VUhKrjSnwjTgzw9VQNQSgHcSp1kcoJCnQAor3F9NS9SeN4iI8xnsB17QSc_ibPF0MioLEwaVuAinl5VmWnuO-T67khvFqQYG2Izj3hqn4BqaFh5crVXJKzs58ZvF_bEwinm2CIoJdiiyuOvfuX5tjFSHxQhVeq8IZzHu6v8x6vktBK3RKuRxaIfe9Vcgb3FIxhy40Oo0duhl9sxQOfZAr6hlGscDcZTnZZuF8Z-OIAUJjCdw5cJo9tJRADdI-hal2ubXaijbrIBfhigHA17rMEuw
</span>
</div>

Finally, the web-page or app that Bob is using, would save his new access token
as either a cookie or in local storage, and send it along along in the
authorization header for all the following requests to continuously prove his
identity as well as any other claims included in the token.

```
Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5c....A17rMEuw
```

Main sources:
- [wiki/json_web_token](https://en.wikipedia.org/wiki/JSON_Web_Token)
- [jwt.io/introduction](https://jwt.io/introduction/)
- [tools.ietf/tfc7519/section 4.1](https://tools.ietf.org/html/rfc7519#section-4.1)
- [jwt.io](https://jwt.io/#debugger)
- [autho0.com/json-web-tokens](https://auth0.com/learn/json-web-tokens/?_ga=2.183430182.1080785105.1601233286-783708108.1599336582)