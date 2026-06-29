## Oracle OSS GPT routing guardrail

- GPT/ChatGPT consultation from Codex should use the modified local Oracle OSS browser workflow by default.
- Use the installed local `oracle` command with `--engine browser`, project-specific `.oracle/config.json` `browser.conversationUrl`, and `--model <name>` when the user specifies a model.
- Do not use `npx -y @steipete/oracle` for normal runs because that can bypass this local modified checkout.
- Do not use old ChatGPT/CDP helper notes, Brave profile memories, normal browser profile hacks, or manual ChatGPT copy/paste workflows as the default GPT route.
- Use API mode only when the user explicitly asks for API or the Oracle browser route is blocked and the user approves the cost/risk.
- Never click ChatGPT's stop/回答停止 control while Oracle is waiting for an answer. If a ChatGPT answer looks frozen or too short, wait longer or refresh/reload and re-read the same conversation; do not send an extra follow-up/question as recovery.
