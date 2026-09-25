## Writing prose

- **Never** use "load-bearing" as a metaphor. It applies to walls and beams, not
  to code, config, SHAs, assumptions or arguments. Say "important" — it does the
  job without the affectation. Applies everywhere: docs, commit messages, code
  comments, PR descriptions and chat.

## Writing code

- Do not add lengthy comments explaining what code does.
- Comments added should explain reasons that would not be obvious from reading the code
- Respect existing comments - only remove them if your change means they're no longer true or relevant

## Screenshots

- Save screenshots to `~/screenshots/`, not to project directories or /tmp.
- Group them in a task-specific subdirectory, e.g. `~/screenshots/<task-slug>/` (use the ticket id or a short descriptive slug). Don't dump loose files directly in `~/screenshots/`.

## Running code

- please use 'docker compose' instead of docker-compose
- Worktrees are isolated environments for separate tasks. Never use resources (databases, containers, ports) from one worktree in another. Only use the DB/services running for the current checkout.
- When agents need to run git commands in a directory that is NOT their current working directory, use `git -C /path` instead of `cd /path && git`. This avoids requiring user approval for every `cd` command. If the repo is already the working directory, just run `git` directly.
- **Don't run the full test suite locally before pushing.** Run the tests for the code you changed, plus typecheck and lint, then push and let CI run the full suite. Never hold up a push or PR waiting on a full local run. If a local run fails in files you didn't touch, treat it as environmental and move on rather than re-running to prove it. Only run the full suite locally when asked or when CI fails in a way that points at your change.

## Version control

- **Before writing any code**, check you are on an appropriate branch. If you need a new branch, create it from main (or the correct base) first. Never make changes on an unrelated branch.
- Always follow the `commit-style` skill when creating git commits.
- Always use the `pr` skill when creating pull requests.
- **Never rewrite shared history.** Once a commit has been pushed, add new commits rather than amending it. Amending or rewording local, unpushed commits is fine. Preserving individual commit history is preferred over a clean single commit. Force push should only be used for rebasing.
- If you encounter SSH permission errors when accessing GitHub (e.g. `git@github.com: Permission denied (publickey)`), stop immediately and ask the user to add the SSH key. You cannot do this yourself — it requires a password you don't have access to.
- When creating git worktrees, always use flat directory names — no slashes. Flatten branch names with dashes, e.g. `../repo_worktree_feature_branch-name` not `../repo_worktree_feature/branch-name`.

## Work Brain — knowledge capture

- A zettelkasten-style knowledge base lives at `~/personal/work-brain/`.
- **You MUST proactively write work-brain notes. Do not wait to be asked.** This is as important as committing code.
- **When working on a Linear ticket**: create or update `journal/tasks/<ticket-id>.md` at the start of the task. Record decisions, PR numbers, gotchas, and anything someone picking this up later would need. Update it as you go.
- **When working without a ticket**: create `journal/adhoc/<YYYY-MM-DD-descriptive_name>.md` for anything worth remembering — debugging sessions, architectural decisions, tool patterns, non-obvious gotchas.
- Read the `CLAUDE.md` in that repo for frontmatter format and guidelines.
- You can write to work-brain from any project — use `git -C ~/personal/work-brain` for git operations and absolute paths for file writes.
- Commit and push notes as you go. Use the commit-style skill. These are low-stakes commits — don't overthink them.
- The `learning/` directory contains distilled notes; don't write there directly during normal work — a periodic skill handles that.

## Remote operations

- **Only the `gitops` agent is allowed to push to remote repositories or open pull requests.** No other agent (developer, qa, engineering-manager, or the orchestrator) may run `git push`, `gh pr create`, or any command that writes to a remote.
- When you need to push a branch or open a PR, always delegate to the `gitops` agent. Pass it the worktree path, branch name, and desired action.
- **You MUST NOT create a PR without using the `pr` skill, and the `gitops` agent must follow the `commit-style` skill for any commits.** Both skills are declared in the gitops agent's frontmatter, so it can invoke them itself — do not paste the skill files into the prompt. Just remind gitops in the delegation prompt that the `pr` and `commit-style` skills apply, and never invent your own PR title/body or commit message format.
- The `gitops` agent will review commit quality before pushing and will reject branches with poor commit messages.
- **Before opening a PR against main**, the gitops agent must fetch `origin/main` and check whether the branch conflicts with it. Being behind main is fine on its own and not worth mentioning; only reject and ask for a rebase if there are conflicts.
- **When pushing further changes to an existing PR**, the gitops agent (or orchestrator) must review the PR description and update it if anything is now stale or inaccurate. Rebases, resolved conflicts, and merged dependencies can all invalidate earlier descriptions.

