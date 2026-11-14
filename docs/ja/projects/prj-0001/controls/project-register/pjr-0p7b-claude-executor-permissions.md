---
specdojo:
  id: prj-0001:pjr-0p7b-claude-executor-permissions
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
  priority: medium
  difficulty: medium
  registered_at: "2026-11-14T23:51:45Z"
  derived_from:
    - PJR-N0FE
  commit_type: chore
---

# PJR-0P7B exec の Claude の executor が、検査のコマンドを流し、個票を書けるようにする

## 1. 概要

exec が Claude の executor に渡す .specdojo/claude/settings.edit.json は編集だけを許し、Bash を許していない。PJR-N0FE で npm・npx・node が承認の待ちで止まり、project の個票も書けなかった。許すコマンドと範囲を決め、SpecDojo の側への要望も含めて直す。

## 2. 入力

<!-- 対話で得た前提・制約・委任範囲を記録する。完了・回答の判定条件とは分ける。 -->

-

## 3. 完了条件

- _TODO_: 完了と判断できる具体的な条件を記載する。

## 4. 作業内容

| No  | 作業   | 担当   | 状態 | メモ |
| --- | ------ | ------ | ---- | ---- |
| 1   | _TODO_ | _TODO_ | open | -    |

## 5. 対応結果

_TODO_: 完了時に、実施内容・成果物・残課題を記載する。未完了の場合は `-` とする。

## 6. 関連ドキュメント

- _TODO_: 根拠・影響先・追跡先を `[[doc-id]]` 形式で記載する。
