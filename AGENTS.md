# AGENTS.md: working notes for this repo

Context for any agent (or human) editing this blog. Read this first, then
`DISCLOSURE.md` if the task involves anything from a security engagement.

## What this is

A Chirpy (Jekyll) blog deployed to GitHub Pages via GitHub Actions.
Repo: `dotcael/dotcael.github.io` → https://dotcael.github.io
Operator: dotcael. Tone: measured, specific, anti-hype. No marketing voice.

## Commands

```bash
bin/setup                # bundle install into vendor/bundle (once)
bin/serve                # localhost:4000, live reload, INCLUDES _drafts
bin/new <cat> "Title"    # new post from _templates/post.md
bin/new --draft "Title"  # new draft in _drafts/ (git-ignored)
bin/preflight            # the disclosure gate (run by bin/publish + CI)
bin/publish [--consent --disclosed-on YYYY-MM-DD] [--wait]
bin/check                # build + htmlproofer, same as CI
bin/status               # published / gated / embargoed
bin/tags                 # existing tags, with counts
bin/scrub IMG...         # strip EXIF (needs exiftool)
bin/setup-giscus         # wire comments (needs the repo to exist)
bin/brief                # regenerate the claude.ai writing brief (paste-safe)
bin/draft                # clipboard -> _drafts/<slug>.md, front matter generated
```

## Chat-drafting lane (claude.ai)

The operator drafts in claude.ai; `bin/brief` and `bin/draft` are the bridge.

- `bin/brief` output MUST stay paste-safe: house rules, output contract, and
  the text of published posts only. Never emit the denylist, program names,
  target hosts, or anything from `_drafts/` into it. It leaves the machine.
- `bin/draft` may only write into `_drafts/`. If a change would let it write to
  `_posts/`, it is wrong; promotion stays a human `bin/publish --from-draft`.
- Generated front matter always arrives with `status: draft`,
  `program_consent: false`, empty `disclosed_on`, regardless of what the model
  returned. Do not make those fields model-controlled.

## Rules that are not negotiable

1. **Never commit anything from `_drafts/`.** It is git-ignored on purpose.
   A pushed-then-deleted file is still in the git history, forever. If a task
   asks you to publish embargoed material, stop and ask the operator.
2. **Every post in `_posts/` needs an open gate**: `disclosure.status: public`,
   `program_consent: true` (or `n/a` for a lab/guide post with no engagement),
   and a `disclosed_on` date. `bin/preflight` enforces it; CI enforces it
   structurally.
3. **Never edit `_config.yml` → `disclosure`-related behaviour away**, and don't
   loosen `bin/preflight` to make something publish. Fix the post instead.
4. **The blog is technical only.** No personal, political, or activist material,
   regardless of what's in the operator's other folders. This was an explicit
   decision.
5. **The denylist lives outside the repo**: `~/Developer/writing/denylist.txt`.
   Never copy it in, never print its contents into a commit or a log.

## Gotchas (learned the hard way)

- **This Ruby version rejects `cmd || die "msg"`** without parentheses (a bare
  string argument after `||` is a syntax error). Write `|| die("msg")`. Same for
  other bare-argument calls used inside expressions.
- **The filename is the URL.** `_posts/2026-10-19-foo.md` → `/posts/foo/`.
  Renaming breaks links permanently (no redirect support in this theme).
- **Ruby**: needs Ruby **3.1–3.x**. This Mac's default is 4.0.6, which the
  theme's gemspec *rejects* ("Ruby ~> 3.1 is required"). Use Homebrew
  `ruby@3.2`, prebuilt. `ruby@3.3`/`ruby@3.4` have no bottle for this
  macOS/Intel combo and compile OpenSSL from source (20+ min of full CPU); do
  not install those. `bin/*` scripts prepend a 3.x keg to PATH automatically.
  Gems install to `vendor/bundle` (git-ignored). CI pins 3.4 independently.
- **Bundler warning** "running version of Bundler does not match the version of
  the specification" is cosmetic here; builds still work.
- **CI does the real build.** A local build passing isn't proof; the deploy is.
  Use `bin/publish --wait` when you need certainty.
- **PWA service worker caches hard.** A published edit may not show up on a
  browser that already visited. Hard-reload or check in a private window.
- **README.md, AGENTS.md, DISCLOSURE.md, bin/ are excluded from the build** via
  `exclude:` in `_config.yml`. Don't remove those entries.
- **`bin/serve` writes drafts into `_site/`.** Serve builds with `--drafts` and
  uses `_site` as its destination, so the drafts you see locally are physically
  in `_site/`. That directory is git-ignored (no leak risk), but if you want a
  clean production build, run `bin/check`; Jekyll removes the stale files.
- **This repo is Syncthing-synced to the gaming PC.** Only one machine commits
  at a time, or you get `*.sync-conflict-*` files. Conflicts are the one thing
  the two-machine setup makes worse.
- **`~/Developer` is itself a bounding git repo** (nothing tracked, `*/`
  ignored) so opencode sessions there don't resolve the workspace root to `/`.
  This repo is a nested repo inside it, which is expected and fine.

## Style guide for posts

- Categories, one per post: `Guides`, `Notes`, `Opinion`, `Writeups`.
- Tags: specific and lowercase-hyphenated (`subdomain-takeover`, `keycloak`).
  Check `bin/tags` first.
- Open with the point, not with throat-clearing.
- Every command and output in a post must have been actually run. No recalled
  output, no invented terminal transcripts.
- Numbers and dates get verified against notes, not memory.
- Use `{: .prompt-warning }` and `{: .prompt-tip }` callouts for the things
  readers get wrong.
- Admitting a mistake in a post increases trust. Do it when it's real.
- Delete the comment block at the top of `_templates/post.md` before publishing.
