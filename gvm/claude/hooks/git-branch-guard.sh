#!/usr/bin/env bash
# PreToolUse (Bash) hook: when a new branch is being created, verify the local
# default branch is not behind the remote before it becomes the new branch's
# base. If stale, ask for confirmation rather than silently branching off an
# out-of-date base. Non-branch commands pass through untouched.

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')

case "$cmd" in
  *"checkout -b"*|*"switch -c"*|*"checkout --branch"*|*"checkout -B"*) ;;
  *) exit 0 ;;
esac

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
git fetch --quiet origin >/dev/null 2>&1

def=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
[ -z "$def" ] && def="origin/main"
git rev-parse --verify --quiet "$def" >/dev/null 2>&1 || exit 0

localmain=${def#origin/}
git rev-parse --verify --quiet "$localmain" >/dev/null 2>&1 || exit 0
mb=$(git rev-list --count "$localmain..$def" 2>/dev/null || echo 0)

if [ "${mb:-0}" -gt 0 ]; then
  reason="Local '$localmain' is $mb commit(s) behind $def. Branching now starts from a stale base. Update it first (git checkout $localmain && git pull) or branch directly from $def, then retry."
  rjson=$(printf '%s' "$reason" | jq -Rs .)
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":%s}}\n' "$rjson"
fi
exit 0
