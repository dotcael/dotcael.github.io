# DISCLOSURE.md: internal rules for this repo

This is the enforcement side of the public [/disclosure/](/disclosure/) page.
Read it before you commit anything that comes out of a bug bounty engagement.

## The one rule

**Embargoed work never enters this repository. Not in a commit, not in a branch,
not in a stash.**

This is not paranoia about the current state of the repo. It's about git: a file
committed and then deleted still exists in the history, in every clone that
happens to exist, and in any Actions artifact or fork that was ever created.
Deletion is not a rollback. There is no undo for "I pushed it for five minutes."

Practically: if a post references a live program, an internal hostname, a
program name, an unreleased finding, or a credential, it lives in `_drafts/`
(which is git-ignored) or in the private ideas ledger, never in `_posts/`.

## The gate

Every post carries this front matter:

```yaml
disclosure:
  status: draft          # draft | embargoed | public
  program_consent: false # has the program/vendor actually said yes?
  disclosed_on:          # YYYY-MM-DD publication was permitted
```

`bin/preflight` refuses to publish anything that isn't `status: public` with
`program_consent: true` and a `disclosed_on` date. CI enforces the same
structurally, so a mistake pushed from a browser can't reach the live site.

`status: public` is a claim that the following are *all* true:

1. The finding is resolved, dismissed as informational by the program, or past
   the program's stated disclosure window.
2. The program's disclosure policy permits publication, or explicit consent was
   given.
3. The post contains no target identifiers beyond what the policy allows.
4. Screenshots have been scrubbed of identifiers and EXIF data.

If you can't tick all four, the post stays in `_drafts/`. There is no partial
publish.

## The denylist

`bin/preflight` also greps every publishable post for terms that must never
appear: program names, internal hosts, target domains, contact addresses.

- **Location**: `~/Developer/writing/denylist.txt` (outside this repo, by
  design: it is not published and not synced into the site).
- **Format**: one term per line, case-insensitive substring match.
- **CI cannot see it** (it's local-only), so the denylist check runs in the
  local pre-push path. Do not bypass it.

## If something slips

1. Remove it, immediately, and publish the removal.
2. Tell the program. Before they find out. Programs forgive mistakes reported
   by the researcher; they do not forgive being surprised.
3. Write the lesson down in `AGENTS.md` so it doesn't recur.

The disclosure gate exists so that step 3 is the only one you ever need.
