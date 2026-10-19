---
title: "__TITLE__"
date: __DATE__ 09:00:00 +0200
categories: [__CATEGORY__]
tags: []
description: >-
  One or two sentences. This is what shows up in link previews, the homepage
  card, and search results — write it last.
image: # /assets/img/POST-SLUG/preview.webp  (produces the homepage card image)
toc: true
comments: true
disclosure:
  status: draft # draft | embargoed | public   <- bin/preflight blocks anything not public
  program_consent: false # true (or n/a for a lab/guide with no engagement) before publishing
  disclosed_on: # YYYY-MM-DD, the date publication was permitted
---

<!--
=====================================================================
 BEFORE YOU PUBLISH — the checklist that actually matters
=====================================================================
 1. embargo: does this reference a live program, host, internal name,
    credential, or unreleased finding? If yes, it belongs in _drafts/.
 2. is this a WRITEUP (a finding) or a GUIDE/NOTE/OPINION (method)?
    Writeups need program_consent: true and a disclosed_on date.
 3. screenshots: strip EXIF (bin/scrub), and check nothing identifies a
    target, account, browser profile, or person.
 4. every command and output shown: did you actually run it? Don't ship
    remembered output.
 5. numbers and dates: verified against your notes, not memory.
 6. delete this comment block before publishing.
=====================================================================
-->

Open with the point. Why does this exist? What did you learn, and who cares?
Skip the throat-clearing — the reader already clicked.

## Background

What someone needs to know to follow the rest. Keep it tight; link out instead
of re-explaining well-covered ground.

## The details

The substance. For a guide: the steps, in order, with the actual commands. For
a writeup: what you observed, what you expected, and what it means.

```bash
# code blocks get line numbers, copy buttons, and syntax highlighting
curl -sS -D - -o /dev/null http://127.0.0.1:8081/example
```

> Use callouts for the things people get wrong.
{: .prompt-warning }

> And for the thing you'd tell a colleague over coffee.
{: .prompt-tip }

| Observed | Expected | Verdict |
|---|---|---|
| what happened | the hypothesis | pass / fail / unknown |

## What I got wrong

Optional, and the section most worth writing. A post that admits one mistake
reads as more trustworthy than one that doesn't.

## Takeaways

Three to five bullets. If you can't fill these, the post isn't finished.

- The thing that surprised me.
- The thing I'd do differently next time.
- The thing worth trying if you hit the same wall.
