---
specdojo:
  id: prj-0001:pjr-4sm2-a11y-form-link-names
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: issue
  item_status: open
  priority: high
  difficulty: easy
  owner: DEV
  registered_at: "2026-10-31T21:31:53Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-DFWV
---

# PJR-4SM2 人数の入力欄のラベルとトップへ戻るリンクの名前を付ける（a11y）

## 1. 課題内容

a11y の検査で、人数の入力欄にラベルがない（label・critical、2 story）ことと、トップへ戻るリンクに名前がない（link-name・serious、6 story）ことが見つかった。dashboard のコードで直す

## 2. 入力

<!-- 対話で得た前提・制約・委任範囲を記録する。完了・回答の判定条件とは分ける。 -->

- 2026-10-31 に naoji が、a11y の違反の修正を推奨どおり起票することを承認した。担当・優先度・期限は specdojo-orchestrator の推奨（担当 DEV、期限 2026-11-30）。

### 2.1. 実行の前提（2026-11-01、specdojo-orchestrator）

- 対象は `feature/frontend-test-upgrade` の先頭（2026-11-01 時点は `378eb36`）に積む。依存の追加は要らない見込みである。executor は依存を追加・変更せず、`npm ci` も流さない（ネットワークに出られない）。
- 違反の場所（2026-11-01 時点、axe-core）: `label` は story の `questions-templates--person-count`・`restored-person-count` の人数の入力欄。`link-name` は 6 story（エラー画面・結果画面など）のトップへ戻るリンク（`a[href="/"]`）。
- a11y の違反の有無は、story のテスト（`npx vitest run --config vitest.browser.config.mts --project storybook`）の report で確かめられる。サンドボックスでブラウザーのテストを流せない場合は `requires_human` としてよく、統合のあとに orchestrator が流して違反がなくなったことを確かめる。
- 見た目を変えない（ラベルは見えるものを足すか、`aria-label` などの見えない名前にするかを executor が決め、理由を記録する）。
- 上流の文書・コードに、登録簿の ID やリンクを書かない。Git の設定と commit には触れない。

## 3. 影響範囲

| 観点         | 影響                                                                                                                                                           |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| スコープ     | `openfisca-japan:dashboard/src/components/questions/template/personNumQuestionTemplate.tsx` の入力欄、トップへ戻るリンクを持つ画面（エラー画面・結果画面など） |
| スケジュール | Chakra UI の更新（PJR-BSXA）とは独立しており、先に直せる                                                                                                       |
| コスト       | 小さい（ラベルと `aria-label` などの追加）                                                                                                                     |
| 品質         | スクリーンリーダーで人数の入力欄とトップへ戻るリンクの目的が伝わらない                                                                                         |
| 関係者       | DEV                                                                                                                                                            |

## 4. 対応方針

| 項目     | 内容                                                                                                                                                                                                                                           |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 原因     | 人数の入力欄に関連付けたラベルがなく、トップへ戻るリンクが画像やアイコンだけで中身の文字がない（axe の `label`・`link-name`）                                                                                                                  |
| 対応策   | 入力欄にラベル（`FormLabel` か `aria-label`）を付け、リンクに読み上げる名前を付ける                                                                                                                                                            |
| 依存事項 | なし。`feature/frontend-test-upgrade` の上に積む                                                                                                                                                                                               |
| 完了条件 | 該当する story で `label` と `link-name` の違反がなくなり、`npm run test`・`test:ui`・`build`・`lint`・`pretty:check`・`test:e2e` が通る。違反の有無は orchestrator が統合のあとに確かめる。上流の文書とコードに登録簿の ID やリンクを書かない |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 発見元: [[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]] の「a11y の違反の一覧」
