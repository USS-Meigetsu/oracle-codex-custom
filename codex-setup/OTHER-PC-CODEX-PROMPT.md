# Prompt To Use On Another Codex PC

Copy this request into Codex on the other Windows PC:

```text
GitHub private repo `USS-Meigetsu/oracle-codex-custom` から、改変済み Oracle OSS をこのPCへ導入して。

やってほしいこと:
- `gh auth status` を確認し、未ログインなら GitHub ログインだけ俺に依頼する。
- repo を `%USERPROFILE%\source\repos\oracle` へ clone する。既にあれば pull / fetch して最新化する。
- `codex-setup\install-windows.ps1` を実行して、依存関係、build、npm link、Codex skill配置、AGENTS.md追記、`%USERPROFILE%\.oracle\config.json` 作成まで自動でやる。
- `oracle --dry-run summary --files-report` で動作確認する。
- ChatGPTログインが必要なら、Oracleの専用ブラウザプロファイルでログインするところだけ俺に依頼する。

注意:
- `npx -y @steipete/oracle` は使わない。
- `.oracle\browser-profile`、Cookie、APIキー、パスワードはGitHubから持ってこない。
- GPT/ChatGPT相談はこの改変済みOracleのbrowser workflowを標準にする。
```

If the other PC already has the repo cloned, Codex can skip cloning and run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\source\repos\oracle\codex-setup\install-windows.ps1"
```
