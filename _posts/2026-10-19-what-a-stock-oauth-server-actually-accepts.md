---
title: "What a stock OAuth server actually accepts"
date: 2026-10-19 08:00:00 +0200
categories: [Guides]
tags: [oauth, keycloak, redirect-uri, lab]
description: >-
  I ran eight redirect_uri validation tests against stock Keycloak 26.0, all
  on localhost. Two results contradicted what I assumed: host wildcards are
  silently useless, and PKCE is off by default.
image:
toc: true
comments: true
disclosure:
  status: public
  program_consent: n/a
  disclosed_on: 2026-10-19
---

In OAuth, `redirect_uri` is the parameter that holds the whole guarantee
together. The authorization code gets handed back to *one* registered place,
and the entire defence against a stolen or leaked code rests on the server
refusing to send it anywhere else.

So the interesting question isn't "is redirect_uri validated?" It's "validated
*how*, exactly, by default, before anyone configures anything?" I had
assumptions. I decided to test them instead of quoting them.

> The short version: evil siblings are rejected, scopes are strict, the host
> wildcard I assumed existed **doesn't**, and PKCE is **off** until you turn
> it on.
{: .prompt-tip }

## The setup

Nothing clever, and nothing on the internet:

- Stock `quay.io/keycloak/keycloak:26.0` (26.0.8), listening on
  `127.0.0.1:8081`.
- A realm called `lab`, with three clients:
  - `c1`: exact registered redirect `https://app.example.com/callback`
  - `c2`: host wildcard `https://*.example.com/*`
  - `c3`: path wildcard `https://app.example.com/*`
- Every request below goes to localhost. No external host was contacted, and
  no live system was involved.

One methodological note, because it matters more than the results: **every
verdict is `Observed`**, captured directly from a response or a server log
event. Nothing here is inferred, reproduced from someone else's writeup, or
generalised beyond what I saw. Where I don't know, it says so.

## The results

| # | Test | Result |
|---|---|---|
| TK0 | Baseline: exact registered redirect | `200`, login page rendered |
| TK1 | Unregistered host | `400 Invalid parameter: redirect_uri` |
| TK2 | Evil siblings (`app.example.com.evil.test`, `evil-app.example.com`) | `400`, both rejected |
| TK3 | Trailing path + query injection | `400`, both rejected |
| TK4 | Host wildcard client (`c2`) | **every candidate rejected, including its own** |
| TK4b | Path wildcard client (`c3`) | `200` for registered path, `200` for `/callback/evil` |
| TK5 | Flow-agnostic (implicit vs code) | identical validation, no bypass |
| TK6 | PKCE | **not enforced by default**; opt-in per client |
| TK7 | Scope handling | unknown scope → whole request rejected |

## Three findings worth the post

### 1. The host wildcard is stored, and matches nothing

This is the one that changed how I'd review a Keycloak config. Client `c2` was
configured with the pattern `https://*.example.com/*`, a form that looks like
standard wildcard support. Every single candidate I tried against it failed:

```
redirect_uri=https://foo.example.com/cb                       -> 400
redirect_uri=https://evil.example.com/cb                      -> 400
redirect_uri=https://a.b.example.com/cb                       -> 400
redirect_uri=https://example.com/cb                           -> 400
redirect_uri=https://app.example.com.evil.test/cb             -> 400
redirect_uri=https://app.example.com/callback/evil            -> 400
redirect_uri=https://app.example.com/callback?next=//evil.test -> 400
```

All seven rejected, with the server event `invalid_redirect_uri` each time.

My first read was "good, that's strict". The actual explanation is less
comforting: the pattern is **accepted and stored, but the matcher doesn't
support host wildcards**, so it matches no redirect URI at all.

Meanwhile `c3`, registered with a *path* wildcard (`https://app.example.com/*`),
behaved as you'd expect: the exact path worked, and so did a suffix:

```
https://app.example.com/callback      -> 200 login page
https://app.example.com/callback/evil -> 200 login page
https://evil.example.com/cb           -> 400
```

That's a real path-suffix exposure, and the interesting part is what happens
after login: the final redirect is
`https://app.example.com/callback/evil?code=...&session_state=...`, i.e. the
originally authorized URI, so the re-validation on the way out holds. You get
the looseness you configured, and no more.

**The practical consequence:** "wildcard redirect URI" in Keycloak is a
path-suffix feature, not a host-suffix one. A host wildcard in a client config
is worse than no wildcard, because it looks like a broad-but-intended
permission while actually rejecting everything, which tends to get "fixed"
later by someone pasting in a real wildcard or a bare-domain registration.

### 2. PKCE is off until you turn it on

Out of the box, an authorization request with **no `code_challenge` at all**
was accepted: `200`, straight to the login page.

Flipping one per-client attribute (`pkce.code.challenge.method=S256`) changed
that immediately and cleanly:

```
no code_challenge:
  302 Location: https://app.example.com/callback?error=invalid_request
                &error_description=Missing+parameter%3A+code_challenge_method
with a valid S256 challenge:
  200 login page
```

So enforcement works, it's just opt-in. If you're auditing a deployment rather
than configuring one, "does it enforce PKCE" is a client-by-client question,
not a version question, and the default answer is no.

### 3. Evil siblings and query injection are dead on arrival

Under exact matching, the classic tricks all failed:

```
https://app.example.com.evil.test/cb          -> 400
https://evil-app.example.com/cb               -> 400
https://app.example.com/callback/evil         -> 400
https://app.example.com/callback?next=//evil.test -> 400
```

No prefix matching, no suffix matching, no "the base domain is in there
somewhere". And the validation is identical whether you ask for `code` or
`token`, so enabling the implicit flow doesn't quietly change the rules:

```
response_type=token, redirect_uri=https://evil.example.com/cb -> 400
response_type=code,  redirect_uri=https://evil.example.com/cb -> 400
```

Scopes are similarly unforgiving: one unknown scope kills the whole request
with `invalid_scope` rather than being silently dropped:

```
scope=openid                    -> 200
scope=openid profile            -> 200
scope=idm:*                     -> 302 error=invalid_scope (Invalid scopes: idm:*)
scope=openid idm:* bogus_scope  -> 302 error=invalid_scope
```

That last line is the behaviour you want. Silent scope drop is how you end up
with a token that's narrower than the application believes it is.

## The headline

**Stock, nothing configured:**

- Exact `redirect_uri` matching. Evil siblings, trailing paths, and query
  injection all rejected.
- Unknown scopes rejected: no pass-through, no silent narrowing.
- PKCE **not** enforced.
- Trailing path wildcard (`/*`) is supported. Host wildcards are not, and
  the pattern is stored anyway.

**Requires explicit configuration, which means it requires explicit review:**

- PKCE enforcement (`pkce.code.challenge.method=S256`, per client).
- Path wildcard redirects, which enable path-suffix abuse.
- The implicit flow, which must be deliberately enabled.
- Anything that would let `scope=idm:*` through.

## Takeaways

- **Test the default, don't quote it.** Every one of these behaviours took
  minutes to determine and two of them contradicted what I'd have written down
  from memory.
- **Host wildcards in Keycloak are a trap.** They're accepted, stored, and
  useless. If you review configs for a living, that's a finding in itself.
- **PKCE's default matters for audits.** "Modern Keycloak" does not mean "PKCE
  enforced": it's a per-client attribute.
- **Label your evidence.** Calling every result `Observed` and refusing to
  generalise kept me honest about the three or four things I genuinely didn't
  test.

If you want to reproduce any of this, it's a stock container and
`http://127.0.0.1:8081`. I kept the lab around for exactly that reason.
