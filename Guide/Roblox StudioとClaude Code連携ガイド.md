# Roblox StudioとClaude Code連携ガイド

このガイドでは、AIアシスタント「Claude Code」からRoblox Studioを直接操作できるようにする設定方法を、初心者の方にも分かりやすく解説します。

---

## このガイドでできるようになること

設定が完了すると、以下のようなことができるようになります：

- Claude Codeに「赤いパーツをWorkspaceに追加して」と頼むだけで、Roblox Studio上にパーツが作成される
- 「プレイヤーがタッチしたら爆発するスクリプトを書いて」と頼むだけで、スクリプトが自動生成される
- ゲームの構造をAIに読み取ってもらい、改善提案を受けられる

---

## MCP（Model Context Protocol）とは？

**MCP**は、AIとアプリケーションをつなぐ「通訳」のような仕組みです。

```
┌─────────────────┐      ┌─────────────┐      ┌─────────────────┐
│   Claude Code   │ ←──→ │  MCP Server │ ←──→ │  Roblox Studio  │
│  （AIアシスタント）│      │   （通訳）    │      │  （ゲーム開発）   │
└─────────────────┘      └─────────────┘      └─────────────────┘
```

- **Claude Code**: あなたの指示を理解するAI
- **MCP Server**: AIの指示をRoblox Studioが理解できる形に変換
- **Roblox Studio**: 実際にゲームを編集するアプリ

---

## 必要なもの

始める前に、以下がインストールされていることを確認してください：

| ソフトウェア | 確認方法 |
|-------------|---------|
| Roblox Studio | デスクトップにアイコンがあるか確認 |
| VSCode | デスクトップにアイコンがあるか確認 |
| Claude Code | VSCodeのターミナルで `claude` と入力して起動するか確認 |

---

## 設定手順

### ステップ1: MCP Serverをダウンロードする

MCP Serverは、Claude CodeとRoblox Studioの間で通訳をしてくれるプログラムです。

1. 以下のURLにアクセスします：

   **https://github.com/Roblox/studio-rust-mcp-server/releases**

2. ページ内で「**Latest**」と書かれた最新リリースを探します

3. お使いのパソコンに合ったファイルをダウンロードします：
   - **Windowsの場合**: `rbx-studio-mcp.exe` をクリック
   - **Macの場合**: `macOS-rbx-studio-mcp.zip` をクリック

4. ダウンロードしたファイルを分かりやすい場所に保存します

   **おすすめの保存場所（Windows）:**
   ```
   C:\Users\あなたのユーザー名\Downloads\rbx-studio-mcp.exe
   ```

> **ポイント**: ファイルの保存場所（パス）は後で使うので、メモしておいてください。

---

### ステップ2: MCP Serverを起動してプラグインをインストールする

1. **Roblox StudioとVSCodeを完全に終了**します
   - タスクバーのアイコンを右クリック→「ウィンドウを閉じる」

2. ダウンロードした `rbx-studio-mcp.exe` を**ダブルクリック**して起動します

3. 黒いウィンドウ（コマンドプロンプト）が一瞬表示されて消えます
   - これは正常です。バックグラウンドで起動しています
   - **Roblox Studio用のプラグインが自動的にインストールされます**

> **注意**: このMCP Serverは、ゲーム開発中は常に起動しておく必要があります。

---

### ステップ3: Claude Codeに設定ファイルを作成する

ここが最も重要なステップです。Claude CodeにMCP Serverの場所を教えます。

#### 方法A: コマンドで設定（おすすめ）

1. **VSCodeを起動**します

2. ターミナルを開きます（メニューの「ターミナル」→「新しいターミナル」）

3. あなたのゲームプロジェクトのフォルダに移動します：
   ```bash
   cd "C:\Users\あなたのユーザー名\Desktop\あなたのプロジェクトフォルダ"
   ```

4. 以下のコマンドを入力してEnterキーを押します：
   ```bash
   claude mcp add --transport stdio rbx-studio --scope project -- cmd /c "C:\Users\あなたのユーザー名\Downloads\rbx-studio-mcp.exe" --stdio
   ```

   > **重要**: `あなたのユーザー名` の部分は、実際のユーザー名に置き換えてください。

5. 「MCP server added」と表示されれば成功です。

---

#### 方法B: 手動で設定ファイルを作成

コマンドがうまくいかない場合は、手動で設定ファイルを作成します。

1. あなたのゲームプロジェクトのフォルダを開きます

2. フォルダ内に `.mcp.json` という名前のファイルを新規作成します

   > **ファイル名の注意**: 先頭にドット（.）がついています。「mcp.json」ではありません。

3. ファイルを開き、以下の内容をコピー＆ペーストします：

```json
{
  "mcpServers": {
    "rbx-studio": {
      "type": "stdio",
      "command": "cmd",
      "args": ["/c", "C:\\Users\\あなたのユーザー名\\Downloads\\rbx-studio-mcp.exe", "--stdio"],
      "env": {}
    }
  }
}
```

4. `あなたのユーザー名` を実際のユーザー名に置き換えます

5. ファイルを保存します

> **Windowsでの注意点**:
> - パス内のバックスラッシュ（\）は `\\` と2つ重ねて書きます
> - 例: `C:\\Users\\tanaka\\Downloads\\...`

---

### ステップ4: 設定を確認する

設定が正しくできたか確認しましょう。

1. VSCodeのターミナルで以下のコマンドを入力します：
   ```bash
   claude mcp list
   ```

2. 以下のような表示が出れば成功です：
   ```
   rbx-studio: cmd /c C:\Users\...\rbx-studio-mcp.exe --stdio - ✓ Connected
   ```

**「Connected」と表示されていれば、設定完了です！**

---

### ステップ5: 実際に使ってみる

1. **Roblox Studioを起動**し、ゲームプロジェクトを開きます

2. **VSCodeでClaude Codeを起動**します：
   ```bash
   claude
   ```

3. Claude Codeに話しかけてみましょう：
   ```
   Roblox StudioのWorkspaceに赤いPartを追加して
   ```

4. 初回は**セキュリティ確認のダイアログ**が表示される場合があります
   - 内容を確認し、「許可」をクリックしてください

---

## うまくいかないときは

### 「Connected」と表示されない場合

1. MCP Server（`rbx-studio-mcp.exe`）が起動しているか確認
   - タスクマネージャーで `rbx-studio-mcp.exe` を探す
   - 見つからなければ、ダブルクリックして起動

2. `.mcp.json` のパスが正しいか確認
   - ファイルの保存場所を再確認
   - バックスラッシュが `\\` になっているか確認

3. VSCodeとRoblox Studioを再起動

### Claude CodeがRoblox Studioを操作できない場合

1. Roblox Studioが起動しているか確認
2. Claude Codeのセッションを再起動（`/exit` → `claude`）
3. `/mcp` コマンドで接続状態を確認

---

## よくある質問

### Q: MCP Serverは毎回起動する必要がありますか？

A: はい。ゲーム開発を始める前に `rbx-studio-mcp.exe` を起動してください。起動し忘れるとClaude CodeからRoblox Studioを操作できません。

### Q: 複数のプロジェクトで使いたい場合は？

A: 各プロジェクトフォルダに `.mcp.json` を作成するか、以下のコマンドで全プロジェクト共通の設定にできます：
```bash
claude mcp add --transport stdio rbx-studio --scope user -- cmd /c "パス" --stdio
```

### Q: Macでも使えますか？

A: はい。Mac版は `cmd /c` が不要です。`.mcp.json` を以下のように書きます：
```json
{
  "mcpServers": {
    "rbx-studio": {
      "type": "stdio",
      "command": "/Users/あなたのユーザー名/Downloads/rbx-studio-mcp",
      "args": ["--stdio"],
      "env": {}
    }
  }
}
```

---

## まとめ

| ステップ | 内容 |
|---------|------|
| 1 | MCP Serverをダウンロード |
| 2 | MCP Serverを起動（プラグイン自動インストール） |
| 3 | `.mcp.json` 設定ファイルを作成 |
| 4 | `claude mcp list` で接続確認 |
| 5 | Claude Codeから操作開始 |

これで、AIの力を借りてRobloxゲーム開発ができるようになりました！

---

## Claude Codeによる自動セットアップ（おすすめ）

上記の手順を自分で行う代わりに、**Claude Codeに全部お任せ**することもできます。
このガイドファイルをClaude Codeに読み込ませるだけで、自動的にMCP設定を行ってくれます。

### 自動セットアップの手順

#### ステップ1: MCP Serverだけダウンロードしておく

自動セットアップでも、MCP Server本体のダウンロードだけは手動で必要です。

1. https://github.com/Roblox/studio-rust-mcp-server/releases にアクセス
2. `rbx-studio-mcp.exe`（Windows）または `macOS-rbx-studio-mcp.zip`（Mac）をダウンロード
3. ダウンロードフォルダに保存（移動しなくてOK）

#### ステップ2: VSCodeでClaude Codeを起動

1. VSCodeを開く
2. ターミナルを開く（メニュー「ターミナル」→「新しいターミナル」）
3. ゲームプロジェクトのフォルダに移動：
   ```bash
   cd "あなたのプロジェクトフォルダのパス"
   ```
4. Claude Codeを起動：
   ```bash
   claude
   ```

#### ステップ3: 魔法の一言を入力

Claude Codeが起動したら、以下の文章をそのままコピー＆ペーストしてEnterを押すだけです：

```
@"Roblox StudioとClaude Code連携ガイド.md" を読んでMCPをセットアップして
```

#### 「@」記号の意味

`@` はClaude Codeにファイルを読み込ませる特別な記号です。

| 入力例 | 意味 |
|-------|------|
| `@"ファイル名.md"` | 指定したファイルをClaude Codeに読み込ませる |
| `@"フォルダ/ファイル.txt"` | フォルダ内のファイルを読み込ませる |

この機能を使うと、Claude Codeはファイルの中身を読んで、書かれている指示に従って作業してくれます。

#### ステップ4: あとは待つだけ

Claude Codeが自動的に以下を実行します：

1. あなたのパソコンから `rbx-studio-mcp.exe` を探す
2. 設定ファイル（`.mcp.json`）を自動作成
3. 接続テストを実行
4. 結果を報告

**何か質問されたら回答してください。**（例：「MCP Serverはダウンロード済みですか？」など）

### 自動セットアップ後の確認

セットアップが完了したら、Claude Codeに以下のように聞いてみましょう：

```
MCPの接続状態を確認して
```

「Connected」と表示されれば成功です！

---

## LLM向け自動セットアップ手順

> **注意**: この手順はClaude Code等のLLMが自動実行するためのものです。人間の方は上記の手順をご参照ください。

### LLM_INSTRUCTION_START

このセクションを読んだLLMは、以下の手順に従ってRoblox Studio MCP連携を自動セットアップしてください。

#### 前提条件の確認

1. 現在のOSを確認（Windows/macOS/Linux）
2. ユーザーのホームディレクトリパスを取得

#### 手順1: MCP Server実行ファイルの検索

以下の場所を順番に検索し、`rbx-studio-mcp.exe`（Windows）または `rbx-studio-mcp`（macOS）を探す：

```bash
# Windows
find /c -name "rbx-studio-mcp.exe" 2>/dev/null || \
ls "$HOME/Downloads/rbx-studio-mcp.exe" 2>/dev/null || \
ls "$HOME/Desktop/rbx-studio-mcp.exe" 2>/dev/null

# macOS
find ~ -name "rbx-studio-mcp" -type f 2>/dev/null | head -5
```

**見つからない場合**: ユーザーに以下を案内
- ダウンロードURL: https://github.com/Roblox/studio-rust-mcp-server/releases
- Windowsは `rbx-studio-mcp.exe`、macOSは `macOS-rbx-studio-mcp.zip` をダウンロード

#### 手順2: .mcp.json ファイルの作成

現在のプロジェクトディレクトリに `.mcp.json` を作成する。

**Windows用テンプレート:**
```json
{
  "mcpServers": {
    "rbx-studio": {
      "type": "stdio",
      "command": "cmd",
      "args": ["/c", "{MCP_SERVER_PATH}", "--stdio"],
      "env": {}
    }
  }
}
```

**macOS/Linux用テンプレート:**
```json
{
  "mcpServers": {
    "rbx-studio": {
      "type": "stdio",
      "command": "{MCP_SERVER_PATH}",
      "args": ["--stdio"],
      "env": {}
    }
  }
}
```

**重要な置換ルール:**
- `{MCP_SERVER_PATH}` を実際のパスに置換
- Windowsの場合、パス内の `\` を `\\` にエスケープ

#### 手順3: 接続確認

```bash
claude mcp list
```

**成功判定**: 出力に `rbx-studio` と `Connected` が含まれていること

#### 手順4: ユーザーへの報告

セットアップ完了後、以下を報告：
- 作成したファイル: `.mcp.json` のパス
- MCP Server実行ファイルの場所
- 接続状態（Connected/Failed）

**接続失敗時の対処:**
1. MCP Server実行ファイルのパスを再確認
2. ファイルが存在し、実行可能か確認
3. Windowsの場合、`cmd /c` 経由での実行を確認

#### エラーハンドリング

| エラー状況 | 対処 |
|-----------|------|
| MCP Serverが見つからない | ユーザーにダウンロードを案内 |
| パスにスペースが含まれる | ダブルクォートで囲む |
| 接続失敗 | パスのエスケープを確認、再試行 |
| 既存の.mcp.jsonがある | 既存設定を保持しつつrbx-studioを追加 |

#### 既存設定がある場合のマージ処理

`.mcp.json` が既に存在する場合は、既存の `mcpServers` オブジェクトに `rbx-studio` を追加する。上書きしない。

```javascript
// 既存の設定を読み込み
existingConfig = JSON.parse(existingContent)

// rbx-studioを追加（既存キーは上書きしない）
if (!existingConfig.mcpServers) {
  existingConfig.mcpServers = {}
}
if (!existingConfig.mcpServers["rbx-studio"]) {
  existingConfig.mcpServers["rbx-studio"] = { /* 新しい設定 */ }
}
```

### LLM_INSTRUCTION_END

---

## 参考リンク

- [Roblox Studio MCP Server（GitHub）](https://github.com/Roblox/studio-rust-mcp-server)
- [MCP公式紹介（Roblox DevForum）](https://devforum.roblox.com/t/introducing-the-open-source-studio-mcp-server/3649365)
