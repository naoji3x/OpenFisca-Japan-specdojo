---
specdojo:
  id: prj-0001:pjr-1w29-make-docs-unit-display
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
  priority: high
  difficulty: medium
  owner: DEV
  registered_at: "2026-10-31T03:00:43Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-KS3C
  depends_on:
    - PJR-KS3C
---

# PJR-1W29 制度ドキュメントの生成で率と年齢の単位を表示する

## 1. 概要

制度ドキュメントのパラメータ一覧では、率が `0.183`、年齢が `20`、学年が `12` のように単位のない数値で表示され、読み手に分かりにくい。`../OpenFisca-Japan` の `tools/make_docs/make_docs.py` の `format_number` は、`currency-JPY` と `人` しか扱わないためである。PJR-KS3C で直した YAML の単位を前提に、表示を足す。

## 2. 完了条件

- 変更は `openfisca-japan:tools/make_docs/make_docs.py`、そのテスト、作り直した `openfisca-japan:docs/_data` に限る。パラメータの YAML は変更しない（PJR-KS3C の範囲）。
- `unit: /1` の値を百分率で表示する。例: `0.183` → `18.3%`、`0.0055` → `0.55%`、`0.1` → `10%`。浮動小数点の誤差（`18.299999999999997%` など）を出さない。
- `unit: year` の値を「歳」付きで表示する。例: `20` → `20 歳`。
- `unit: day` の値を「日」付きで表示する。例: `30` → `30 日`。
- `unit: 人` と `unit: 学年` の値を、単位付きで表示する。例: `3` → `3 人`、`12` → `12 学年`。`人` は今の表示を保ち、`学年` は PJR-KS3C で `上限学年` の 2 件に付く単位である。
- 単位のない数値パラメータを `make docs` が検出し、名前の一覧を標準エラーに出す。検出したときに失敗させるかは executor が決め、理由を「4. 対応結果」に記録する。
- `currency-JPY` の値が整数のときだけ「円」を付ける、今の回避策を外す。PJR-KS3C で率の単位が `/1` に直るためである。
- `format_number` の単体テストを追加する。今は `tools/make_docs` にテストがないため、置き場所と実行方法は executor が決め、理由を「4. 対応結果」に記録する。
- `make docs`・`make check-docs`・`make check-style`・`make test` が通る。

### 2.1. 実行の前提（2026-10-31、specdojo-orchestrator）

- product の統合先は `feature/parameter-unit-metadata`（PJR-KS3C の修正の上）である。PJR-KS3C の YAML の修正と `docs/_data` の作り直しは、すでにこのブランチにある。
- Python 3.11 の仮想環境（`../OpenFisca-Japan/.venv`）は PATH にあり、OpenFisca-Japan は editable install されている。依存は追加しない。
- editable install は `../OpenFisca-Japan` の作業ツリー（今は `develop`）を指す。Python の検査は、product の worktree の root で `PYTHONPATH="$PWD"` を付けて流す（例: `PYTHONPATH="$PWD" make docs`、`PYTHONPATH="$PWD" make test`）。流す前に `PYTHONPATH="$PWD" python -c "import openfisca_japan; print(openfisca_japan.__file__)"` で worktree のコードが読まれていることを確かめ、結果を「4. 対応結果」に書く。
- `make check-style` が通るよう、仮想環境の setuptools を 81 未満、pycodestyle を 2.7 系にしてある（flake8 3.9 と flake8-commas のため）。`make format-style` は autopep8 と pycodestyle の版が合わないため流さない。
- executor はネットワークに出られない。

## 3. 作業内容

| No  | 作業                                                                                       | 担当 | 状態 | メモ              |
| --- | ------------------------------------------------------------------------------------------ | ---- | ---- | ----------------- |
| 1   | `format_number` に `/1`・`year`・`day`・`学年` の表示を足し、`currency-JPY` の回避策を外す | DEV  | open | `人` の表示は保つ |
| 2   | 単位のない数値パラメータを検出する検査を足す                                               | DEV  | open | -                 |
| 3   | 単体テストを追加する                                                                       | DEV  | open | -                 |
| 4   | `make docs` で `docs/_data` を作り直し、検証を流す                                         | DEV  | open | -                 |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 先行の項目: PJR-KS3C（パラメータの YAML の単位の誤りを直す）
