# GitHub Copilot カスタムエージェント 運用ガイド

Python Flask Webアプリケーション開発に特化したカスタムエージェントセット。  
要件定義から実装・テストまで、フェーズごとに専門エージェントを使い分けることで開発プロセスを効率化する。

---

## エージェント一覧

| エージェント | 呼び出し | 担当フェーズ |
|---|---|---|
| Strategist | `@Strategist` | 戦略・企画・MVP定義・OKR設定 |
| Product Owner | `@Product Owner` | 要件定義・ユーザーストーリー・PRD |
| Architect | `@Architect` | 技術設計・DB/API設計・ADR |
| Developer | `@Developer` | 実装・コーディング・バグ修正 |
| QA Reviewer | `@QA Reviewer` | テスト・コードレビュー・ドキュメント生成 |

---

## 基本的な使い方

### ステップ1: エージェントを呼び出す

VS Code のチャットパネル（`Ctrl+Alt+I`）を開き、`@` に続けてエージェント名を入力する。

```
@Strategist 副業をしている人向けに確定申告を楽にするWebアプリを作りたい
```

### ステップ2: 推奨ワークフロー

開発フェーズの順番に沿ってエージェントを切り替えて使う。

```
1. @Strategist     → 戦略立案・MVP定義・OKR設定
        ↓
2. @Product Owner  → 要件定義・ユーザーストーリー作成
        ↓
3. @Architect      → 技術設計・DB設計・API設計
        ↓
4. @Developer      → 実装・コーディング
        ↓
5. @QA Reviewer    → テスト作成・コードレビュー・ドキュメント生成
```

---

## 各エージェントの使い方

### Strategist

**いつ使うか**: 開発の最上流。「何を・なぜ・誰のために作るか」が固まっていない段階。アイデアを戦略に変えるフェーズ。

**典型的なプロンプト例**:
```
@Strategist
副業をしている人向けに確定申告を楽にするWebアプリを作りたい。
リーンキャンバスとMVPのスコープ、OKRを整理してほしい。
```

**主な成果物**:
- リーンキャンバス（課題・UVP・収益モデル・競合優位性）
- 仮説検証シート
- MVPスコープ定義（含む/含まない機能の明示）
- OKR（Objective + Key Results）
- Product Ownerへの引き渡し条件チェックリスト

---

### Product Owner

**いつ使うか**: 戦略が固まったあと、「何を作るか・なぜ作るか」を機能レベルで整理するフェーズ。

**典型的なプロンプト例**:
```
@Product Owner
ユーザーが日々の支出を記録・分析できる家計簿アプリを作りたい。
主なユーザーは20〜30代の個人。PRDとユーザーストーリーを作ってほしい。
```

**主な成果物**:
- PRD（プロダクト要件定義書）
- ユーザーストーリー（Given/When/Then形式の受け入れ条件付き）
- MoSCoW優先順位表

---

### Architect

**いつ使うか**: PRDが固まったあと、実装前に技術方針を決めるフェーズ。

**典型的なプロンプト例**:
```
@Architect
以下のPRDをもとにFlaskアプリのDB設計とAPI設計をしてほしい。
[PRDの内容を貼り付ける]
```

**主な成果物**:
- ディレクトリ構成
- ERDとテーブル定義
- APIエンドポイント一覧
- ADR（技術選定の意思決定記録）

---

### Developer

**いつ使うか**: 設計が決まったあと、コードを書くフェーズ。

**典型的なプロンプト例**:
```
@Developer
以下の設計に基づき、ユーザー認証機能（登録・ログイン・ログアウト）を実装してほしい。
- Blueprint名: auth
- 使用ライブラリ: Flask-Login, Flask-WTF, Flask-Bcrypt
[API設計を貼り付ける]
```

**主な成果物**:
- Blueprintファイル（routes.py, forms.py）
- SQLAlchemyモデル
- Jinja2テンプレート
- マイグレーションファイル

---

### QA Reviewer

**いつ使うか**: 実装後に品質を担保するフェーズ。またはコードレビューを依頼するとき。

**典型的なプロンプト例**:
```
@QA Reviewer
以下のコードをレビューしてほしい。セキュリティ上の問題と、pytestテストケースを作成してほしい。
[実装コードを貼り付けるか、ファイルを #ファイル名 で参照する]
```

**主な成果物**:
- セキュリティ・品質のレビューコメント（修正案付き）
- pytestテストケース
- README.md やAPIドキュメント

---

## ファイル構成

```
.github/
├── agents/
│   ├── strategist.agent.md      # Strategist エージェント定義
│   ├── product-owner.agent.md   # Product Owner エージェント定義
│   ├── architect.agent.md       # Architect エージェント定義
│   ├── developer.agent.md       # Developer エージェント定義
│   └── qa-reviewer.agent.md     # QA Reviewer エージェント定義
├── instructions/                # ファイルタイプ別の指示（追加可）
├── copilot-instructions.md      # 全エージェント共通のワークスペース指示
└── copilot-agents.md            # このファイル（運用ガイド）
```

---

## カスタマイズ

各エージェントの `.agent.md` を編集することで動作を調整できる。

| 項目 | 場所 | 例 |
|---|---|---|
| 使用ツールの制限 | frontmatter `tools:` | `tools: [read, search]`（実行禁止） |
| モデルの指定 | frontmatter `model:` | `model: "Claude Sonnet 4"` |
| 対応技術の変更 | 本文 | Flask → FastAPI に書き換える |
| 禁止事項の追加 | 本文 `## 制約` セクション | 特定ライブラリの使用禁止など |
