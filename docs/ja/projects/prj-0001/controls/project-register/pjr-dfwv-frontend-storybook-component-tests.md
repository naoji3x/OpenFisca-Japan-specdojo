---
specdojo:
  id: prj-0001:pjr-dfwv-frontend-storybook-component-tests
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
  registered_at: "2026-10-31T04:05:54Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-Z7FQ
    - PJR-49V3
  depends_on:
    - PJR-PP9D
---

# PJR-DFWV Storybook を導入し、画面のテストを story で流す

## 1. 概要

Vite と Vitest の更新後に Storybook と `@storybook/addon-vitest` を導入し、画面のテストを story として実際のブラウザーで流す。a11y の検査も story で流し、E2E に頼らない構成にする（[[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ]]）。

## 2. 完了条件

- 着手の時点で、Storybook の最新版が求める Vite・Vitest・Node の版を公式の情報で確かめ、採る版と理由を「4. 対応結果」に記録する。2026-10-31 時点では、Storybook 10.6 の `@storybook/react-vite` は Vite 5 以上、`@storybook/addon-vitest` は Vitest 4 以上と `@vitest/browser-playwright` を要する。
- Storybook、`@storybook/addon-vitest`、`@storybook/addon-a11y` を導入し、story を Vitest のブラウザーモード（Playwright の Chromium）で流す。
- [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]] と [[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]] の画面のテストのうち、実際のブラウザーで確かめる価値のあるものを、story と play 関数に移す。どれを移すか、移したあとの jsdom 版を消すか残すかの基準は executor が決め、理由を「4. 対応結果」に記録する。同じ確認を二重に持たない。
- story は PJR-49V3 の描画用のヘルパーと固定データを使う。API の応答は `msw-storybook-addon` で、[[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]] の `dashboard/src/mocks/handlers.ts` を使う。
- story にしない画面のテストで実際のブラウザーが要るものは、Vitest Browser Mode（`vitest-browser-react`）で書けるようにする。jsdom のままにするか Browser Mode に移すかは executor が決め、理由を「4. 対応結果」に記録する。ロジックのテストは node 環境のまま変えない。
- Vitest の Test Projects で、単体テスト（node・jsdom）と、story・Browser Mode のテスト（ブラウザー）を分け、それぞれを流すスクリプトを用意する。
- 見た目の回帰テスト（スクリーンショットの比較）はこの項目の範囲の外とする。Chromatic は画面のデータを外部のサービスに送るため使わない。
- 質問テンプレート・結果・エラー画面の story で a11y の検査を流す。見つかった違反はこの項目では直さず、一覧を「4. 対応結果」に記録して別の項目に分ける。
- story のテストを CI で流す段を足す。
- `openfisca-japan:docs/dev_note.md` のフロントエンドの節に、story の書き方と流し方を書く。
- 検証は `dashboard` で `npm run test`、`npm run build`、`npm run lint`、`npm run pretty:check` を実行する。実行したコマンド・環境・成否を「4. 対応結果」に記録する。
- `npm ci` は worktree を作るときに runner が流すため、executor は流さない（executor はネットワークに出られない）。依存が足りない場合は追加せず、要る依存と理由を「4. 対応結果」に書いて止まる。
- exec で実施する場合は、その時点の設定による親の検証も通す。親の検証にフロントエンドの検査が含まれない場合も、この項目で指定した検査は省略しない。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。反映は利用者の承認のもとで行い、反映と検証が終わるまで close しない。
- CHANGELOG を更新する場合は未公開の版の節に書き、公開済みの版の節は変えない。範囲外の問題は別の項目に分ける。

## 3. 作業内容

前提: [[prj-0001:pjr-pp9d-frontend-vite-vitest-upgrade|PJR-PP9D]]（Vite・Reactプラグイン・Vitest の更新）が完了していることを確かめてから着手する。

| No  | 作業                                                                            | 担当 | 状態 | メモ                                   |
| --- | ------------------------------------------------------------------------------- | ---- | ---- | -------------------------------------- |
| 1   | Storybook の要件と、更新後の Vite・Vitest の版が合うことを確かめる              | DEV  | open | -                                      |
| 2   | Storybook と addon を導入し、Provider と固定データを story から使えるようにする | DEV  | open | 依存の追加は保護された設定の扱いに従う |
| 3   | 画面のテストを story に移し、a11y の検査を流す                                  | DEV  | open | -                                      |
| 4   | CI と `docs/dev_note.md` を書き換え、検証を流す                                 | DEV  | open | CI は保護された設定の扱いに従う        |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 方針: [[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ フロントエンドのテストの方針を決める]]
- 対象リポジトリ: `openfisca-japan`（`../OpenFisca-Japan`）、対象ディレクトリ: `dashboard/`、`.github/workflows/`
- 先行の項目: [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]]、[[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]]、[[prj-0001:pjr-pp9d-frontend-vite-vitest-upgrade|PJR-PP9D]]
- 後続の項目: [[prj-0001:pjr-2csw-frontend-typescript-eslint-upgrade|PJR-2CSW]]
- Storybook の Vitest addon: <https://storybook.js.org/docs/writing-tests/integrations/vitest-addon>
