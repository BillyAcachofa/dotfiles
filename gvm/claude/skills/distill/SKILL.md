---
name: distill
description: Read journal notes in work-brain and extract useful learnings into atomic notes.
user_invocable: true
---

# Distill Learnings

Read recent journal notes from work-brain and distil reusable knowledge into the `learning/` directory.

## Arguments

Optional filter:

- `/distill` — process all un-distilled journal notes
- `/distill last week` — only notes from the past week
- `/distill journal/tasks/BN-1234.md` — distil a specific note

## Steps

### 1. Find journal notes to process

Scan `journal/tasks/` and `journal/adhoc/` in `~/personal/work-brain/` for markdown files.

Filter to notes where the frontmatter does **not** contain `distilled: true`. If an argument was passed, apply it as a date or path filter.

Read each candidate note.

### 2. Identify learnings

For each journal note, look for things that would be useful to know in a future, unrelated context:

- **Non-obvious behaviour** of tools, libraries, APIs, or infrastructure
- **Debugging patterns** — symptoms that point to a specific root cause
- **Architectural decisions** and the reasoning behind them
- **Gotchas and workarounds** — things that wasted time or were surprising
- **Useful commands, configs, or techniques** that aren't well-documented

Skip anything that is:
- Specific to only that one ticket with no general applicability
- Already well-known / easily searchable
- Already captured in an existing learning note (check first)

### 3. Create or update learning notes

For each learning identified:

1. **Check existing notes** in `learning/` — search by filename and tags. If a relevant note exists, update it rather than creating a duplicate.
2. **Create a new note** if no match. Use a descriptive filename: `learning/<topic>.md` (lowercase, hyphens, no dates).
3. Follow the frontmatter format from the repo's `CLAUDE.md`. Always include:
   - `source:` pointing back to the journal note(s) this came from
   - `repos:`, `tools:`, `tags:` carried over from the source where relevant

### Writing style for learning notes

- **Atomic**: one topic per note. If a journal entry yields three learnings, that's three notes.
- **Context first**: start with when/why you'd need this — the situation, not the solution.
- **Then the answer**: what to do, concretely. Include commands, config snippets, or code if they help.
- **Link the why**: if there's a reason it works this way (not just "do X"), explain briefly.
- **No fluff**: skip preamble, no "I learned that...", no "This is useful because...". Just the knowledge.

Example:

```markdown
---
title: ECS tasks need explicit log group creation before first deploy
date: 2026-03-12
type: learning
source:
  - journal/tasks/BN-892.md
repos:
  - brightnetwork/terraform-bright-apply
tools:
  - terraform
  - ecs
tags:
  - aws
  - ecs
  - logging
  - deploy
---

When adding a new ECS service, the CloudWatch log group must exist before
the task definition references it. Terraform creates them in parallel by
default, so the first deploy fails with "ResourceNotFoundException".

Fix: add an explicit `depends_on` from the task definition to the log group,
or use `aws_cloudwatch_log_group` with `retention_in_days` set (which
forces Terraform to create it as a tracked resource rather than letting
ECS auto-create it).
```

### 4. Update repo knowledge notes

If a journal note contains information specific to how a particular repo works — its architecture, deployment, data model, conventions, etc. — update the corresponding repo knowledge note in `repos/<owner>-<repo>/<area>.md`.

This is different from learning notes: learnings are general/transferable, repo knowledge is specific to that codebase.

1. Check the journal note's `repos:` frontmatter to identify which repos are involved.
2. For each repo, check if `repos/<owner>-<repo>/` exists. Create it if not.
3. Determine which area the knowledge falls into (architecture, infrastructure, data-model, integrations, testing, build-deploy, conventions, purpose).
4. Read the existing area note if it exists and merge the new information in. Create it if it doesn't exist.
5. Follow the repo-knowledge frontmatter format from the work-brain `CLAUDE.md`.

### 5. Mark journal notes as distilled

For each journal note you processed, add `distilled: true` to its frontmatter. This prevents re-processing on future runs.

If you only extracted some learnings and want to revisit later, leave it as `distilled: false` or don't add the field.

### 6. Commit and push

Stage all changes in the work-brain repo (new learning notes + updated journal frontmatter). Commit following the `commit-style` skill. Push to origin.

Use `git -C ~/personal/work-brain` if not already in that directory.

## Important

- **Don't force it.** If a journal note has nothing worth distilling, just mark it `distilled: true` and move on. Not every task produces a reusable learning.
- **Prefer updating over creating.** A learning note on "ECS deploy gotchas" that gains a new bullet is better than a second note on a closely related topic.
- **Keep learning notes evergreen.** If new information contradicts an existing note, update or replace it — don't just append.
