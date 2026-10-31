---
specdojo:
  id: prj-0001:pjr-bzgg-frontend-result-error-regression
  type: project
  status: ready
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: done
  priority: high
  difficulty: medium
  owner: DEV
  registered_at: "2026-10-31T04:05:40Z"
  due_on: "2026-11-30"
  completed_at: "2026-10-31T12:13:37Z"
  conclusion: MSW で計算 API を HTTP の境界で差し替え、結果・エラー画面と計算 API の呼び出しのテスト 27 件と固定データを整えた（openfisca-japan の a99c1c9）
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

| No  | 作業                                                                                        | 担当 | 状態 | メモ                                            |
| --- | ------------------------------------------------------------------------------------------- | ---- | ---- | ----------------------------------------------- |
| 1   | 今の画面の表示条件と遷移を調べ、固定の応答と期待結果を整理する                              | DEV  | done | 4 種類の表示とモード別の戻り先を確認            |
| 2   | MSW の handlers と固定データを整え、結果・エラー画面と計算 API の呼び出しのテストを追加する | DEV  | done | 共通 handlers、JSON 8 ファイル、27 テストを追加 |
| 3   | 既存のテストを含めて検証を流す                                                              | DEV  | done | 全 967 件と build・lint・pretty:check に成功    |

## 4. 対応結果

### 実施内容

- 個票の完了条件を作業基準とし、先行の [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]] が `done` であることと、描画用ヘルパー・既存 940 件のテスト基盤を確認して着手した。
- MSW 2.15.0 の `http.post` と `HttpResponse` で `/calculate` を模擬した。`fetch` の直接の模擬は行っていない。共通の `dashboard/src/mocks/handlers.ts` は正常応答 4 種類の factory と HTTP 500・通信失敗の handlers を公開し、node 固有の依存を持たず、後続の story でも利用できる。
- `dashboard/src/mocks/server.ts` に node 用の server を置き、既存の `src/testSetup.ts` で起動・テストごとの handlers リセット・終了を登録した。未定義の通信はエラーにする。既存のロジックと共有リンクのテストは node 環境のまま、新規の 3 ファイルはファイル単位の jsdom 指定で動く。
- 先行の `questionTemplateTestUtils.tsx` の Provider ヘルパーを `renderWithProviders` として共用し、既存の `renderQuestion` 呼び出しを維持した。任意の Recoil 初期化を追加し、`src/mocks/resultTestUtils.tsx` で Router と固定日・世帯を設定する。描画ごとに新しい RecoilRoot を作り、終了時に cleanup し、API テストの通信監視・環境変数も毎回解除する。
- `docs/dev_note.md` のフロントエンド節だけに、handlers と固定データの使い方、`docker compose` と `curl` による同一 POST 本文からの再記録、照合するフィールド、差分時の対応を追記した。追加節だけを Prettier で整形し、既存部分の書式は維持した。
- 実装の振る舞い、既存のテスト 5 ファイル（共有リンクの互換性テストを含む）、依存、lockfile、`package.json`、CI 設定は変更していない。追加の依存や保護された設定への変更案はない。CHANGELOG は変更していない。

### 固定データの作り方と表示の期待値

`openfisca-japan:dashboard/src/mocks/calculate/` の各ケースに `*.request.json` と `*.response.json` の組を置いた。`calculateFixtures.ts` に固定日・ケース一覧・モードの期待値を分離した。日付は `2026-01-15`、居住地は東京都渋谷区、親は「あなた」、給付ありのケースには子どもを設定した。POST 本文は世帯員・世帯一覧・親子の配列・日付付きの収入と居住地を含み、計算を依頼する 5 フィールドは `null` にする。

応答は実 API の記録ではなく、`hooks/calculate.ts` の JSON 保存と `Benefit`・`Loan`・`EmptyResults` が読む構造に合わせて手作りした。POST 本文を複製し、`世帯一覧.世帯1` の計算フィールドだけを数値にした。給付ありは `児童手当` 15,000 円、`児童扶養手当_最小` 10,000 円・`児童扶養手当_最大` 45,000 円、貸付ありは `生活支援費` 150,000 円・`緊急小口資金` 200,000 円、それぞれ該当なしなら 0 とした。実際の制度の適格性・金額を保証する固定データではない。

| ケース         | 給付の表示                                                     | 貸付の表示                                                                        | 対象なしの案内             |
| -------------- | -------------------------------------------------------------- | --------------------------------------------------------------------------------- | -------------------------- |
| `benefit-only` | 給付の見出し、児童手当 1.5 万円/月、児童扶養手当 1~4.5 万円/月 | 見出し・制度ボタンともに非表示                                                    | 非表示                     |
| `loan-only`    | 見出し・制度ボタンともに非表示                                 | 貸付の見出し・生活福祉資金貸付制度、生活支援費 ~15 万円/月、緊急小口資金 ~20 万円 | 非表示                     |
| `both`         | `benefit-only` と同じ                                          | `loan-only` と同じ                                                                | 非表示                     |
| `none`         | 見出し・制度ボタンともに非表示                                 | 見出し・制度ボタンともに非表示                                                    | 理由の案内と応援の文を表示 |

### 追加したテスト

| ファイル（`openfisca-japan:dashboard/` 配下） | 件数 | 確認内容                                                                                                                                                                                                                                                                     |
| --------------------------------------------- | ---- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `src/hooks/calculate.test.tsx`                | 9    | 正常 4 種類の応答を保存。HTTP 境界で POST の URL・method・Content-Type・本文を検査。明示呼び出し前と世帯なしでは通信しない。500 の status・body を含む例外と通信失敗の例外を確認。再計算でリクエストの `null` を維持し、失敗時は前の成功結果を保持し、次の成功では置き換える |
| `src/components/result/result.test.tsx`       | 10   | 実際の Result と hook を組み合わせ、正常 4 種類の表示・非表示・万円への換算と範囲・月額と一時金を確認。500・通信失敗それぞれを 3 モードで再現し、エラー画面への遷移と戻るリンクの実クリックを確認                                                                            |
| `src/components/errors/errors.test.tsx`       | 8    | GenericError・NotFoundError の文言とトップへ戻る操作。FormResponseError の 3 モードの既定の戻り先、くわしくの明示 redirect、かんたん・災害でのモード優先を確認                                                                                                               |

`FormResponseError` の既定の戻り先は、かんたんが `/calculate-simple`、くわしくが `/calculate`、災害が `/calculate-disaster`。一方、現在の `Result` は API 失敗時に `redirect: '/'` を渡すため、くわしくの API 失敗後はトップ `/` に戻る。これを別のケースとして固定した。

### 検証

実行環境: 2026-10-31、Linux の task worktree、Node.js v22.23.3、npm 10.9.9、Vitest 3.2.4、Vite 2.9.13、MSW 2.15.0、jsdom 30.1.3。runner が導入済みの依存だけを使い、`npm ci` は実行していない。

| 実行場所                    | コマンド                                                                                                                                           | 結果                                                                                        |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| `openfisca-japan:dashboard` | `npm run test`                                                                                                                                     | 成功。8 ファイル・967 件（既存 940 件と追加 27 件）。既存の共有リンクの 15 件も変更せず成功 |
| `openfisca-japan:dashboard` | `npm run build`                                                                                                                                    | 成功。既存の 500 KiB 超のバンドルサイズ警告のみ                                             |
| `openfisca-japan:dashboard` | `npm run lint`                                                                                                                                     | 成功                                                                                        |
| `openfisca-japan:dashboard` | `npm run pretty:check`                                                                                                                             | 成功                                                                                        |
| `openfisca-japan:dashboard` | `npm run pretty`                                                                                                                                   | pre-commit 相当の整形に成功                                                                 |
| project                     | `node tools/specdojo-pre-commit.mjs prettier docs/ja/projects/prj-0001/controls/project-register/pjr-bzgg-frontend-result-error-regression.md`     | 成功                                                                                        |
| project                     | `node tools/specdojo-pre-commit.mjs markdownlint docs/ja/projects/prj-0001/controls/project-register/pjr-bzgg-frontend-result-error-regression.md` | 成功                                                                                        |
| project                     | `node tools/specdojo-pre-commit.mjs register-build`                                                                                                | sandbox の `spawnSync git EPERM` により実行不可。ホスト側の runner に申し送る               |

project に `catalog_path`、schema 検証 script、typecheck script、`test:unit` script はなく、`test` は初期化時の仮置きのため非適用。product に typecheck・`test:unit` の独立した script はなく、指定の build と test で検査した。product の Markdown 用 lint 依存は未導入で非適用。YAML の変更はなく schema 検証は非適用。`specdojo index build` と result の編集は runner / reporter に委ねた。

### 申し送り

- 統合後、orchestrator は `docs/dev_note.md` の手順で、4 件の `*.request.json` と同じ本文をローカルの `docker compose` の `openfisca` の `/calculate` に送り、実際の応答を `tmp/calculate-recordings/` に記録する。結果画面が読む世帯・日付・金額・居住地・配列の形を固定応答と比較し、違いがあれば API の版と差分を記録して別項目で対応する。executor はネットワークとローカル API に接続できないため、今回の固定応答は実 API と未照合である。
- runner は sandbox 外で `node tools/specdojo-pre-commit.mjs register-build` を確認する。result の記入・登録簿と個票の状態遷移は reporter / runner が行う。

### orchestrator の確認（2026-10-31、specdojo-orchestrator）

- `openfisca-japan` の `feature/frontend-test-upgrade`（`a99c1c9`）を一時的な worktree に取り出し、`dashboard` で `npm ci`、`npm run test`（8 ファイル・967 件）、`npm run build`、`npm run lint`、`npm run pretty:check` がすべて成功することを確かめた。
- 上流の変更に登録簿の ID やリンクがないこと（commit メッセージの `Refs:` 行を除く）、保護された設定と既存の 5 つのテストのファイルが変わっていないことを確かめた。
- `docs/dev_note.md` の手順で、4 件の `*.request.json` をローカルの API（`docker compose` の `openfisca`）の `/calculate` に送り、実際の応答を記録した。4 件とも 200 で、応答の構造（キーの並び・日付付きの値・配列の形）は固定データと同じだった。金額が 0 でない制度の組み合わせも 4 件とも同じで、給付のみ・貸付のみ・両方・対象なしの出し分けは実際の応答でも変わらない。
- 金額は 3 件で違った（手作りのため）。例: `benefit-only` の児童扶養手当は固定データが 10,000〜45,000 円、実際は 11,010〜46,680 円。`loan-only` の緊急小口資金は固定データが 200,000 円、実際は 100,000 円。`dev_note.md` は応答を手作りと明記しており、テストは表示の出し分けと換算を確かめるものなので、この項目では直さない。実際の応答に置き換えるかは別に判断する。
- 申し送りの、くわしく見積もりの API 失敗後にトップへ戻る挙動は、今の実装として固定された。

## 5. 関連ドキュメント

- 方針: [[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ フロントエンドのテストの方針を決める]]
- 起点: `openfisca-japan:tmp/dev_analysis.md` の 2.2 節・4.1 節・推奨アクション。記載された値は当時の調査値として扱い、確かめ直す。
- 対象リポジトリ: `openfisca-japan`（`../OpenFisca-Japan`）、対象ディレクトリ: `dashboard/`
- 先行の項目: [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]]
- 後続の項目: [[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]]、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]]
