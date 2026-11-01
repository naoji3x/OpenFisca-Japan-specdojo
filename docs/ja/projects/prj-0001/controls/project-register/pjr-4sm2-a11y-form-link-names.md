---
specdojo:
  id: prj-0001:pjr-4sm2-a11y-form-link-names
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: issue
  item_status: in-progress
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

- `openfisca-japan:dashboard/src/components/questions/template/personNumQuestionTemplate.tsx` の人数入力欄に `aria-label="人数"` を追加した。通常入力と復元時、PC のテキスト入力とモバイルの数値入力に共通で適用される。
- `openfisca-japan:dashboard/src/components/homeButton.tsx` の共通ホームリンクに `aria-label="トップへ戻る"` を追加した。エラー画面・結果画面など、同じコンポーネントを利用する画面へ適用される。既存の文字リンク「トップページに戻る」と区別できる名前にした。
- 見た目を保つため、両方とも見えない名前を追加した。DOM の配置・スタイル・入力や遷移の処理は変更していない。依存の追加・変更や `npm ci` は行っていない。上流の変更はこの 2 ファイルの属性追加だけであり、登録簿の ID やリンクは含めていない。
- dashboard で `npm run test`（6 ファイル・937 件）、`npm run build`、`npm run lint`、`npm run pretty:check` が成功した。ビルドではチャンクサイズの警告が出たが、終了コードは 0 だった。
- `npm run test:ui` は Storybook 設定読み込み中の `uv_interface_addresses` エラーで起動できなかった。`npm run test:e2e` も preview サーバーを起動できず、同じサーバーコマンドで `listen EPERM: operation not permitted 0.0.0.0:30000` を確認した。いずれも sandbox の制約によるため `requires_human` とする。
- 申し送り: 統合後、orchestrator が dashboard で `npm run test:ui`（storybook project を含む）と `npm run test:e2e` を再実行する。Storybook の a11y report で `questions-templates--person-count`・`restored-person-count` の `label` と、ホームリンクに起因する 6 story の `link-name` が消えたことを確認する。ブラウザー検証が起動できていないため、違反解消と実画面の表示はまだ未確認である。

## 6. 関連ドキュメント

- 発見元: [[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]] の「a11y の違反の一覧」
