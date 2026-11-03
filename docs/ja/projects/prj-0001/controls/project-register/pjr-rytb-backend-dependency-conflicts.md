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
  owner: DEV
  registered_at: "2026-11-03T01:48:11Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-8V4P
  commit_type: fix
---

# PJR-RYTB バックエンドの依存の食い違いを直す

## 1. 課題内容

make install で入る依存のうち、python-dateutil 4.0.0 が pendulum 2.1.2 の <3.0 に、numexpr 2.14.2 が OpenFisca-Core の numpy <1.25 に合わない。上限のない指定を直す。

## 2. 入力

- PJR-8V4P の作り直しの確認（2026-11-03）で、`../OpenFisca-Japan/.venv` に `make install` で入れ直したあと、`pip check` が次の食い違いを出した。`make test`（1829 件）と `make check-style` は通っている。
  - `pendulum 2.1.2 has requirement python-dateutil<3.0,>=2.6, but you have python-dateutil 4.0.0.`
  - `numexpr 2.14.2 has requirement numpy>=1.26.0, but you have numpy 1.24.4.`
  - `autopep8 1.7.0 has requirement pycodestyle>=2.9.1, but you have pycodestyle 2.7.0.`（`.devcontainer/post-create.sh` の pycodestyle の固定によるもので、この項目では扱わない）
- 上流の `setup.py` の dev extras に `"python-dateutil > 2.8.1"`（上限なし）がある。pendulum 2.1.2 は `python-dateutil (>=2.6,<3.0)` を求める。
- OpenFisca-Core 41.5.7 は `numexpr<3.0,>=2.8.4`・`numpy<1.25,>=1.24.2`・`pendulum<3.0.0,>=2.1.2` を求める。numexpr のどの版から `numpy>=1.26` を求めるかは、まだ確かめていない。
- naoji の依頼で起票した（2026-11-03）。担当と期限は未定。

## 3. 影響範囲

| 観点         | 影響                                                                                                                                 |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------ |
| スコープ     | 上流の `setup.py`（dev extras と、必要なら install_requires）                                                                        |
| スケジュール | なし（テストは通っている）                                                                                                           |
| コスト       | 小さい（依存の指定を直し、入れ直して確かめる）                                                                                       |
| 品質         | 依存の版が上流の想定から外れている。python-dateutil 4 や numexpr 2.14 の変更で、日付や計算の処理が気づかないうちに変わるおそれがある |
| 関係者       | 上流の開発者（`make install` で入れる全員）                                                                                          |

## 4. 対応方針

| 項目     | 内容                                                                                                                                                                                                                               |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 原因     | dev extras の `python-dateutil > 2.8.1` に上限がなく、4.0.0 が入る。OpenFisca-Core の `numexpr<3.0` が、`numpy>=1.26` を求める新しい numexpr を許している（版の境目は未確認）                                                      |
| 対応策   | `setup.py` で python-dateutil に `< 3.0` の上限を付ける。numexpr は、`numpy<1.25` で動く最も新しい版までに上限を付ける（境目を PyPI の metadata で確かめる）                                                                       |
| 依存事項 | なし（上流の PR にする場合は #504 の取り込みのあと）                                                                                                                                                                               |
| 完了条件 | Python 3.11 の新しい仮想環境で `make install` のあと `pip check` が python-dateutil と numexpr の食い違いを出さない。`make test`・`make check-style`・`make check-docs` が通る。上流の文書・コードに登録簿の ID やリンクを書かない |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-8v4p-devcontainer-image|PJR-8V4P]]（「5.3. 作り直しの確認」）
