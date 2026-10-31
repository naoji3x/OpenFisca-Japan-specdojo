---
specdojo:
  id: prj-0001:pjr-14rn-person-num-validity
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: issue
  item_status: open
  priority: medium
  difficulty: easy
  owner: DEV
  registered_at: "2026-10-31T11:51:17Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-49V3
---

# PJR-14RN 人数の入力を空にしたとき、有効かどうかの判定がすぐに変わらない

## 1. 課題内容

personNumQuestionTemplate で人数を入れたあと「はい」のまま入力を空にすると、有効状態が true のまま残り、もう一度「はい」を押すと false になる。effect の依存に formValidated がないことが原因とみられる

## 2. 入力

<!-- 対話で得た前提・制約・委任範囲を記録する。完了・回答の判定条件とは分ける。 -->

-

## 3. 影響範囲

| 観点         | 影響   |
| ------------ | ------ |
| スコープ     | _TODO_ |
| スケジュール | _TODO_ |
| コスト       | _TODO_ |
| 品質         | _TODO_ |
| 関係者       | _TODO_ |

## 4. 対応方針

| 項目     | 内容   |
| -------- | ------ |
| 原因     | _TODO_ |
| 対応策   | _TODO_ |
| 依存事項 | _TODO_ |
| 完了条件 | _TODO_ |

## 5. 対応結果

_TODO_: 解決内容、確認結果、再発防止策を記載する。未解決の場合は `-` とする。

## 6. 関連ドキュメント

- _TODO_: 根拠・影響先・追跡先を `[[doc-id]]` 形式で記載する。
