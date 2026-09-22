---
name: stacked-prs
description: How to build, extend, and fix stacked PRs using GitHub CLI's own `gh stack` extension. Applied automatically whenever the user asks for "stacked PRs" or work is being organised as a PR stack.
user_invocable: true
allowed-tools: Bash
---

# Stacked PRs

"Stacked PRs" means GitHub CLI's own `gh stack` extension. It does **not**
mean manually chaining branches with `gh pr create --base <branch>`, and it
does not mean hand-rolled `git rebase --onto` across multiple branches. If
you find yourself typing either of those for stack work, stop — there is a
`gh stack` command that does it properly. Run `gh stack --help` (or
`gh stack <subcommand> --help`) and use the real one instead of improvising.

## Starting a stack

```bash
gh stack init <branch1> [branch2 ...]   # creates/adopts branches bottom-to-top off the default branch
gh stack init --base develop <branch>   # ...or off a different trunk
```

## Adding a PR to the top of the current stack

```bash
gh stack add <new-branch>               # creates the branch on top of current HEAD
gh stack add -Am "commit message" <new-branch>   # ...and commits staged changes in one step
```

## Adding a PR to an *existing* stack (already has open PRs on GitHub)

Don't reconstruct anything. Use the shortcut built for exactly this:

```bash
gh stack link <stack-number> <branch-or-pr> [<branch-or-pr>...]
```

This appends to the top of that stack and **never removes existing PRs**.
Works from anywhere, whether or not the stack is checked out locally.

## Inserting a commit partway through a stack

You do **not** need to manually rebase every branch above it. Land the
commit on the branch it belongs to, then let `gh stack` cascade it upward:

```bash
git checkout <branch-partway-up-the-stack>
git commit -m "..."
gh stack sync          # fetch, cascade-rebase every branch above it, push, re-link PRs
```

If `sync` hits a real conflict it aborts cleanly (nothing half-pushed) and
tells you to run `gh stack rebase` — which supports `--continue`/`--abort`
for resolving it interactively, still as part of the managed cascade, not as
an ad-hoc rebase you're conducting by hand.

Useful variants:
- `gh stack rebase --downstack` / `--upstack` — limit the cascade direction from the current branch.
- `gh stack push` — push without touching PRs (no creation/linking).
- `gh stack submit` — push **and** create/update PRs (opens an editor for titles/bodies; `--auto` skips it, but see the PR-body gotcha below).
- `gh stack checkout <stack-number | pr-number | branch>` — adopt/switch to a stack locally, discovering it from GitHub if needed.

## Known hard limit — merged branches are a wall

If a repo deletes branches on merge (common default), a PR whose branch is
already merged-and-deleted **cannot** be re-added to that stack later — gh
stack requires each PR's base ref to equal the *still-existing* head branch
of the PR below it. An open PR can sit quite happily on top of merged
history it was already linked to (its base just auto-retargets to the
trunk when the branch below it disappears) — but you cannot pull it back out
and re-link it once removed. If you hit this, the correct outcome is a new
stack number for the remaining open work; that is not a bug or something to
route around. `gh pr view <n>` and `git ls-remote origin 'refs/heads/*'` will
confirm this in seconds if you suspect it.

## Also follow

- `commit-style` for every commit.
- `pr` for title/description conventions — note that `gh stack submit --auto`
  seeds PR bodies from the commit message, which then need replacing with the
  `pr` skill's placeholder body by hand.

## If something doesn't work the way you expect

**Ask. Do not invent an explanation and then "fix" it.** A command failing
or refusing something is not evidence of a platform limitation — it's
evidence you reached for the wrong `gh stack` subcommand, or that something
upstream (a merge, a deleted branch, a stale local stack) changed underneath
you. Before taking any destructive or hard-to-reverse action (unstacking,
rebuilding a stack, force-pushing broadly, closing PRs, resurrecting deleted
branches):

1. Read the actual error and the relevant `--help` output.
2. Check whether the same thing already worked earlier in this session — if
   so, your explanation for why it "can't" work now is probably wrong.
3. If you're still not certain what the right move is, say so and ask,
   rather than picking a workaround and presenting it as the only option.
