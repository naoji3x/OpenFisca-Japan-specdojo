---
specdojo:
  id: prj-0001:pjr-93ng-frontend-applicable-refresh
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: issue
  item_status: open
  priority: low
  difficulty: medium
  owner: DEV
  registered_at: "2026-11-15T00:35:28Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-R4TH
  commit_type: fix
---

# PJR-93NG フロントエンドの結果だけが変わったときに、制度の一覧が更新されないことがあるかを調べる

## 1. 課題内容

applicable.tsx の制度の一覧を作る useEffect は、無限ループを避けるため依存を result だけにしている。フロントエンドの結果だけが変わる場面が実際に起き、一覧が古いまま残るのか、依存を足すと本当に無限ループになるのかを調べ、it.fails のテストの扱いを決める。

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
