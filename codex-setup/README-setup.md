# Oracle Codex Setup For Another Windows PC

This folder makes the modified Oracle checkout usable from another Windows Codex environment.

## What This Installs

- Builds this local modified Oracle checkout.
- Links the `oracle` command to this checkout with `npm link`.
- Replaces `%USERPROFILE%\.codex\skills\oracle` with this repo's `skills/oracle`.
- Appends the Oracle routing guardrail to `%USERPROFILE%\.codex\AGENTS.md`.
- Creates `%USERPROFILE%\.oracle\config.json` for browser mode.

It does not copy browser cookies, ChatGPT sessions, passwords, API keys, or `%USERPROFILE%\.oracle\browser-profile`.

## Use From Another PC

After cloning the public repo:

```powershell
cd $env:USERPROFILE\source\repos\oracle
powershell -NoProfile -ExecutionPolicy Bypass -File .\codex-setup\install-windows.ps1
```

Then run one Oracle browser command and sign into ChatGPT if the Oracle browser profile asks.

## Optional Project Conversation Reuse

To make one project reuse one existing ChatGPT conversation:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\codex-setup\install-windows.ps1 `
  -ProjectPath "C:\path\to\project" `
  -ConversationUrl "https://chatgpt.com/c/<thread-id>"
```

Use a different ChatGPT conversation URL for a different project.

## What To Avoid

- Do not run `npx -y @steipete/oracle` for normal Codex use; it can bypass this modified checkout.
- Do not commit `.oracle/`, browser profiles, cookies, `.env`, or API keys.
- Do not reuse one project's ChatGPT conversation for a different project unless that is intentional.
- Do not click ChatGPT's stop/回答停止 button or send extra follow-up questions when an answer looks frozen or too short. Wait, refresh/reload, and re-read the same conversation instead.
