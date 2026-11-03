---
specdojo:
  id: prj-0001:pjr-rytb-backend-dependency-conflicts
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: issue
  item_status: open
  priority: low
  difficulty: easy
  registered_at: "2026-11-03T01:48:11Z"
  derived_from:
    - PJR-8V4P
  commit_type: fix
---

# PJR-RYTB バックエンドの依存の食い違いを直す

## 1. 課題内容

make install で入る依存のうち、python-dateutil 4.0.0 が pendulum 2.1.2 の <3.0 に、numexpr 2.14.2 が OpenFisca-Core の numpy <1.25 に合わない。上限のない指定を直す。

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
