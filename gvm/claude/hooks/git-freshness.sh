#!/usr/bin/env bash
# SessionStart hook: fetch origin and report how far the current branch and
# local default branch are behind the remote default branch, so freshness is
# visible before any code is written or any code-based answer is given.
# Always exits 0 and never blocks startup.

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo '{}'; exit 0; }

git fetch --quiet origin >/dev/null 2>&1

def=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
[ -z "$def" ] && def="origin/main"
git rev-parse --verify --quiet "$def" >/dev/null 2>&1 || { echo '{}'; exit 0; }

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
behind=$(git rev-list --count "HEAD..$def" 2>/dev/null || echo 0)

localmain=${def#origin/}
mainmsg=""
if [ "$branch" != "$localmain" ] && git rev-parse --verify --quiet "$localmain" >/dev/null 2>&1; then
  mb=$(git rev-list --count "$localmain..$def" 2>/dev/null || echo 0)
  if [ "$mb" -gt 0 ]; then
    mainmsg=" Local '$localmain' is $mb commit(s) behind $def — update it before branching from it."
  fi
fi

if [ "${behind:-0}" -gt 0 ] || [ -n "$mainmsg" ]; then
  msg="Git freshness check: current branch '$branch' is $behind commit(s) behind $def.$mainmsg Confirm the checkout is current before writing code or answering based on it."
else
  msg="Git freshness check: '$branch' is level with $def."
fi

ctx=$(printf '%s' "$msg" | jq -Rs .)
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' "$ctx"
exit 0
