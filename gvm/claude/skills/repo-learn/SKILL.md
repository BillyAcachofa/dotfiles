---
name: repo-learn
description: Learn about a repo by reading recent PRs from GitHub and updating work-brain repo knowledge notes.
user_invocable: true
---

# Repo Learn

Read recent merged PRs for a repo and update work-brain's understanding of what the repo does and how it works.

## Arguments

- `/repo-learn` — use the current working directory's GitHub repo, last 7 days
- `/repo-learn 2 weeks` — current repo, last 2 weeks
- `/repo-learn brightnetwork/bright-apply` — specific repo, last 7 days
- `/repo-learn brightnetwork/bright-apply 2 weeks` — specific repo, custom window

## Steps

### 1. Determine repo and timeframe

**Repo:** If no repo argument, detect from the current directory:

```bash
gh repo view --json nameWithOwner --jq '.nameWithOwner'
```

**Timeframe:** Default to 7 days. Parse relative timeframes ("2 weeks", "1 month") into a date range. Calculate the start date from today.

### 2. Fetch merged PRs

```bash
gh api search/issues --method GET --paginate \
  -f q="type:pr repo:${OWNER}/${REPO} is:merged merged:>=${START_DATE} -author:app/dependabot -author:app/renovate" \
  -f per_page=100 \
  --jq '.items[] | {
    number: .number,
    title: .title,
    body: .body,
    user: .user.login,
    url: .html_url
  }'
```

If there are no results, say so and stop.

### 3. Read PR descriptions and triage

For each PR, read the title and description. Group them by area of the codebase they touch (you'll usually be able to tell from titles and descriptions alone).

For PRs where the description is thin or the change sounds significant, fetch more detail:

```bash
gh api repos/${OWNER}/${REPO}/pulls/${NUMBER} --jq '{
  title: .title,
  body: .body,
  changed_files: .changed_files,
  additions: .additions,
  deletions: .deletions
}'
```

For genuinely important or confusing changes, fetch the file list:

```bash
gh api repos/${OWNER}/${REPO}/pulls/${NUMBER}/files --jq '.[].filename'
```

Only fetch full diffs as a last resort for changes that seem architecturally significant but are unclear from everything else.

### 4. Identify knowledge areas

From the PRs, identify distinct areas of knowledge about the repo. These might be:

- **Purpose and domain** — what the repo is for, what business problems it solves
- **Architecture** — how it's structured, key patterns, service boundaries
- **Infrastructure** — how it's deployed, what cloud resources it uses
- **Data model** — key entities, relationships, storage
- **Integrations** — external services, APIs, message queues
- **Testing** — test strategy, what's well-covered, what isn't
- **Build and deploy** — CI/CD pipeline, release process
- **Conventions** — naming patterns, code organisation, tech choices

Not every PR run will touch all areas. Only update areas where you learned something new.

### 5. Update repo knowledge notes

Notes live in `~/personal/work-brain/repos/<owner>-<repo>/` (hyphens, not slashes in the repo name — e.g. `repos/brightnetwork-bright-apply/`).

Create the directory if it doesn't exist.

For each knowledge area identified:

1. **Check for an existing note** at `repos/<owner>-<repo>/<area>.md`. If it exists, read it.
2. **Update or create** the note. Merge new information with existing content — don't just append, restructure if needed so the note reads coherently.

Repo knowledge notes use this frontmatter:

```yaml
---
title: "<repo> — <area>"
date: YYYY-MM-DD
type: repo-knowledge
repo: owner/repo-name
area: architecture | infrastructure | data-model | integrations | testing | build-deploy | conventions | purpose
last_reviewed: YYYY-MM-DD
pr_sources:
  - "#123 — Short PR title"
  - "#456 — Another PR title"
---
```

Update `last_reviewed` and append to `pr_sources` each time. Keep `pr_sources` trimmed to the last ~20 entries so it doesn't grow forever.

### Writing style for repo knowledge notes

- Write as if explaining the repo to a new team member who'll be working on it next week
- Be concrete — name the actual services, tables, endpoints, not vague descriptions
- Structure with headings within the note if the area is complex
- Note uncertainty: "seems to be X based on PR #123" is fine — these notes evolve
- When something changes (e.g. a migration from X to Y), note both the current state and the transition if it's still in progress

### 6. Commit and push

Stage all changes in the work-brain repo. Commit following the `commit-style` skill with a message like:

```
Update brightnetwork/bright-apply repo knowledge from recent PRs
```

Push to origin. Use `git -C ~/personal/work-brain` if not already in that directory.

### 7. Report

Output a brief summary of what was learned:
- How many PRs were reviewed
- Which knowledge areas were created or updated
- Any notable changes or patterns spotted

## Important

- **Descriptions first, code second.** Most understanding comes from PR descriptions and titles. Only dig into code when something is unclear or architecturally significant.
- **Don't over-index on dependency bumps or trivial fixes.** They don't tell you much about the repo.
- **Merge, don't replace.** Existing knowledge should be preserved and refined, not overwritten with just what you learned from this week's PRs.
- **One area per file.** Keep notes atomic by topic so they're easy to find and update independently.
- **Use `--jq` for all data formatting.** Do not pipe `gh` output through python, awk, or other processors — use the `--jq` flag on `gh api` calls to shape output directly. This keeps bash commands predictable and avoids permission prompts.
- **No shell loops.** Do not wrap `gh` commands in `for`/`while` loops — each `gh api` call must be its own Bash tool invocation so it matches the pre-authorized permission pattern `Bash(gh api *)`. Use parallel Bash tool calls to fetch multiple PRs at once instead of a loop.
