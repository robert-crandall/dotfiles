---
name: notify-slack
description: Send a Slack message to notify the user that a long-running task has completed. Use after PR creation, CI watching, bulk operations, large refactors, or any task that may take a while.
allowed-tools: Bash(~/repos/dotfiles/zsh/notify-slack.sh:*)
---

# Notify Slack Skill

Send a Slack message to notify the user that a long-running task has completed.

## When to use

After completing any task that may take a while - PR creation, CI watching, bulk operations, large refactors, etc. - run this to ping Slack so the user doesn't have to watch the terminal.

## How to invoke

Run the notification script from the dotfiles repo:

```bash
~/repos/dotfiles/zsh/notify-slack.sh "Your message here"
```

Example messages:
- `"PR #123 created and CI is passing"`
- `"Refactor of auth module complete - 14 files changed"`
- `"manage-pr: All review threads resolved, waiting on re-review"`

## Setup (one-time, user must do this)

The script reads the webhook URL from `~/.dotfiles-secrets`. That file is never committed.

Create it once:

```bash
echo 'export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..."' > ~/.dotfiles-secrets
chmod 600 ~/.dotfiles-secrets
```

If `SLACK_WEBHOOK_URL` is already exported in the shell environment, the secrets file is not needed.

## Notes

- If the webhook URL is missing, the script exits with an error and prints setup instructions - do not retry, just let the user know.
- The script exits non-zero on failure; treat that as a non-fatal warning unless the user specifically asked for guaranteed notification.
