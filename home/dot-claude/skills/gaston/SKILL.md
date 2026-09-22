---
name: gaston
description: >-
  Hand off an agreed implementation plan to Gaston (our in-house AI implementer) via Linear.
  Use after planning a task together when the operator says "gaston it", "hand this to gaston",
  or "/gaston". Serialises the agreed plan into a Linear issue in the Tech & Product team,
  assigns it to the Gaston user and sets it to Todo (Gaston's pickup trigger), and embeds a
  handover protocol: Gaston Slack-DMs the operator on pickup and completion, and returns a PR
  with the operator added as both reviewer and assignee.
---

# Gaston handover

Gaston is our in-house AI assistant. It is strong at implementation but weaker at planning, so
the intended division of labour is: **plan with Claude, then hand the finished plan to Gaston.**
Gaston watches Linear and picks up issues that are **assigned to it and in `Todo`**. This skill
turns the plan we just agreed in this conversation into exactly such an issue.

The operator has opted into **fire immediately** — do **not** show a preview or ask for
confirmation before creating the issue. Assemble it and create it. Report the issue URL afterward.

## Preconditions

Run this only when there is a concrete, agreed plan in the current conversation. If the plan is
still vague or unresolved, stop and say so — Gaston needs a clear spec, not a half-formed idea.
Do not invent scope that wasn't discussed.

## Known Linear identifiers

Verify these still resolve before use (Gaston may have been re-provisioned, statuses renamed). If
any lookup fails, re-discover with `list_users` / `list_teams` / `list_issue_statuses`.

- **Team — Tech & Product**: `21b4d81b-846d-48a3-b45b-431e7e3c9efc` (EMP prefix)
- **Gaston user (assignee / pickup trigger)**: `4f1cef64-5012-4602-b75d-32505223fcc5` (`gaston@p9f.fr`)
- **`Todo` status**: `9ee3cb37-95c9-4936-81d8-36774c4688e3`
- **`Ready for Test` status** (where Gaston parks completed work): `bba9e33f-c464-4c5f-b5d6-835bafdf78b1`

## Steps

1. **Resolve the operator identity.** This is the human running the skill — the person Gaston
   reports back to. Get their email from `git config user.email`, then:
   - Linear user: `list_users` with `query: <email>` → capture the user id and display name. This
     is who the PR gets assigned to / review-requested from.
   - Slack handle: `slack_search_users` with the email or name → capture their `@handle` / member
     id. Bake the concrete handle into the handover block so Gaston has no ambiguity about who to DM.
   - If either lookup fails, fall back to the name/email and say so in the ticket.

2. **Assemble the plan from the conversation.** Pull together everything we agreed: the goal and
   *why*, the concrete approach, the files/areas involved, edge cases discussed, and acceptance
   criteria. Write it as a spec Gaston can execute without re-planning. Be specific — name files,
   functions, and expected behaviour. Do not pad with generic advice Gaston already knows.

3. **Create the issue** with `save_issue`:
   - `team`: Tech & Product id above
   - `assignee`: Gaston user id above
   - `state`: `Todo` id above (this is the pickup trigger — only set Todo when the plan is truly
     ready; use `Backlog` if you ever need to stage without triggering)
   - `title`: a single concise sentence describing the outcome (sentence case, no ticket prefix)
   - `description`: the body template below
   - Add labels if obviously applicable (e.g. `Technical`, `Screening`, `Voice`) — optional.

4. **Report back** to the operator with the created issue's identifier and URL. Done.

## Issue body template

This body is the **contract** Gaston reads. Fill the bracketed sections from the conversation;
keep the `## Handover protocol` section verbatim (substituting the resolved operator identity).

```markdown
> Handover from a planning session with Claude. Implement per the spec below, then follow the handover protocol at the bottom.

## Goal
[One-paragraph statement of what we want and **why** it matters.]

## Context
[Background needed to do this correctly: current behaviour, relevant constraints, related prior work, links.]

## Plan
[The agreed implementation approach, as concrete ordered steps. Name the files/functions to touch and the expected change in each.]

## Files / areas involved
- [path — what changes here]
- ...

## Acceptance criteria
- [Observable outcome 1]
- [Observable outcome 2]
- ...

## Testing
- [How to verify this change, appropriate to the repo and task — e.g. type check, lint, the relevant test command, a manual flow, bot run, or screening check. Only list what's actually useful here; don't prescribe checks that don't fit.]

## Handover protocol (please follow exactly)
1. **On pickup**: move this issue to **In Progress** and send a Slack DM to **[operator name / @handle]** acknowledging you've started, e.g. "Picking up <ISSUE-ID>: <title>."
2. **Implement** on a branch off `main` with small, well-described commits (repo conventions live in `AGENTS.md`).
3. **Open a draft PR** against `main` with a concise title and a short why-led description. On that PR, **request review from [operator @github] AND add them as assignee**.
4. **On completion**: move this issue to **Ready for Test**, **reassign the issue to [operator name / @handle]** (so it lands back with the requester), and send a Slack DM to **[operator name / @handle]** with the PR link, e.g. "Finished <ISSUE-ID> — PR: <url>."
5. **Deviations**: if you must depart from the plan, do it, but leave a Linear comment explaining what changed and why.
6. If you cannot send a Slack DM for any reason, post the pickup/completion notes as a Linear comment that **@mentions [operator]** instead.
```

## Notes

- The PR returns with the operator as **both reviewer and assignee**, and the Linear issue is **reassigned to the operator** on completion (their chosen handoff).
- Slack DM is the operator's preferred acknowledgement channel; the Linear-comment fallback in
  step 6 only triggers if Gaston genuinely can't DM.
- This skill never pushes code or opens PRs itself — it only files the Linear handover. Gaston
  does the implementation and the PR.
