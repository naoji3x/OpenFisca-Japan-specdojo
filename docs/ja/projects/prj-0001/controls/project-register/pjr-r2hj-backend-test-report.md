---
specdojo:
  id: prj-0001:pjr-r2hj-backend-test-report
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
  priority: medium
  difficulty: medium
  owner: DEV
  registered_at: "2026-11-03T03:01:45Z"
  due_on: "2026-11-30"
  depends_on:
    - PJR-67TM
  commit_type: feat
---

# PJR-R2HJ バックエンドのテストのレポートを自動で作る

## 1. 概要

OpenFisca の YAML のテストから、制度×出力の変数×入力の条件の表と、テストのない変数の一覧を作り、tools/test_report のレポートに足す。

## 2. 入力

- naoji の依頼（2026-11-03）: テストのレポートのうち、バックエンドは後で行う。PJR-67TM で作る `tools/test_report/` に、バックエンドの集計を足す（そのため PJR-67TM の後に行う）。
- バックエンドのテストは `openfisca_japan/tests/` の YAML（92 ファイル・1829 件、2026-11-03 時点）である。ディレクトリが制度（`福祉/生活保護` など）を表し、各ケースは `name`・`period`・`input`（条件）・`output`（確かめる変数と期待値）を持つ。
- `tools/make_tests/テストパターン/` に、子育て支援制度と生活福祉資金貸付制度の条件の組み合わせを書いた CSV があり、`tools/make_tests/` がそこからテストを生成している。
- 統合先は、PJR-67TM の後の状況に合わせて、流す前に決める。

## 3. 完了条件

- PJR-67TM の `tools/test_report/` に、バックエンドのテストの集計を足し、`make test-report` で `tmp/test-report/backend.md`（または PJR-67TM の出力と同じ形の別の節）を作る。
- レポートには次を入れる。
  - **概要**: 制度（ディレクトリ）ごとのファイル数と件数。
  - **観点×条件**: 制度 × 出力の変数ごとに、入力に使った変数と値の組み合わせの表。
  - **テストの状況**: `make test` の結果（成功・失敗の件数）。結果を取れない場合は「未実行」とする。
  - **不足しているテスト**: OpenFisca の制度の定義（`openfisca_japan` の全部の変数）のうち、どのテストの `output` にも出てこない変数。
  - **設計との差**: `tools/make_tests/テストパターン/` の CSV の条件の組み合わせのうち、テストにないもの。
- pytest のテストを足し、`python -m pytest tools/test_report` で通る。`make test`・`make check-style`・`make check-docs` が通る。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。

## 4. 作業内容

| No  | 作業                                             | 担当 | 状態 | メモ |
| --- | ------------------------------------------------ | ---- | ---- | ---- |
| 1   | YAML とテストパターンの CSV の読み方を決める     | DEV  | open | -    |
| 2   | バックエンドの集計を `tools/test_report/` に足す | DEV  | open | -    |
| 3   | `make test-report` を流して確かめる              | DEV  | open | -    |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 関連: [[prj-0001:pjr-67tm-frontend-test-report|PJR-67TM]]（先に行う。道具を作る）
