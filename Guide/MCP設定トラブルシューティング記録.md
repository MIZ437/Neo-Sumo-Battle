# MCP設定トラブルシューティング記録

## 概要
Roblox StudioとClaude CodeをMCP（Model Context Protocol）で連携させる際に発生した問題と解決方法の記録。

---

## 発生した問題

### 問題1: 設定ファイルの場所の混乱

**状況:**
ガイドドキュメントでは、VSCodeの `settings.json` に以下のように設定すると記載されていた：

```json
{
    "claude.mcp.servers": {
        "Roblox Studio": {
            "command": "/path/to/your/rbx-studio-mcp",
            "args": ["--stdio"]
        }
    }
}
```

**問題点:**
- Claude Code CLIは VSCode拡張機能ではなく、独立したCLIツール
- `~/.claude/settings.json` に `mcpServers` を追加しようとしたが、スキーマ検証エラーが発生
- エラー: `Unrecognized field: mcpServers`

**原因:**
Claude Codeの `settings.json` はMCPサーバー設定をサポートしていない。MCPサーバーは別ファイル（`.mcp.json`）で管理される。

---

### 問題2: Windowsコマンド構文の問題

**状況:**
最初にWindowsのバッチコマンド構文（`if exist ... (...)` 等）を使用した。

**問題点:**
Claude Codeのシェルは bash を使用しており、Windowsコマンド構文が動作しなかった。

**解決:**
bash構文（`cat`, `ls -la` 等）に変更して実行。

---

## 解決方法

### 正しいMCP設定方法

**1. 設定ファイルの場所:**
- プロジェクトルートに `.mcp.json` を作成
- パス: `C:\Users\ashim\Desktop\Robloxゲーム開発\Neo Sumo Battle\.mcp.json`

**2. 正しい設定内容:**

```json
{
  "mcpServers": {
    "rbx-studio": {
      "type": "stdio",
      "command": "cmd",
      "args": ["/c", "C:\\Users\\ashim\\Downloads\\rbx-studio-mcp.exe", "--stdio"],
      "env": {}
    }
  }
}
```

**3. Windows特有の注意点:**
- 直接 `.exe` を指定するのではなく、`cmd /c` 経由で実行
- パスのバックスラッシュは `\\` でエスケープ

---

## 設定確認コマンド

```bash
# MCPサーバー一覧を確認
claude mcp list

# 特定のMCPサーバーの詳細を確認
claude mcp get rbx-studio

# MCPサーバーを追加（CLI経由）
claude mcp add --transport stdio rbx-studio --scope project -- cmd /c "C:\Users\ashim\Downloads\rbx-studio-mcp.exe" --stdio
```

---

## 最終結果

| 項目 | 状態 |
|------|------|
| MCP Server実行ファイル | `C:\Users\ashim\Downloads\rbx-studio-mcp.exe` |
| 設定ファイル | `.mcp.json` 作成完了 |
| 接続状態 | **Connected** |

---

## 次のステップ

MCPツールを使用するには、Claude Codeセッションの再起動が必要：

1. `/exit` でセッション終了
2. `claude` で再起動
3. `/mcp` で接続確認
4. Roblox Studioとの連携操作が可能になる

---

## 参考：ガイドとの差異

| ガイドの記載 | 実際の正しい方法 |
|-------------|-----------------|
| `settings.json` に `claude.mcp.servers` を追加 | `.mcp.json` に `mcpServers` を追加 |
| 直接 `.exe` パスを指定 | `cmd /c` 経由で実行（Windows） |
| VSCode設定から編集 | `claude mcp add` コマンドまたは手動で `.mcp.json` 作成 |
