# Roblox StudioとClaude Code連携ガイド：MCP導入ステップ

本ドキュメントは、VSCodeのClaude Code環境（`@claude`コマンド）とRoblox Studioを連携させ、AIによるゲーム開発支援を可能にするための**Model Context Protocol (MCP)** の導入手順を、初心者の方にも分かりやすく詳細に解説します。

## 1. Model Context Protocol (MCP) の基本概念

**Model Context Protocol (MCP)** は、AIアシスタント（LLM）と、開発者が使用するアプリケーション（Roblox Studio）の間で、**コンテキスト（文脈）** と **操作（ツール実行）** をやり取りするためのオープンソースの標準規格です [1]。

このプロトコルを介して、AIはRoblox Studioのプロジェクト構造を理解し、開発者の指示に基づいてStudio内で直接的な操作を実行できるようになります。

| 要素 | 役割 |
| :--- | :--- |
| **AIアシスタント** | Claude Code（VSCodeの`@claude`コマンド） |
| **プロトコル** | MCP (Model Context Protocol) |
| **ブリッジ** | Roblox Studio MCP Server |
| **アプリケーション** | Roblox Studio |

## 2. 導入のための前提条件

導入を開始する前に、以下のソフトウェアがインストールされ、正常に動作していることを確認してください。

1.  **Roblox Studio**: 最新版がインストールされていること。
2.  **VSCode (Visual Studio Code)**: インストールされていること。
3.  **Claude Code (VSCode拡張機能)**: VSCodeにインストールされ、ターミナルで`@claude`コマンドが使用できる状態であること。

## 3. 詳細な導入ステップ

導入は、主に「MCP Serverの準備」「Studioプラグインのインストール」「Claude Codeの設定」の3つのステップで構成されます。

### ステップ 3.1: Roblox Studio MCP Serverのダウンロード

Roblox StudioとClaude Codeを仲介する**MCP Server** の実行ファイルをダウンロードします。

1.  **GitHubリリースページにアクセスします** [2]。
    *   URL: `https://github.com/Roblox/studio-rust-mcp-server/releases`
2.  **最新のリリース**（Latestと表示されているもの）を探します。
3.  **お使いのOSに合ったファイルをダウンロードします**。
    *   **Windowsの場合**: `rbx-studio-mcp.exe`
    *   **macOSの場合**: `macOS-rbx-studio-mcp.zip`
4.  ダウンロードしたファイルを、移動させない**任意の場所**（例：`C:\RobloxMCP\` や `~/Documents/RobloxMCP/`）に保存し、macOSの場合は解凍しておきます。

### ステップ 3.2: MCP Serverの実行とStudioプラグインのインストール

ダウンロードした実行ファイルを起動し、Roblox Studioに連携用のプラグインをインストールします。

1.  **Roblox StudioとVSCode（Claude Code）を完全に終了します**。
2.  **ダウンロードしたMCP Serverの実行ファイルを起動します**。
    *   Windowsの場合は `rbx-studio-mcp.exe` をダブルクリック。
    *   macOSの場合は解凍したフォルダ内の実行ファイルをダブルクリック。
3.  実行すると、Serverはバックグラウンドで起動し、**Roblox Studioのプラグインフォルダに自動的に連携用プラグイン（MCP）をインストールします** [1]。
    *   *注意*: このServerは、Claude CodeとRoblox Studioが通信するために、**ゲーム開発中は常に起動しておく必要があります**。

### ステップ 3.3: Claude Code (VSCode) の設定

VSCodeのClaude Code拡張機能に、起動したRoblox Studio MCP Serverの情報を登録します。

Claude Codeは、他のMCPクライアント（例：Claude Desktop）の設定を自動検出する機能がありますが、ここでは最も確実な**手動設定**の方法を推奨します [3]。

1.  **VSCodeを開きます**。
2.  **Claude Codeの設定ファイル**を開きます。
    *   通常、ユーザー設定ファイルは以下のパスにあります [5]。
        *   Windows: `%APPDATA%\Code\User\settings.json`
        *   macOS/Linux: `~/.config/Code/User/settings.json`
    *   または、VSCodeの「設定」（`Ctrl+,` または `Cmd+,`）を開き、検索バーで `claude mcp` と検索して設定項目を探します。
3.  **MCP Serverの設定をJSON形式で追記します**。
    *   `settings.json` ファイルに、以下の構造で `claude.mcp.servers` の設定を追加または編集します。
    *   `"command"` の値は、**ステップ3.1で保存したMCP Serverの実行ファイルへの絶対パス**に置き換えてください。

```json
{
    // 他の設定項目...
    
    "claude.mcp.servers": {
        "Roblox Studio": {
            "command": "/path/to/your/rbx-studio-mcp", 
            "args": [
                "--stdio"
            ]
        }
    }
    
    // 他の設定項目...
}
```

*   **パスの例**:
    *   Windows: `"C:\\RobloxMCP\\rbx-studio-mcp.exe"`
    *   macOS: `"/Users/yourname/Documents/RobloxMCP/rbx-studio-mcp"`

4.  **VSCodeを再起動します**。

### ステップ 3.4: 連携の確認と使用方法

設定が完了したら、連携が正しく機能しているかを確認します。

1.  **Roblox Studioを起動し、プロジェクトを開きます**。
2.  Studioの「プラグイン」タブに、**MCPプラグイン**のアイコンが表示されていることを確認します。
3.  **VSCodeを起動し、ターミナルで`@claude`コマンドを入力します**。
4.  ClaudeにRoblox Studioへの操作を指示します。

| 指示の例 | 期待される動作 |
| :--- | :--- |
| `@claude Insert a model of a red car into the workspace.` | Studioの`Workspace`に赤い車のモデルが挿入される。 |
| `@claude Write a Luau script that makes a part explode when a player touches it, and place it in ServerScriptService.` | 爆発スクリプトが生成され、`ServerScriptService`に配置される。 |

**重要**: 初めてClaudeがRoblox Studioにアクセスしようとするとき、**セキュリティの確認ダイアログ**が表示される場合があります。必ず内容を確認し、許可してください。

## 4. トラブルシューティング

*   **ClaudeがRoblox Studioを認識しない**:
    *   MCP Serverの実行ファイルが起動したままであるか確認してください。
    *   Roblox StudioとVSCode（Claude Code）を完全に終了し、MCP Serverを再起動してから、再度StudioとVSCodeを起動してみてください。
    *   `settings.json` に記述したMCP Serverの実行ファイルへのパスが正しいか、特にバックスラッシュ（`\`）のエスケープ（`\\`）が正しく行われているか確認してください。
*   **Roblox Studioにプラグインが見当たらない**:
    *   MCP Serverの実行ファイルを再度起動し、プラグインの自動インストールを試みてください。
    *   手動でプラグインをインストールする方法もありますが、まずは自動インストールを試みてください。

***

### 参考文献

[1] [Introducing the Open Source Studio MCP Server - Roblox DevForum](https://devforum.roblox.com/t/introducing-the-open-source-studio-mcp-server/3649365)
[2] [GitHub - Roblox/studio-rust-mcp-server](https://github.com/Roblox/studio-rust-mcp-server)
[3] [Use MCP servers in VS Code - Visual Studio Code Docs](https://code.visualstudio.com/docs/copilot/customization/mcp-servers)
[4] [Visual Studio Code - Claude Code Docs](https://code.claude.com/docs/en/vs-code)
[5] [Claude Code settings - Claude Code Docs](https://code.claude.com/docs/en/settings)
[6] [The Official Roblox Studio MCP Server: An AI Engineer's ... - Skywork AI](https://skywork.ai/skypage/en/roblox-studio-mcp-server-guide/1978332255713140736)
