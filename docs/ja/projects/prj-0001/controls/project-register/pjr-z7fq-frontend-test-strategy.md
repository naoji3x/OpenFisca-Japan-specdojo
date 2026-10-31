---
specdojo:
  id: prj-0001:pjr-z7fq-frontend-test-strategy
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: decision
  item_status: open
  priority: high
  owner: naoji
  registered_at: "2026-10-31T04:05:22Z"
  due_on: "2026-11-30"
---

# PJR-Z7FQ フロントエンドのテストの方針を決める（単体テスト中心、E2E は Playwright）

## 1. 背景

`../OpenFisca-Japan` の `dashboard` は、Vite 2.9・React 18・Chakra UI 2・Cypress 12 などの依存が古く、バージョンアップを控えている。更新で壊れたことに気づくための回帰テストが要るが、今のテストはロジックだけの Vitest 4 ファイルと、開始画面までの Cypress 3 シナリオしかない。cypress-axe は読み込まれているが、検査は呼ばれていない。

テストをどの層で書き、どの道具を使うかを、依存の更新に着手する前に決める。

## 2. 検討した選択肢

| 選択肢 | 内容                                                                        | 利点                                                                                              | 懸念                                                                                             |
| ------ | --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| A      | Cypress を最新に上げ、E2E を拡充して回帰を守る                              | 今の構成のまま進められる                                                                          | E2E は遅く不安定になりやすく、依存の更新のたびに流す負担が大きい。並列実行は有料のサービスが前提 |
| B      | 単体テストと画面のテストで品質を保証し、E2E は Playwright のスモークに限る  | 速く安定した検査で更新を守れる。Playwright は複数のブラウザー・並列実行・`webServer` を標準で持つ | Cypress の 3 シナリオを移す手間がある（fixture がなく少量）                                      |
| C      | B に加え、画面のテストを Storybook と addon-vitest で実際のブラウザーで流す | jsdom との差がなく、story ごとに a11y の検査も流せる                                              | Storybook 10 は Vite 5 以上・Vitest 4 以上を要し、今の Vite 2.9 では入れられない                 |

## 3. 決定内容

B を採り、Vite と Vitest の更新後に C へ進む。

- 品質は単体テスト（ロジック）と画面のテストで保証し、E2E に頼らない。
- 画面のテストは、依存の更新前は Vitest と jsdom、Testing Library で書く。Vite と Vitest の更新後に Storybook と `@storybook/addon-vitest` へ移し、a11y の検査も story で流す。
- E2E は Cypress から Playwright に移し、主要な導線のスモーク（トップの表示、かんたん見積もり・くわしく見積もりを 1 本ずつ結果まで）に限る。API の失敗などの分岐は画面のテストで固定する。

## 4. 採択理由

- 依存の更新を何度も重ねるため、速く安定した検査で守るほうが手戻りが少ない。
- 今の E2E は 3 シナリオで fixture もなく、Playwright へ移す手間が小さい。
- Storybook を今すぐ入れると Vite の更新を先に行う必要があり、更新の前に回帰を守る網がなくなる。jsdom で先に書いておけば、描画用のヘルパーと固定データを story に使い回せる。

## 5. 承認

| 項目     | 内容                                                                       |
| -------- | -------------------------------------------------------------------------- |
| 決定者   | naoji                                                                      |
| 決定日   | 2026-10-31                                                                 |
| 承認方式 | commit                                                                     |
| 証跡     | 会話での承認（2026-10-31）。この個票を `decided` にした register の commit |

- 承認方式は `commit` または `PR` を記載する。`PR` の場合は証跡に PR URL と merge SHA を本文テキストで記載する。
- 不可逆・高リスク・framework schema 破壊的変更に該当する決定は `PR` 方式で承認する。

## 6. 影響範囲とフォローアップ

| 項目       | 内容                                                                                                                                                                                                                                                                                                                                             |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 影響範囲   | `openfisca-japan:dashboard/` のテスト構成、CI の `test_frontend.yml`、`docs/dev_note.md` のフロントエンドの節                                                                                                                                                                                                                                    |
| 必要な対応 | PJR-49V3・PJR-BZGG・PJR-1RJE・PJR-DFWV を実施する。ローカルで下書きした PJR-HDQ7・PJR-EHRG は PJR-1RJE に置き換える。PJR-PP9D・PJR-2CSW・PJR-0HYV・PJR-BSXA を起票するときは、完了条件の Cypress の記述を Playwright と story のテストに書き換え、PJR-0HYV の前提を PJR-EHRG から PJR-1RJE に付け替える。PJR-DFWV に PJR-PP9D の前後関係を付ける |
| 追跡先     | PJR-49V3、PJR-BZGG、PJR-1RJE、PJR-DFWV                                                                                                                                                                                                                                                                                                           |

## 7. 関連ドキュメント

- 起点: `openfisca-japan:tmp/dev_analysis.md`（ローカルの調査メモ）と、ローカルで下書きした `local/pjr-*.md` の 8 件。
- 実施項目: [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]]、[[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]]、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]]、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]]
- Storybook の Vitest addon: <https://storybook.js.org/docs/writing-tests/integrations/vitest-addon>
