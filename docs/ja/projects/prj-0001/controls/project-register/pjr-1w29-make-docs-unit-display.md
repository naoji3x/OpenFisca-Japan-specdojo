---
specdojo:
  id: prj-0001:pjr-1w29-make-docs-unit-display
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: review
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

| No  | 作業                                                                                       | 担当 | 状態 | メモ                                         |
| --- | ------------------------------------------------------------------------------------------ | ---- | ---- | -------------------------------------------- |
| 1   | `format_number` に `/1`・`year`・`day`・`学年` の表示を足し、`currency-JPY` の回避策を外す | DEV  | done | 百分率は `Decimal` で変換。`人` の表示を維持 |
| 2   | 単位のない数値パラメータを検出する検査を足す                                               | DEV  | done | 名前順の一覧を標準エラーへ警告               |
| 3   | 単体テストを追加する                                                                       | DEV  | done | 標準ライブラリの `unittest` で6件を検証      |
| 4   | `make docs` で `docs/_data` を作り直し、検証を流す                                         | DEV  | done | パラメータの表示24か所を更新                 |

## 4. 対応結果

- 変更ファイル:
  - `openfisca-japan:tools/make_docs/make_docs.py`: `/1` を百分率、`year` を「歳」、`day` を「日」、`学年` を「学年」付きで表示する。百分率は数値の文字列表現を `Decimal` にして100倍し、浮動小数点誤差と不要な末尾のゼロを除く。`currency-JPY` は小数にも「円」を付け、`人`・桁区切り・真偽値・適用なしの表示を維持する。
  - `openfisca-japan:tools/make_docs/test_make_docs.py`: 単位別の表示、百分率のゼロ・負数・微小値、小数の円、配列、過去値、単位漏れ、CLI の標準エラーへの警告と生成継続を検証する6件のテストを追加した。
  - `openfisca-japan:docs/_data/parameters.yml`: `make docs` で再生成し、24か所の表示を更新した。生の値・単位メタデータ・パラメータ YAML に変更はなく、ほかの生成データ3ファイルにも差分はない。
- 単位漏れの扱い: 最新値だけでなく過去値と配列内の数値も調べ、単位がないパラメータの名前を重複なく名前順に標準エラーへ警告する。真偽値と `None` は数値に数えない。警告で生成を失敗させない。理由は、単位メタデータの不足があっても制度ドキュメントを生成できるようにし、YAML の修正が本タスクの対象外である中でも修正対象を明示するためである。現行153件に単位漏れはなく、単位不足を注入した CLI テストで警告先と終了成功を確認した。
- テストの置き場所・実行方法: 生成ツールの隣に置き、product root で `PYTHONPATH="$PWD" python -m unittest discover -s tools/make_docs -v` を実行する。標準ライブラリで検証でき、依存追加や対象外の Makefile 変更を避けられるため採用した。`make test` は制度の YAML テストを対象とするため、この6件は別コマンドで実行する。
- 実行環境: product root で `PYTHONPATH="$PWD" python -c "import openfisca_japan; print(openfisca_japan.__file__)"` を実行し、出力が本タスクの product worktree 内の `openfisca_japan/__init__.py` であることを確認した。Python 3.11.18 を使用した。
- 検証結果:
  - `PYTHONPATH="$PWD" python -m unittest discover -s tools/make_docs -v`: 6件成功。
  - `PYTHONPATH="$PWD" make docs`: 成功。Variable 301件、Parameter 153件、TODO 39件、制度31件を生成した。
  - `PYTHONPATH="$PWD" make check-docs`: 成功。生成物が未コミットのため、一時ディレクトリ内のインデックスとオブジェクト領域に今回の生成物を比較基準として置き、再生成後の差分ゼロを確認した。実リポジトリのインデックス・オブジェクト・設定は変更せず、実行前後の Git 状態が一致することも確認した。
  - `PYTHONPATH="$PWD" make -o encode-jananese-filename check-style`: 成功。`make check-style` の前提ターゲットが Git 設定を書き換えるため、その前処理だけを除外して既存の全件 flake8 と Ruff を実行した。未追跡の追加テストも `flake8 tools/make_docs/test_make_docs.py` と `ruff check tools/make_docs` で検査し、成功した。
  - `PYTHONPATH="$PWD" make test`: 1,829件成功。
- 未解決事項なし。個票のステータス項目と登録簿の行、result は変更していない。

### orchestrator の確認（2026-10-31、specdojo-orchestrator）

- `openfisca-japan` の `feature/parameter-unit-metadata`（`896ba88`）を一時的な worktree に取り出し、`PYTHONPATH` で worktree のコードを読ませて流した。`make docs` は生成物に差を出さず、単位のない数値のパラメータの警告も出なかった。`make check-docs`・`make check-style`・`make test`（1829 件）と、`tools/make_docs/test_make_docs.py`（6 件）が通った。
- 生成物の表示を確かめた。`0.183` → `18.3%`、`0.0055` → `0.55%`、`0.1` → `10%`、年齢は `18 歳`、日数は `30 日`、学年は `12 学年`、人数は `3 人`、金額は `28,840 円`。浮動小数点の誤差は出ていない。
- 上流の変更に登録簿の ID やリンクはない（commit メッセージの `Refs:` 行を除く）。
- 注意: `test_make_docs.py` は `make test`（`openfisca test`）にも CI にも含まれず、手で流す必要がある。executor は、`Makefile` を変えない判断と、流し方（`python -m unittest discover -s tools/make_docs`）を記録している。CI に入れるかは別に判断する。

## 5. 関連ドキュメント

- 先行の項目: PJR-KS3C（パラメータの YAML の単位の誤りを直す）
