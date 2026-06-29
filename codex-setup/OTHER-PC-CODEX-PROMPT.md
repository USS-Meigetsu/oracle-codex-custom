# Prompt To Use On Another Codex PC

Copy this request into Codex on the other Windows PC:

```text
Public GitHub repo https://github.com/USS-Meigetsu/oracle-codex-custom から、改変済み Oracle OSS をこのPCへ導入して。

やってほしいこと:
- GitHub login や秘密鍵は不要。public repo なので HTTPS で clone する。
- repo を `%USERPROFILE%\source\repos\oracle` へ clone する。既にあれば pull/fetch して最新化する。
- `codex-setup\install-windows.ps1` を実行して、依存関係、build、npm link、Codex skill 配置、AGENTS.md 追記、`%USERPROFILE%\.oracle\config.json` 作成まで自動でやる。
- `oracle --dry-run summary --files-report` で動作確認する。
- ChatGPT login が必要なら、Oracle 専用ブラウザプロファイルでログインするところだけユーザーに依頼し、その後は Codex 側で続行する。

運用ルール:
- GPT/ChatGPT 相談は、この改変済み Oracle の browser workflow を標準にする。
- `npx -y @steipete/oracle` は通常利用しない。local checkout の `oracle` コマンドを使う。
- `.oracle\browser-profile`、cookie、API key、password、secret は GitHub から持ってこないし、GitHub に置かない。
- 既存 ChatGPT チャットの文脈を維持したいプロジェクトでは、プロジェクトごとに `.oracle\config.json` の `browser.conversationUrl` を使う。
- ChatGPT が回答中に見える、固まって見える、または回答が明らかに短すぎる場合でも、回答停止/Stop ボタンは押さない。追加質問や `--browser-follow-up` で催促しない。待つか、画面更新/リロードして同じ会話の最新回答を読み直す。
```

If the other PC already has the repo cloned, Codex can skip cloning and run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\source\repos\oracle\codex-setup\install-windows.ps1"
```
