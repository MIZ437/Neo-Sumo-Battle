# Rojo入門ガイド - VSCodeでRoblox開発を始めよう

## Rojoとは？

**Rojo（ロホ）** は、VSCodeなどの外部エディタとRoblox Studioを**リアルタイムで同期**するためのツールです。

### 一言で説明すると
> 「VSCodeで書いたコードが、保存した瞬間にRoblox Studioに反映されるツール」

---

## なぜRojoが必要なの？

### Roblox Studio単体の問題点

| 問題 | 説明 |
|------|------|
| エディタが貧弱 | 自動補完が弱い、検索が使いにくい |
| Git管理できない | コードがStudio内に閉じ込められる |
| チーム開発が困難 | 複数人での同時編集ができない |
| バックアップが面倒 | 手動でエクスポートが必要 |

### Rojoを使うと解決！

- VSCodeの強力な編集機能が使える
- GitHubでバージョン管理・チーム開発
- ファイルを保存 → 即座にStudioに反映
- Studioでの変更 → 即座にファイルに反映

---

## Rojoの仕組み（図解）

```
┌─────────────────┐          ┌─────────────────┐
│    VSCode       │          │  Roblox Studio  │
│                 │   Rojo   │                 │
│  src/           │ ←─────→  │  Explorer       │
│   ├─ Server/    │  (同期)  │   ├─ Server     │
│   ├─ Client/    │          │   ├─ Client     │
│   └─ Shared/    │          │   └─ Shared     │
└─────────────────┘          └─────────────────┘
         │
         ↓
┌─────────────────┐
│     GitHub      │
│  (バージョン管理) │
└─────────────────┘
```

**双方向同期**なので、どちらで編集しても反映されます。

---

## インストール方法

### 必要なもの

1. **Roblox Studio** （インストール済み）
2. **VSCode** （インストール済み）
3. **Rojo CLI** （コマンドラインツール）
4. **Rojo VSCode拡張機能**
5. **Rojo Studioプラグイン**

---

### Step 1: Rojo CLIのインストール

#### 方法A: Aftman（推奨）

```bash
# Aftmanをインストール（Rustのツール管理）
# https://github.com/LPGhatguy/aftman からダウンロード

# プロジェクトフォルダで実行
aftman init
aftman add rojo-rbx/rojo
aftman install
```

#### 方法B: Foreman

```bash
# Foremanをインストール
# https://github.com/Roblox/foreman

foreman install
```

#### 方法C: 直接ダウンロード

1. [Rojo Releases](https://github.com/rojo-rbx/rojo/releases) にアクセス
2. 最新版の `rojo-win64.zip` をダウンロード
3. 解凍して `rojo.exe` をPATHの通った場所に配置

#### インストール確認

```bash
rojo --version
# 出力例: Rojo 7.4.1
```

---

### Step 2: VSCode拡張機能のインストール

1. VSCodeを開く
2. 拡張機能タブ（Ctrl+Shift+X）
3. 「Rojo」で検索
4. **Rojo - Roblox Studio Sync** をインストール

---

### Step 3: Studioプラグインのインストール

#### 方法A: Rojoコマンドから（推奨）

```bash
rojo plugin install
```

#### 方法B: 手動インストール

1. [Rojo Plugin](https://github.com/rojo-rbx/rojo/releases) からダウンロード
2. `Rojo.rbxm` を取得
3. Roblox Studioの `Plugins` フォルダに配置
   - Windows: `%LOCALAPPDATA%\Roblox\Plugins`

---

## プロジェクトのセットアップ

### Step 1: 新規プロジェクト作成

```bash
# プロジェクトフォルダを作成
mkdir my-roblox-game
cd my-roblox-game

# Rojoプロジェクトを初期化
rojo init
```

### Step 2: 生成されるファイル構造

```
my-roblox-game/
├── default.project.json    # Rojoの設定ファイル
├── src/
│   ├── server/             # ServerScriptService
│   │   └── init.server.lua
│   ├── client/             # StarterPlayerScripts
│   │   └── init.client.lua
│   └── shared/             # ReplicatedStorage
│       └── init.lua
└── .gitignore
```

---

## default.project.json の解説

```json
{
  "name": "my-roblox-game",
  "tree": {
    "$className": "DataModel",

    "ServerScriptService": {
      "$className": "ServerScriptService",
      "$path": "src/server"
    },

    "StarterPlayer": {
      "$className": "StarterPlayer",
      "StarterPlayerScripts": {
        "$className": "StarterPlayerScripts",
        "$path": "src/client"
      }
    },

    "ReplicatedStorage": {
      "$className": "ReplicatedStorage",
      "$path": "src/shared"
    }
  }
}
```

| 項目 | 説明 |
|------|------|
| `$className` | Robloxのインスタンスタイプ |
| `$path` | 対応するローカルフォルダ |

---

## ファイル命名規則

Rojoはファイル名でスクリプトの種類を判別します。

| ファイル名 | Robloxでの種類 |
|-----------|---------------|
| `*.server.lua` | Script（サーバー） |
| `*.client.lua` | LocalScript（クライアント） |
| `*.lua` | ModuleScript（モジュール） |
| `init.server.lua` | フォルダ名のScript |
| `init.client.lua` | フォルダ名のLocalScript |
| `init.lua` | フォルダ名のModuleScript |

### 例

```
src/server/
├── BattleManager.server.lua  → ServerScriptService.BattleManager (Script)
├── ShopServer.server.lua     → ServerScriptService.ShopServer (Script)
└── Modules/
    └── init.lua              → ServerScriptService.Modules (ModuleScript)
```

---

## 実際の使い方

### Step 1: Rojoサーバーを起動

```bash
# プロジェクトフォルダで実行
rojo serve
```

出力例:
```
Rojo server listening:
  Address: localhost
  Port: 34872

Visit http://localhost:34872/ in your browser for more information.
```

### Step 2: Studioで接続

1. Roblox Studioを開く
2. Pluginsタブ → **Rojo** をクリック
3. **Connect** ボタンをクリック

接続成功すると「Connected!」と表示されます。

### Step 3: 編集してみる

1. VSCodeで `src/server/init.server.lua` を編集
2. **保存（Ctrl+S）**
3. Studioを見ると**即座に反映**されている！

---

## よく使うコマンド

```bash
# サーバー起動（同期開始）
rojo serve

# 特定のプロジェクトファイルを使用
rojo serve myproject.project.json

# Studioプラグインをインストール
rojo plugin install

# プロジェクトをrbxlxファイルにビルド
rojo build -o game.rbxlx

# 既存のplaceファイルにビルド
rojo build -o game.rbxl --output-kind place
```

---

## フォルダ構成のベストプラクティス

### 推奨構成

```
my-game/
├── default.project.json
├── .gitignore
├── README.md
│
├── src/
│   ├── server/                    # ServerScriptService
│   │   ├── Services/
│   │   │   ├── BattleService.server.lua
│   │   │   └── ShopService.server.lua
│   │   └── init.server.lua
│   │
│   ├── client/                    # StarterPlayerScripts
│   │   ├── Controllers/
│   │   │   ├── InputController.client.lua
│   │   │   └── UIController.client.lua
│   │   └── init.client.lua
│   │
│   └── shared/                    # ReplicatedStorage
│       ├── Modules/
│       │   ├── GameConfig.lua
│       │   └── Utils.lua
│       └── init.lua
│
└── assets/                        # Roblox外のアセット
    ├── images/
    └── sounds/
```

---

## トラブルシューティング

### Q: 接続できない

**原因**: Rojoサーバーが起動していない、またはポートが違う

**解決策**:
```bash
# サーバーを再起動
rojo serve

# Studioプラグインでポート番号を確認
# デフォルトは 34872
```

### Q: 変更が反映されない

**原因**: ファイル名の命名規則が間違っている

**解決策**:
- サーバースクリプト: `*.server.lua`
- クライアントスクリプト: `*.client.lua`
- モジュール: `*.lua`

### Q: 日本語ファイル名が文字化けする

**原因**: エンコーディングの問題

**解決策**:
- ファイル名は**英語**を使用
- コード内の日本語コメントは問題なし

### Q: Studioでの変更が消える

**原因**: 双方向同期ではなく、Rojoが上書きしている

**解決策**:
- `rojo serve` 中はVSCode側で編集する
- Studioで編集したい場合は接続を切る

---

## MCPとRojoの比較

| 項目 | MCP（現在使用中） | Rojo |
|------|------------------|------|
| セットアップ | 簡単 | やや複雑 |
| 同期方向 | 手動（コマンド実行） | 自動（リアルタイム） |
| Studio→VSCode | 毎回ダウンロード | 自動反映 |
| VSCode→Studio | コマンドで反映 | 保存で即反映 |
| UI管理 | Studioで直接 | JSONで定義可能 |
| 学習コスト | 低い | 中程度 |

### どちらを選ぶ？

- **MCP**: 手軽にGit管理したい、たまに同期すればOK
- **Rojo**: 頻繁にコード編集、即座にテストしたい、本格開発

---

## おすすめの追加ツール

### 1. Selene（リンター）

コードの問題を検出してくれるツール。

```bash
# インストール
aftman add Kampfkarren/selene

# 実行
selene src/
```

### 2. StyLua（フォーマッター）

コードを自動整形してくれるツール。

```bash
# インストール
aftman add JohnnyMorganz/StyLua

# 実行
stylua src/
```

### 3. Luau LSP（言語サーバー）

VSCodeでの自動補完・型チェックを強化。

1. VSCode拡張「Luau Language Server」をインストール
2. プロジェクトに `.luaurc` を作成

```json
{
  "languageMode": "strict"
}
```

---

## Git管理のセットアップ

### .gitignore の例

```gitignore
# Roblox
*.rbxl
*.rbxlx
*.rbxm
*.rbxmx

# ビルド出力
build/

# OS
.DS_Store
Thumbs.db

# エディタ
.vscode/
*.swp

# 依存関係
/Packages/
```

### 初期コミット

```bash
git init
git add .
git commit -m "Initial commit - Rojo project setup"
git remote add origin https://github.com/username/my-game.git
git push -u origin main
```

---

## まとめ

### Rojoを使うメリット

1. **VSCodeの強力な編集機能**が使える
2. **Git/GitHub**でバージョン管理
3. **リアルタイム同期**で効率的な開発
4. **チーム開発**が可能に
5. **プロの開発フロー**を体験できる

### 始め方（最短ルート）

1. Rojo CLIをインストール
2. VSCode拡張をインストール
3. Studioプラグインをインストール
4. `rojo init` でプロジェクト作成
5. `rojo serve` で同期開始
6. Studioで接続

---

## 参考リンク

- [Rojo公式ドキュメント](https://rojo.space/docs/)
- [Rojo GitHub](https://github.com/rojo-rbx/rojo)
- [Selene](https://kampfkarren.github.io/selene/)
- [StyLua](https://github.com/JohnnyMorganz/StyLua)
- [Luau Language Server](https://github.com/JohnnyMorganz/luau-lsp)

---

*このガイドは2024年12月時点の情報です。最新情報は公式ドキュメントを参照してください。*
