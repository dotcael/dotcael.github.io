# dotcael.github.io

Personal blog — software engineering and security notes.
Chirpy (Jekyll) theme, hosted free on GitHub Pages, deployed by GitHub Actions
on every push to `main`.

Live: https://dotcael.github.io

---

## The three commands you'll actually use

```bash
bin/new guides "What a stock OAuth server actually accepts"   # start a post
bin/serve                                                     # preview at localhost:4000
bin/publish --consent --disclosed-on 2026-10-19                 # make it live
```

`bin/publish` runs the disclosure gate first. If the gate isn't open, nothing
is committed and nothing is pushed. That's the whole safety model.

---

## Writing a post

**1. Create it**

```bash
bin/new <category> "The Title You Want"
```

Categories are fixed: `Guides` · `Notes` · `Opinion` · `Writeups`.
This creates `_posts/2026-10-19-the-title-you-want.md` from a template with the
front matter already filled in and the gate set to `draft`.

**2. Write it**

```bash
bin/serve        # http://127.0.0.1:4000 — saves trigger a reload
```

Plain markdown. Two things worth knowing:

- The **filename is the URL**. `_posts/2026-10-19-foo.md` → `/posts/foo/`.
  Pick it once; renaming later breaks every existing link.
- The date in the filename is the publish date. Future dates stay unpublished
  until that day arrives.

**3. Publish it**

```bash
bin/publish --consent --disclosed-on 2026-10-19
```

`--consent` opens the gate; `--disclosed-on` is the date publication was
permitted (today, for a non-engagement post). Add `--wait` to watch the deploy
finish. Live in about a minute.

---

## Embargoed work

Anything that touches a live program, a target, or an unreleased finding goes
here instead:

```bash
bin/new --draft notes "Something I can't publish yet"
```

- `_drafts/` is **git-ignored**. It never enters the repo, so it can never enter
  the git history, and it can never be published by accident.
- `bin/serve` shows drafts (only locally). `bin/serve` is the only place they
  appear.
- When it's cleared:

```bash
bin/publish --from-draft something-i-cant-publish-yet --consent --disclosed-on 2026-11-02
```

**Read `DISCLOSURE.md` before you publish anything that came out of a hunt.**
The short version: git history is forever, so a mistake pushed for five minutes
is a mistake published forever.

---

## Images

```bash
mkdir -p assets/img/my-post-slug
cp ~/Desktop/shot.png assets/img/my-post-slug/
bin/scrub assets/img/my-post-slug/shot.png    # strips EXIF — needs: brew install exiftool
```

Then in the post:

```markdown
![screenshot](/assets/img/my-post-slug/shot.png)
```

The `image:` key in the front matter is what produces the big preview card on
the homepage. **Look at every screenshot with your own eyes.** Metadata is not
the only thing images leak — hostnames, usernames, and browser profiles are.

---

## Categories and tags

- **Categories** (front matter, exactly one per post): `Guides`, `Notes`,
  `Opinion`, `Writeups`. These are the four pages under `/categories/`.
- **Tags** (front matter, as many as you like): free-form, and specific.
  Run `bin/tags` to see what exists before inventing a new one, so you don't end
  up with both `bugbounty` and `bug-bounty`.

`Writeups` stays invisible until the first disclosed finding lands in it.

---

## Changing the site itself

| What | Where |
|---|---|
| Title, tagline, description | `_config.yml` (top) |
| Email, social links | `_config.yml` → `social:`, and `_data/contact.yml` |
| Share buttons at the bottom of posts | `_data/share.yml` |
| About page | `_tabs/about.md` |
| Disclosure policy page | `_tabs/disclosure.md` |
| Adding a new tab | new file in `_tabs/` with `icon:` and `order:` |
| Dark/light default | `_config.yml` → `theme_mode:` |
| Posts per page | `_config.yml` → `paginate:` |

Everything is a one-line edit, then `bin/publish`.

---

## Analytics — GoatCounter

Free, cookieless, no banner needed.

1. Sign up at https://www.goatcounter.com/signup
   - **Account name**: `dotcael` → your dashboard is `dotcael.goatcounter.com`
     and this exact string goes in `_config.yml` → `analytics.goatcounter.id`.
   - **Site domain**: `dotcael.github.io` — display only, used for links, not
     for filtering.
2. Already wired in `_config.yml` as `id: dotcael`. If you picked a different
   account name, change that one line.
3. Stats appear at `dotcael.goatcounter.com` a few minutes after the next deploy.

---

## Comments — giscus

Backed by GitHub Discussions on this repo. Two repos' worth of setup, one command:

```bash
bin/setup-giscus      # enables Discussions, reads the IDs, patches _config.yml
bin/publish --wait    # deploy it
```

Anyone with a GitHub account can then comment. To moderate: the Discussions tab
on the repo — comments are just discussions, so deleting one there deletes it
from the site.

---

## Troubleshooting

**The build failed (red X on GitHub)**
Run `bin/check` locally — it does the same build plus a link check and prints
the real error. Usual causes: a typo in the front matter, an unclosed code
fence (```), or a link to a page that doesn't exist.

**A post is published but I still see the old version**
Chirpy installs a PWA service worker, which caches aggressively. Hard-reload
(⌘⇧R), or check in a private window. First-time visitors are unaffected.

**I renamed a post file and now links 404**
The filename is the URL, so the old URL is gone. Rename it back, or accept the
break. To keep old links working you'd need a redirect, which this theme
doesn't do out of the box.

**Preflight says "denylist hit"**
A term in `~/Developer/writing/denylist.txt` appears in the post. Either the
post shouldn't be published yet, or the term is a false positive — edit the
denylist if so.

**`bundle install` fails**
Needs Ruby (3.1+). `brew install ruby` if missing. On this Intel Mac, Ruby 4.0.6
works.

---

## Writing from the PC

The repo is Syncthing-synced to the PC, so you can *write* anywhere. Publish
from the Mac:

- Jekyll on Windows is painful — don't try to build there.
- **Only one machine should commit at a time.** If both do, Syncthing creates
  `*.sync-conflict-*` files. Git conflicts are the one thing this setup makes
  worse, not better.
- Writing from a phone or a machine without the repo: edit the post in GitHub's
  web UI and commit. CI's disclosure gate still runs, so a structural mistake
  can't go live.

---

## Files

```
_config.yml          everything configurable
_tabs/               the pages in the top nav (about, disclosure, …)
_posts/              published posts — filename = URL
_drafts/             GIT-IGNORED — embargoed work, never published
_templates/post.md   the template bin/new copies
bin/                 the commands in this README
assets/img/          post images
DISCLOSURE.md        the rules for publishing a finding (read this)
AGENTS.md            notes for future agent sessions
.github/workflows/   the deploy; you never need to touch it
```
