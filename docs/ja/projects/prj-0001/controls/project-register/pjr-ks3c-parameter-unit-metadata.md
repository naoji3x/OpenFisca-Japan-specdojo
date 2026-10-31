---
specdojo:
  id: prj-0001:pjr-ks3c-parameter-unit-metadata
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
  priority: high
  difficulty: easy
  owner: BA
  registered_at: "2026-10-31T03:00:17Z"
  due_on: "2026-11-30"
---

# PJR-KS3C パラメータの YAML の単位の誤りを直す

## 1. 概要

`feature/institution-docs` で公開した制度ドキュメント（パラメータ一覧）について、単位が誤っているとの指摘を受けた。原因は、生成元である `../OpenFisca-Japan` のパラメータの YAML の `metadata.unit` に誤りと抜けがあることである。BA が YAML を手で直す。

## 2. 完了条件

- 「3.1. 直す箇所」の 34 ファイルが、表のとおりに直っている。
- `上限学年` の 2 ファイルの単位について、決めた値と理由が「4. 対応結果」に記録されている。
- `make docs` で `docs/_data` を作り直し、YAML の修正と同じ commit に入れている。CI の `make check-docs` が生成物との差を検出するため。
- `make test` と `make check-docs` が通る。
- パラメータの一覧のページで、3.1.2 の金額が「28,840 円」のように「円」付きで表示される。
- `feature/openfisca-hot-reload` の `make serve-dev` を起動したまま 3.1 の修正を当てると、サーバーが自動で再起動し、API の `metadata.unit` が修正後の値に変わる。確かめた結果は「4. 対応結果」に記録する。

## 3. 作業内容

| No  | 作業                                                     | 担当 | 状態 | メモ                                                 |
| --- | -------------------------------------------------------- | ---- | ---- | ---------------------------------------------------- |
| 1   | `../OpenFisca-Japan` で `develop` から作業ブランチを切る | BA   | open | ブランチ名の例: `fix/parameter-units`                |
| 2   | 3.1 の 34 ファイルを直す                                 | BA   | open | -                                                    |
| 3   | `make docs` / `make test` / `make check-docs` を流す     | BA   | open | -                                                    |
| 4   | 3.2 の手順で hot-reload を確かめる                       | BA   | open | -                                                    |
| 5   | 作業ブランチを commit し、PR を出す                      | BA   | open | commit メッセージに `Refs: prj-0001:PJR-KS3C` を書く |

### 3.1. 直す箇所

基準は `../OpenFisca-Japan` の `develop`（`823818e`）である。行番号はこの版のものである。

#### 3.1.1. 率なのに単位が `currency-JPY` になっている（7 件）

4 行目の `unit: currency-JPY` を `unit: /1` にする。同じ率の `openfisca_japan/parameters/福祉/育児/高等教育の修学支援新制度/減免額算定基準額の税率.yaml` は、すでに `unit: /1` になっている。

```yaml
# 修正前
metadata:
  reference: ...
  unit: currency-JPY
# 修正後
metadata:
  reference: ...
  unit: /1
```

| No  | ファイル                                                      |
| --- | ------------------------------------------------------------- |
| 1   | `openfisca_japan/parameters/住民税/標準税率.yaml`             |
| 2   | `openfisca_japan/parameters/所得/復興特別所得税率.yaml`       |
| 3   | `openfisca_japan/parameters/所得/超過所得割合.yaml`           |
| 4   | `openfisca_japan/parameters/社会保険料/介護保険料率.yaml`     |
| 5   | `openfisca_japan/parameters/社会保険料/健康保険料率.yaml`     |
| 6   | `openfisca_japan/parameters/社会保険料/厚生年金保険料率.yaml` |
| 7   | `openfisca_japan/parameters/社会保険料/雇用保険料率.yaml`     |

#### 3.1.2. 金額なのに単位がない（23 件）

3〜4 行目の `threshold_unit: person` と `rate_unit: 1` を削除し、`unit: currency-JPY` を追加する。この 2 つのキーは累進税率表（Scale）用であり、ふつうの Parameter には意味がない。

```yaml
# 修正前
metadata:
  threshold_unit: person
  rate_unit: 1
  reference: ...
# 修正後
metadata:
  reference: ...
  unit: currency-JPY
```

| No  | ファイル                                                                                                                            |
| --- | ----------------------------------------------------------------------------------------------------------------------------------- |
| 1   | `openfisca_japan/parameters/東京都/福祉/重度心身障害者手当/所得制限限度額.yaml`                                                     |
| 2   | `openfisca_japan/parameters/災害/支援/災害援護資金/所得制限額.yaml`                                                                 |
| 3   | `openfisca_japan/parameters/災害/支援/災害援護資金/所得制限額_一人当たり追加額.yaml`                                                |
| 4   | `openfisca_japan/parameters/災害/支援/災害援護資金/所得制限額_住居が滅失した場合.yaml`                                              |
| 5   | `openfisca_japan/parameters/福祉/感染症/健康管理支援事業/支給額.yaml`                                                               |
| 6   | `openfisca_japan/parameters/福祉/感染症/健康管理費用/支給額_最大.yaml`                                                              |
| 7   | `openfisca_japan/parameters/福祉/感染症/健康管理費用/支給額_最小.yaml`                                                              |
| 8   | `openfisca_japan/parameters/福祉/感染症/先天性の傷病治療によるC型肝炎患者に係るQOL向上等のための調査研究事業/調査研究協力謝金.yaml` |
| 9   | `openfisca_japan/parameters/福祉/特別障害者手当/所得制限限度額/扶養義務者.yaml`                                                     |
| 10  | `openfisca_japan/parameters/福祉/特別障害者手当/所得制限限度額/扶養義務者_老人扶養親族加算額.yaml`                                  |
| 11  | `openfisca_japan/parameters/福祉/特別障害者手当/所得制限限度額/本人.yaml`                                                           |
| 12  | `openfisca_japan/parameters/福祉/特別障害者手当/所得制限限度額/本人_特定扶養親族加算額.yaml`                                        |
| 13  | `openfisca_japan/parameters/福祉/特別障害者手当/所得制限限度額/本人_老人扶養親族加算額.yaml`                                        |
| 14  | `openfisca_japan/parameters/福祉/特別障害者手当/支給額.yaml`                                                                        |
| 15  | `openfisca_japan/parameters/福祉/育児/児童扶養手当/所得制限限度額/一部支給.yaml`                                                    |
| 16  | `openfisca_japan/parameters/福祉/育児/児童扶養手当/所得制限限度額/全部支給.yaml`                                                    |
| 17  | `openfisca_japan/parameters/福祉/育児/児童扶養手当/所得制限限度額/扶養義務者.yaml`                                                  |
| 18  | `openfisca_japan/parameters/福祉/育児/児童育成手当/所得制限限度額.yaml`                                                             |
| 19  | `openfisca_japan/parameters/福祉/育児/特別児童扶養手当/所得制限限度額/受給者.yaml`                                                  |
| 20  | `openfisca_japan/parameters/福祉/育児/特別児童扶養手当/所得制限限度額/扶養義務者.yaml`                                              |
| 21  | `openfisca_japan/parameters/福祉/育児/障害児福祉手当/所得制限限度額/受給者.yaml`                                                    |
| 22  | `openfisca_japan/parameters/福祉/育児/障害児福祉手当/所得制限限度額/扶養義務者.yaml`                                                |
| 23  | `openfisca_japan/parameters/福祉/育児/障害児童育成手当/所得制限限度額.yaml`                                                         |

#### 3.1.3. 日数なのに単位がない（2 件）

3.1.2 と同じく 3〜4 行目の 2 つのキーを削除し、`unit: day` を追加する。

| No  | ファイル                                                      |
| --- | ------------------------------------------------------------- |
| 1   | `openfisca_japan/parameters/福祉/傷病手当金/日数_会社員.yaml` |
| 2   | `openfisca_japan/parameters/福祉/傷病手当金/日数_公務員.yaml` |

#### 3.1.4. 学年なのに単位が `year` になっている（2 件）

値は小学 1 年生から数えた学年であり、年齢ではない。4 行目の `unit: year` を直す。

- 直したあとの値: _UNDECIDED_。OpenFisca には学年を表す標準の単位がない。`unit` を削除する案と、独自の単位を書く案がある。決めた値と理由は「4. 対応結果」に記録する。

| No  | ファイル                                                          |
| --- | ----------------------------------------------------------------- |
| 1   | `openfisca_japan/parameters/福祉/育児/児童扶養手当/上限学年.yaml` |
| 2   | `openfisca_japan/parameters/福祉/育児/児童育成手当/上限学年.yaml` |

### 3.2. hot-reload での確かめ方

`feature/openfisca-hot-reload` の `make serve-dev` は、watchmedo で `openfisca_japan` の下の `.py`・`.yaml`・`.csv` を見張り、変更があるとサーバーを再起動する。OpenFisca の API の `GET /parameter/<パス>` は `metadata` をそのまま返すため、`unit` の修正がサーバーを止めずに反映されたかを応答で確かめられる。`<作業ブランチ>` は、3 の No 1 で切ったブランチ（例: `fix/parameter-units`）に読み替える。

1. 衝突がないことを確かめる。次のコマンドで衝突が出ないこと。

   ```bash
   git merge-tree --write-tree feature/openfisca-hot-reload <作業ブランチ>
   ```

2. 準備する。`feature/openfisca-hot-reload` に切り替え、作業ツリーに変更がないことを確かめる。リポジトリの外で import 先を確かめ、ワークスペースの `openfisca_japan/__init__.py` が表示されること。違う場所が表示された場合は、`docs/devcontainer_note.md` の「バックエンドのホットリロード（editable install）」の手順で戻す。`watchmedo` がなければ `sudo make install` を流す。

   ```bash
   git switch feature/openfisca-hot-reload
   git status --short
   (cd /tmp && python -c "import openfisca_japan; print(openfisca_japan.__file__)")
   watchmedo --help > /dev/null || sudo make install
   ```

3. ターミナル 1 でサーバーを起動する。

   ```bash
   make serve-dev
   ```

4. ターミナル 2 で、直す前の値を記録する。健康保険料率は `unit` が `currency-JPY`、特別障害者手当の支給額と傷病手当金の日数は `threshold_unit` があり `unit` がないこと。

   ```bash
   show() { curl -s "http://localhost:50000/parameter/$1" | python3 -c "import json,sys; print(json.load(sys.stdin)['metadata'])"; }
   show 社会保険料/健康保険料率
   show 福祉/特別障害者手当/支給額
   show 福祉/傷病手当金/日数_会社員
   ```

5. 修正だけを取り込む。ターミナル 1 で、数秒のうちにサーバーが再起動すること。

   ```bash
   git checkout <作業ブランチ> -- openfisca_japan/parameters
   ```

6. 4 と同じ 3 つを取得し、`unit` がそれぞれ `/1`・`currency-JPY`・`day` に変わり、`threshold_unit` と `rate_unit` がないこと。
7. 元に戻す。ターミナル 1 で `Ctrl+C` を押してサーバーを止め、hot-reload のブランチを元の状態に戻す。`git status --short` で変更がないこと。

   ```bash
   git restore --source=HEAD --staged --worktree openfisca_japan/parameters
   git status --short
   ```

「4. 対応結果」には、再起動にかかった秒数、4 と 6 の `unit` の値、1 の衝突の有無を記録する。

## 4. 対応結果

-

## 5. 関連ドキュメント

- 後続の項目: PJR-1W29（制度ドキュメントの生成で率と年齢の単位を表示する）
- 生成スクリプト: `openfisca-japan:tools/make_docs/make_docs.py`（`format_number` が `currency-JPY` と `人` だけを扱う）
