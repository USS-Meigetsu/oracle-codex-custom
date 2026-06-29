---
name: oracle
description: "Oracle second-model review: bundle prompts/files, debug, refactor, design-check."
---

# Oracle (CLI) — best use

Oracle bundles your prompt + selected files into one “one-shot” request so another model can answer with real repo context (API or browser automation). Treat outputs as advisory: verify against the codebase + tests.

## Main use case (browser, GPT‑5.5 Pro)

Default workflow here: `--engine browser` with GPT‑5.5 Pro in ChatGPT. This is the “human in the loop” path: it can take ~10 minutes to ~1 hour; expect a stored session you can reattach to.

Recommended defaults:

- Engine: browser (`--engine browser`)
- Model: GPT‑5.5 Pro (either `--model gpt-5.5-pro` or a ChatGPT picker label like `--model "5.5 Pro"`)
- Attachments: directories/globs + excludes; avoid secrets.
- Local policy: prefer the modified local Oracle browser workflow for GPT/ChatGPT second opinions. Do not use API mode unless the user explicitly asks for API or browser mode is blocked.
- CLI policy: use the installed local `oracle` command from the modified checkout. Do not use `npx -y @steipete/oracle` for normal runs because that can bypass local changes.
- Existing-chat policy: use project-specific `.oracle/config.json` `browser.conversationUrl` or `--chatgpt-conversation-url` when preserving context matters. Do not reuse one project's conversation URL for another project.
- Model policy: if the user names a model, pass it with `--model <name>` and use `--browser-model-strategy select` by default. Existing conversation reuse still honors model selection before submitting the prompt.

## Golden path (fast + reliable)

1. Pick a tight file set (fewest files that still contain the truth).
2. Preview what you’re about to send (`--dry-run` + `--files-report` when needed).
3. Run in browser mode for the usual GPT‑5.5 Pro ChatGPT workflow; use API only when you explicitly want it.
4. If the run detaches/timeouts: reattach to the stored session (don’t re-run).

## ChatGPT completion safety

- Never click ChatGPT's "Stop generating", "Stop responding", or Japanese "回答を停止" control during Oracle waits or recovery. Treat that control as evidence the answer may still be in progress.
- Do not send `--browser-follow-up` prompts, manual follow-ups, "continue?" prompts, or extra questions while the current answer may still be generating, frozen-looking, or suspiciously short.
- If the page appears stuck, first wait longer. If it still looks stale, refresh/reload the page and re-read the latest assistant response in the same conversation.
- Use browser follow-ups only when the user explicitly requested a planned multi-turn consult and only after the previous answer is verified complete.

## Commands (preferred)

- Show help (once/session):
  - `oracle --help`

- Preview (no tokens):
  - `oracle --dry-run summary -p "<task>" --file "src/**" --file "!**/*.test.*"`
  - `oracle --dry-run full -p "<task>" --file "src/**"`

- Token/cost sanity:
  - `oracle --dry-run summary --files-report -p "<task>" --file "src/**"`

- Startup/perf trace:
  - `oracle --perf-trace --perf-trace-path /tmp/oracle-perf.json --dry-run summary -p "<task>" --file "src/**"`
  - Use when CLI startup or time-to-first-output feels slow; inspect `first-output` and `exit`.

- Browser run (main path; long-running is normal):
  - `oracle --engine browser --model gpt-5.5-pro -p "<task>" --file "src/**"`

- Browser run that reuses a project-specific ChatGPT conversation:
  - `oracle --engine browser --chatgpt-conversation-url "https://chatgpt.com/c/<thread-id>" -p "<task>" --file "src/**"`
  - Prefer this when the user wants to preserve an existing ChatGPT thread's context. Use a different conversation URL per project. Oracle verifies prior turns before submitting and fails closed rather than silently creating a fresh chat.

- Preview bundle only (not a GPT submission route):
  - `oracle --render -p "<task>" --file "src/**"`
  - Use this only to inspect the assembled prompt. Submit through Oracle browser mode unless the user explicitly asks for manual copy/paste.

## Attaching files (`--file`)

`--file` accepts files, directories, and globs. You can pass it multiple times; entries can be comma-separated.

- Include:
  - `--file "src/**"` (directory glob)
  - `--file src/index.ts` (literal file)
  - `--file docs --file README.md` (literal directory + file)

- Exclude (prefix with `!`):
  - `--file "src/**" --file "!src/**/*.test.ts" --file "!**/*.snap"`

- Defaults (important behavior from the implementation):
  - Default-ignored dirs: `node_modules`, `dist`, `coverage`, `.git`, `.turbo`, `.next`, `build`, `tmp` (skipped unless you explicitly pass them as literal dirs/files).
  - Honors `.gitignore` when expanding globs.
  - Does not follow symlinks (glob expansion uses `followSymbolicLinks: false`).
  - Dotfiles are filtered unless you explicitly opt in with a pattern that includes a dot-segment (e.g. `--file ".github/**"`).
  - Default cap: files > 1 MB are rejected unless you raise `ORACLE_MAX_FILE_SIZE_BYTES` or `maxFileSizeBytes` in `~/.oracle/config.json`.

## Budget + observability

- Target: keep total input under ~196k tokens.
- Use `--files-report` (and/or `--dry-run json`) to spot the token hogs before spending.
- Use `--perf-trace` / `ORACLE_PERF_TRACE=1` for startup and first-output timing. Traces redact prompts, tokens, keys, cookies, and inline cookie payloads; detached API children write a session-suffixed sidecar trace.
- If you need hidden/advanced knobs: `oracle --help --verbose`.

## Engines (API vs browser)

- Auto-pick: uses `api` when `OPENAI_API_KEY` is set, otherwise `browser`.
- Browser engine supports GPT + Gemini only; use `--engine api` for Claude/Grok/Codex or multi-model runs.
- `--copy-profile <chrome-user-data-dir>`: reuse your **already signed-in** Chrome session with no manual login — copies the profile to a throwaway dir, launches with the real Keychain so its cookies decrypt, runs, then always deletes the copy. Failed/incomplete runs are deleted too, so they cannot be kept, reattached, or sent to an existing/remote browser. e.g. `oracle --engine browser --copy-profile "$HOME/Library/Application Support/Google/Chrome" -p "<task>"`. macOS/Linux; needs `rsync`.
- **API runs require explicit user consent** before starting because they incur usage costs.
- Browser attachments:
  - `--browser-attachments auto|never|always` (auto pastes inline up to ~60k chars then uploads).
  - Add `--browser-bundle-files --browser-bundle-format auto|zip` to upload many files as one bundle; ZIP bundles preserve original file bytes.
- Remote browser host (signed-in machine runs automation):
  - Host: `oracle serve --host 0.0.0.0 --port 9473 --token <secret>`
  - Client: `oracle --engine browser --remote-host <host:port> --remote-token <secret> -p "<task>" --file "src/**"`

## API preflight

- API runs require explicit user consent and cost money.
- Before API runs, check provider readiness without printing secrets:
  - `oracle doctor --providers --models gpt-5.4,claude-4.6-sonnet,gemini-3-pro`
  - `oracle --preflight --models gpt-5.4,gemini-3-pro`
  - `oracle --route --model gpt-5.4`
- If the user wants first-party OpenAI, pass `--provider openai` or `--no-azure`. This prevents exported Azure env/config from hijacking the route:
  - `oracle --provider openai --engine api --model gpt-5.5-pro ...`
- For advisory multi-model panels where partial success is useful, use `--allow-partial --write-output <path>` so successful model files and the `<stem>.oracle.json` manifest are easy to recover:
  - `oracle --models gpt-5.4,claude-4.6-sonnet,gemini-3-pro --allow-partial --write-output /tmp/panel.md -p "<task>"`
- `--timeout 10m` is the normal user-facing API deadline; Oracle derives the HTTP transport timeout unless `--http-timeout` is explicitly set.
- If the exported `OPENAI_API_KEY` is invalid and the user wants their personal OpenAI key, use `$one-password` in one persistent tmux session. Known item: `API Key - OpenAI - Personal`, field `api_key`. Inject only into the single Oracle command; never print the key:
  - `OPENAI_API_KEY="$(op item get 'API Key - OpenAI - Personal' --account my.1password.com --fields label=api_key --reveal)" oracle --provider openai --engine api --model gpt-5.5-pro ...`
- For debugging Oracle itself, prefer the local checkout after pulling `~/Projects/oracle`:
  - `pnpm -C ~/Projects/oracle run build`
  - `node ~/Projects/oracle/dist/scripts/run-cli.js ...`

## Sessions + slugs (don’t lose work)

- Stored under `~/.oracle/sessions` (override with `ORACLE_HOME_DIR`).
- Browser runs save durable files under `~/.oracle/sessions/<id>/artifacts/`, including `transcript.md`, Deep Research reports, and downloaded ChatGPT-generated images when available.
- Runs may detach or take a long time (browser/API + GPT‑5.5 Pro often does). If the CLI times out: don’t re-run; reattach.
  - List: `oracle status --hours 72`
  - Attach: `oracle session <id> --render`
- Use `--slug "<3-5 words>"` to keep session IDs readable.
- Duplicate prompt guard exists; use `--force` only when you truly want a fresh run.
- CLI guardrails: root runs without a prompt exit nonzero; `--dry-run` conflicts with `--render` / `--render-markdown`; Ctrl-C exits foreground API runs with code 130 while browser cleanup/reattach still runs.

## Prompt template (high signal)

Oracle starts with **zero** project knowledge. Assume the model cannot infer your stack, build tooling, conventions, or “obvious” paths. Include:

- Project briefing (stack + build/test commands + platform constraints).
- “Where things live” (key directories, entrypoints, config files, dependency boundaries).
- Exact question + what you tried + the error text (verbatim).
- Constraints (“don’t change X”, “must keep public API”, “perf budget”, etc).
- Desired output (“return patch plan + tests”, “list risky assumptions”, “give 3 options with tradeoffs”).

### “Exhaustive prompt” pattern (for later restoration)

When you know this will be a long investigation, write a prompt that can stand alone later:

- Top: 6–30 sentence project briefing + current goal.
- Middle: concrete repro steps + exact errors + what you already tried.
- Bottom: attach _all_ context files needed so a fresh model can fully understand (entrypoints, configs, key modules, docs).

If you need to reproduce the same context later, re-run with the same prompt + `--file …` set (Oracle runs are one-shot; the model doesn’t remember prior runs).

## Safety

- Don’t attach secrets by default (`.env`, key files, auth tokens). Redact aggressively; share only what’s required.
- Prefer “just enough context”: fewer files + better prompt beats whole-repo dumps.
