---
name: create-pr-from-branch-commits
description: "Use when: 現在のブランチに積まれたコミットを読み取ってプルリクエストのタイトルや本文を作りたい, ブランチ差分からPR説明を整理したい, コミット履歴ベースでPRを作成したい, gh pr create 用の下書きを作りたい"
argument-hint: "ベースブランチ、PRの目的、チケット番号、レビュー観点などがあれば渡す"
---

# Create Pull Request From Branch Commits

現在のブランチに積まれたコミットを読み取り、レビューしやすいプルリクエストのタイトルと本文を作るためのSkill。

## When to use this skill

- 現在ブランチのコミット内容からPR本文を組み立てたいとき
- ベースブランチとの差分を要約し、変更理由を説明したいとき
- `gh pr create` でそのまま使えるタイトル・本文の下書きがほしいとき
- コミット単位の変更点、テスト、リスクをPRに整理したいとき

## Required behavior

- PR本文は、現在のブランチに固有のコミットと差分だけを根拠に作る
- 変更理由、ユーザー影響、テスト、リスクを優先して要約する
- コミットメッセージをそのまま並べるだけで終わらせない
- 実行していないテストを実行済みと書かない
- 不明な点は推測で埋めず、未確認として明示する
- 実際にPRを作成するのは、ユーザーが明示的に依頼した場合だけにする
- PR説明文は必ず `.github/skills/create-pr-from-branch-commits/output/pr-description.txt` に保存し、その内容を承認されるまでPR作成を実行しない

## Workflow

1. 現在のブランチ名を取得する
2. ベースブランチを決める
3. ベースブランチとの差分に含まれるコミット一覧を取得する
4. コミットごとの変更ファイルと差分を確認する
5. 必要ならワークツリーの未コミット変更が混ざっていないか確認する
6. 変更内容を機能、修正、リファクタリング、ドキュメント更新などに整理する
7. PRタイトル、要約、変更点、テスト、懸念点をテンプレートに流し込み、`.github/skills/create-pr-from-branch-commits/output/pr-description.txt` に保存する
8. ユーザーに `.github/skills/create-pr-from-branch-commits/output/pr-description.txt` の内容確認を依頼し、承認を待つ
9. ユーザー承認を受けたら、自動でPR作成コマンドを実行する

## Step-by-step guidance

### 1. Decide the base branch

優先順位は次の通り。

1. ユーザーが指定したベースブランチ
2. リモートのデフォルトブランチ
3. `main`
4. `master`

ベースブランチが曖昧なら、その前提を短く確認してから進める。

### 2. Gather Git context

最低限、以下の情報を確認する。

- 現在のブランチ名
- ベースブランチ名
- ベースブランチ以降のコミット一覧
- 差分サマリー
- 変更ファイル一覧

取得例:

```bash
git branch --show-current
git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
git log --reverse --no-merges origin/<base>..HEAD --pretty=format:'%h %s'
git diff --stat origin/<base>...HEAD
git diff --name-status origin/<base>...HEAD
```

マージコミットが重要な文脈を持つ場合を除き、通常は `--no-merges` を優先する。

### 3. Read the actual changes

PR本文はコミット件名だけで書かない。以下を必ず確認する。

- 各コミットの目的
- 主要な変更ファイル
- 破壊的変更の有無
- テストや検証の有無
- レビュー時に見てほしい箇所

必要に応じて、個別コミット差分も読む。

```bash
git show --stat <commit>
git show <commit> --
```

### 4. Synthesize the PR narrative

次の順で整理する。

1. なぜこの変更が必要か
2. 何をどう変えたか
3. ユーザーや運用への影響は何か
4. テストまたは未検証事項は何か
5. レビュー時の注意点は何か

### 5. Write the title

タイトルは「変更の目的」が一目で分かるように書く。コミット件名の単純連結は禁止。

良い例:

- `Add a reusable skill to generate PR descriptions from branch commits`
- `Create a Copilot skill for drafting pull requests from current branch history`

避ける例:

- `fix readme`
- `update files`
- `コミットのまとめ`

### 6. Fill the template

本文は [pr-template.md](./pr-template.md) を基準に作成する。

各項目のルール:

- Summary: 2〜4文で目的と成果を説明する
- Changes: 機能単位で整理し、ファイル名の羅列にしない
- Testing: 実施済みだけを書く。未実施ならその理由も書く
- Risks: 互換性、未確認点、レビュー観点を簡潔に書く

### 7. Approval-gated PR creation

承認前と承認後で手順を分離する。

1. タイトルと本文を `.github/skills/create-pr-from-branch-commits/output/pr-description.txt` に保存する
2. `.github/skills/create-pr-from-branch-commits/output/pr-description.txt` をユーザーに提示し、明示的な承認を待つ
3. 承認メッセージは `承認` のみを有効とし、これ以外では `gh pr create` を実行しない

### 8. Auto-create after approval

ユーザーの承認後は、以下を自動で行う。

1. `gh` の利用可否と認証状態を確認する
2. 現在ブランチとベースブランチを確定する
3. `.github/skills/create-pr-from-branch-commits/output/pr-description.txt` からタイトルと本文を読み取り、PRを作成する

例:

```bash
bash .github/skills/create-pr-from-branch-commits/create-pr-from-description.sh .github/skills/create-pr-from-branch-commits/output/pr-description.txt <base> <current-branch>
```

標準運用では、上記スクリプトを使って `PRタイトル案:` 行をタイトルとして抽出し、残りを本文として送信する。

## Output requirements

出力には最低限以下を含める。

- PRタイトル案を1つ
- PR本文の完成版
- `.github/skills/create-pr-from-branch-commits/output/pr-description.txt` への保存結果
- 根拠にしたベースブランチ名
- テスト実施状況
- 不明点またはレビュー観点

## Quality bar

- 読み手がコミットを追わなくても変更の全体像が分かること
- 変更点の列挙ではなく、意図と影響が伝わること
- テストやリスクの捏造がないこと
- 10コミット以上あっても、論点を圧縮して整理できていること

## Example prompt

```text
/create-pr-from-branch-commits baseはmain。今のブランチのコミットからPRタイトルと本文を作って。チケットはABC-123。
```

```text
承認
```