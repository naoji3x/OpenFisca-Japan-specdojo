---
specdojo:
  id: prj-0001:pjr-bzgg-frontend-result-error-regression
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
  registered_at: "2026-10-31T04:05:40Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-Z7FQ
  depends_on:
    - PJR-49V3
---

# PJR-BZGG 結果・エラー画面と計算 API の呼び出しを単体テストで固定する

## 1. 概要

[[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]] で整えた基盤を使い、給付・貸付・対象なしの結果表示、計算 API の成功と失敗、エラー画面の戻り先を単体テストで固定する。API の失敗の扱いは E2E ではなくこの項目で固定する（[[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ]]）。

## 2. 完了条件

- 給付のみ・貸付のみ・両方・対象なしを固定データで再現し、表示内容と出し分けを確かめる。
- 計算 API（`openfisca-japan:dashboard/src/hooks/calculate.ts` が呼ぶ `/calculate`）は、`fetch` の関数を直接模擬せず、MSW の 2 系で HTTP の境界で差し替える。
  - 応答の定義は `dashboard/src/mocks/handlers.ts` に、Vitest（node）用の設定は `dashboard/src/mocks/server.ts` に置き、Vitest の setup で登録する。[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]] で story からも同じ handlers を使うためである。
  - 正常（給付のみ・貸付のみ・両方・対象なし）、500、通信の失敗の応答で、成功時の結果表示と、失敗時のエラー画面への遷移を確かめる。
- `msw` 2.15.0 は `feature/frontend-test-upgrade` に導入済みである（`5c85d65`）。ほかの依存は追加しない。
- 正常の応答の固定データは、`dashboard/src/mocks/` の下に、送る内容（`/calculate` へ POST する household の JSON）と応答の JSON の組で置く。executor はネットワークに出られずローカルの API に届かないため、応答の JSON は `dashboard/src/hooks/calculate.ts` と結果画面が読む形に合わせて作り、作り方を「4. 対応結果」に書く。統合のあとに orchestrator が、同じ送る内容でローカルの API（`docker compose` の `openfisca`）の実際の応答を記録し直し、結果画面が読むフィールドに違いがないかを確かめる。違いがあれば別の項目で直す。
- 送る内容から応答を記録し直す手順（`curl` の例など）を `openfisca-japan:docs/dev_note.md` のフロントエンドの節に書く。
- `GenericError`・`FormResponseError`・`NotFoundError` の表示と、今の戻る操作を確かめる。`FormResponseError` は、かんたん見積もり・くわしく見積もり・災害のモードの戻り先を確かめる。
- 固定データと描画用のヘルパーは PJR-49V3 のものを使い、新しく足す固定データもテストのファイルから切り離して置く。
- 既存の共有リンクの互換性テストを変えずに通す。
- 検証は `dashboard` で `npm run test`、`npm run build`、`npm run lint`、`npm run pretty:check` を実行する。実行したコマンド・環境・成否を「4. 対応結果」に記録する。
- `npm ci` は worktree を作るときに runner が流すため、executor は流さない（executor はネットワークに出られない）。依存が足りない場合は追加せず、要る依存と理由を「4. 対応結果」に書いて止まる。
- 上流の文書・コード・コメントに、登録簿の ID やリンク（`PJR-XXXX`、`[[prj-0001:…]]`）を書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。PJR-49V3 で `docs/dev_note.md` にリンクが入り、上流では働かなかったためである。
- exec で実施する場合は、その時点の設定による親の検証も通す。親の検証にフロントエンドの検査が含まれない場合も、この項目で指定した検査は省略しない。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。反映は利用者の承認のもとで行い、反映と検証が終わるまで close しない。
- CHANGELOG を更新する場合は未公開の版の節に書き、公開済みの版の節は変えない。範囲外の問題は別の項目に分ける。

## 3. 作業内容

前提: [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]] が完了していることを確かめてから着手する。

| No  | 作業                                                                                        | 担当 | 状態 | メモ |
| --- | ------------------------------------------------------------------------------------------- | ---- | ---- | ---- |
| 1   | 今の画面の表示条件と遷移を調べ、固定の応答と期待結果を整理する                              | DEV  | open | -    |
| 2   | MSW の handlers と固定データを整え、結果・エラー画面と計算 API の呼び出しのテストを追加する | DEV  | open | -    |
| 3   | 既存のテストを含めて検証を流す                                                              | DEV  | open | -    |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 方針: [[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ フロントエンドのテストの方針を決める]]
- 起点: `openfisca-japan:tmp/dev_analysis.md` の 2.2 節・4.1 節・推奨アクション。記載された値は当時の調査値として扱い、確かめ直す。
- 対象リポジトリ: `openfisca-japan`（`../OpenFisca-Japan`）、対象ディレクトリ: `dashboard/`
- 先行の項目: [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]]
- 後続の項目: [[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]]、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]]
