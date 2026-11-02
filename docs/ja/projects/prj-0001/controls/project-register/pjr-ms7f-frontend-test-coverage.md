---
specdojo:
  id: prj-0001:pjr-ms7f-frontend-test-coverage
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: review
  priority: low
  difficulty: easy
  owner: DEV
  registered_at: "2026-11-01T02:31:50Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-BSXA
---

# PJR-MS7F フロントエンドのテストの網羅率を測る

## 1. 概要

フロントエンドのテストは今の動きを固定するもので、網羅率を測っていない。網羅率を測り、テストが薄いところを洗い出す。

## 2. 完了条件

- `@vitest/coverage-v8`（Vitest と同じ版）を入れる（orchestrator が行う）。
- 単体テスト（`unit`）と、story・Browser Mode のテストの網羅率を測り、ファイルごとの結果を「4. 対応結果」に記録する。
- 網羅率が低く、移行や今後の変更で壊れやすいところを洗い出し、テストを足す項目に分ける。この項目では網羅率の目標や CI での強制は決めない（決める場合は理由を記録する）。
- 網羅率を測るスクリプトを足す場合は、`package.json` の変更案を書く（保護された設定）。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合は、変更案を「4. 対応結果」に書き、反映は利用者の承認のもとで行う。依存の追加は、流す前に orchestrator が入れる（exec の executor はネットワークに出られない）。

### 2.1. 実行の前提（2026-11-01、specdojo-orchestrator）

- `@vitest/coverage-v8` 5.0.5（Vitest と同じ版）を `feature/frontend-test-upgrade` に導入済みである（`767f583`）。executor は依存を追加・変更しない。
- orchestrator が試すと、`npx vitest run --project unit --coverage --coverage.reporter=text-summary` で、単体テスト（unit）の網羅率は Statements 90.91%・Branches 78.53%・Functions 90.37%・Lines 90.88% だった。
- この項目では、次を行う。
  - 網羅率の設定（対象と除外、レポートの形式と出力先）を `vite.config.mts` などに書く。出力先は `.gitignore` に入れる。
  - unit と、story・Browser Mode（`vitest.browser.config.mts`）の網羅率を測る。Browser Mode の網羅率がサンドボックスで測れない場合は `requires_human` とし、統合のあとに orchestrator が測る。
  - ファイルごとの結果を「4. 対応結果」に書き、網羅率が低く壊れやすいところを洗い出して、テストを足す項目の案を書く。この項目では、網羅率の目標や CI での強制は決めない。
  - 網羅率を測るスクリプトを足す場合は、`package.json` の変更案を書く。
- executor はネットワークに出られず、サンドボックスではブラウザーや preview・開発サーバーを起動できないことがある（`listen EPERM`）。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。
- `dashboard/package.json` と `.github/workflows/**` は保護された設定である。executor は書き換えず、変更案（差分）を「4. 対応結果」と報告の `handoff` に書く。変更案は未完了の理由にしない。反映は統合のあとに orchestrator が naoji の承認のもとで行う。
- 上流の文書・コードに、登録簿の ID やリンクを書かない。Git の設定と commit には触れない。

## 3. 作業内容

| No  | 作業                               | 担当                  | 状態 | メモ                                                                                     |
| --- | ---------------------------------- | --------------------- | ---- | ---------------------------------------------------------------------------------------- |
| 1   | 依存を入れる                       | specdojo-orchestrator | done | 導入済みの Vitest・coverage-v8 5.0.5 を確認。依存変更なし                                |
| 2   | 網羅率を測り、薄いところを洗い出す | DEV                   | done | unit の全ファイルを計測。UI はサンドボックス制限による `requires_human` として手順を記録 |
| 3   | テストを足す項目に分ける           | DEV                   | done | 優先度・確認内容・テスト層を分けた追加項目案を記録                                       |

## 4. 対応結果

### 4.1. 実施内容と計測範囲（2026-11-01）

- 製品リポジトリの基点は `ca1723a`。インストール済みの Vitest と `@vitest/coverage-v8` はともに 5.0.5。依存の追加・更新は行っていない。
- `openfisca-japan:dashboard/vite.config.mts` と `openfisca-japan:dashboard/vitest.browser.config.mts` のルートの `test.coverage` に V8、対象・除外、レポート形式と出力先を設定した。通常実行では無効で、`--coverage` 指定時に計測する。
- 両者とも `src/**/*.{ts,tsx}` を分母にし、未読込の実装も含める。型宣言、テスト・spec・story、`src/mocks/**`、`src/testSetup.ts`、`*TestUtils.*` は除外する。JSON・CSS・画像と E2E は対象外。窓口の TypeScript 設定データは対象に残す。
- 出力は端末のファイル別一覧、HTML（`index.html`）、JSON（`coverage-summary.json`）。unit は `dashboard/coverage/unit/`、story と Browser Mode の合算は `dashboard/coverage/ui/`。既存の `dashboard/.gitignore` の `/coverage` で全出力先が除外されることを `git check-ignore` で確認済み。生成物はコミット対象に含めない。
- `openfisca-japan:dashboard/COVERAGE.md` に計測範囲、実行方法、別々の UI 計測での出力先指定、数値の読み方を追記した。
- `package.json` の変更は不要。既存の `test:unit`・`test:ui`・`test:stories`・`test:browser` に引数を渡せるため、スクリプトの追加案はない。保護された設定、CI、網羅率の目標・閾値は変更していない。

### 4.2. unit の計測結果

`openfisca-japan:dashboard` で `npm run test:unit -- --coverage` を実行し、6 ファイル・939 テストがすべて成功した。実行時間は 6.39 秒。

| 対象      | Statements          | Branches           | Functions         | Lines               |
| --------- | ------------------- | ------------------ | ----------------- | ------------------- |
| unit 全体 | 58.18%（1148/1973） | 58.06%（734/1264） | 44.84%（161/359） | 57.99%（1135/1957） |

事前計測の Statements 90.91% などは未読込ファイルを分母に含めていない値であり、今回と直接比較できない。今回の低下は計測対象を拡大したことによる。テストや製品の挙動は変更していない。

次表は `coverage/unit/coverage-summary.json` の全 62 エントリを転記したもの。ファイルは `openfisca-japan:dashboard/` からの相対パス。数値は %、`—` は該当カウンターの分母が 0 のため評価対象外。型だけの `src/question.tsx`・`src/state/household.ts`・`src/config/窓口情報形式.ts` も JSON に現れるが、実行可能な文・分岐・関数・行を持たず、集計の分母には寄与しない。

| ファイル                                                                  | Statements | Branches | Functions | Lines |
| ------------------------------------------------------------------------- | ---------- | -------- | --------- | ----- |
| `src/App.tsx`                                                             | 0          | —        | 0         | 0     |
| `src/main.tsx`                                                            | 0          | —        | —         | 0     |
| `src/question.tsx`                                                        | —          | —        | —         | —     |
| `src/state.ts`                                                            | 75         | —        | 0         | 75    |
| `src/components/Description.tsx`                                          | 0          | 0        | 0         | 0     |
| `src/components/PrivacyPolicy.tsx`                                        | 0          | —        | 0         | 0     |
| `src/components/Terms.tsx`                                                | 0          | —        | 0         | 0     |
| `src/components/TermsModal.tsx`                                           | 0          | 0        | 0         | 0     |
| `src/components/homeButton.tsx`                                           | 0          | —        | 0         | 0     |
| `src/components/calculate/calculate.ts`                                   | 0          | 0        | 0         | 0     |
| `src/components/errors/FormResponseError.tsx`                             | 0          | 0        | 0         | 0     |
| `src/components/errors/GenericError.tsx`                                  | 0          | —        | 0         | 0     |
| `src/components/errors/NotFoundError.tsx`                                 | 0          | —        | 0         | 0     |
| `src/components/forms/calculationLabel.tsx`                               | 0          | —        | 0         | 0     |
| `src/components/forms/validation/ErrorMessage.tsx`                        | 100        | 50       | 100       | 100   |
| `src/components/layout/narrowWidth.tsx`                                   | 0          | —        | 0         | 0     |
| `src/components/questions/description.tsx`                                | 0          | 0        | 0         | 0     |
| `src/components/questions/question.tsx`                                   | 0          | 0        | 0         | 0     |
| `src/components/questions/descriptions/spouseExistsButSingleParent.tsx`   | 0          | —        | 0         | 0     |
| `src/components/questions/template/addressQuestionTemplate.tsx`           | 0          | 0        | 0         | 0     |
| `src/components/questions/template/ageQuestionTemplate.tsx`               | 57.14      | 41.46    | 80        | 57.14 |
| `src/components/questions/template/amountOfMoneyQuestionTemplate.tsx`     | 58.97      | 39.47    | 80        | 58.97 |
| `src/components/questions/template/childrenAgeQuestionTemplate.tsx`       | 80.23      | 56.62    | 93.33     | 79.76 |
| `src/components/questions/template/multipleSelectionQuestionTemplate.tsx` | 0          | 0        | 0         | 0     |
| `src/components/questions/template/personNumQuestionTemplate.tsx`         | 76.27      | 63.04    | 91.66     | 76.27 |
| `src/components/questions/template/questionFrame.tsx`                     | 0          | 0        | 0         | 0     |
| `src/components/questions/template/selectionQuestionTemplate.tsx`         | 0          | 0        | 0         | 0     |
| `src/components/questions/template/yesNoQuestionTemplate.tsx`             | 0          | 0        | 0         | 0     |
| `src/components/result/applicable.tsx`                                    | 0          | 0        | 0         | 0     |
| `src/components/result/benefit.tsx`                                       | 0          | 0        | 0         | 0     |
| `src/components/result/emptyResults.tsx`                                  | 0          | 0        | 0         | 0     |
| `src/components/result/externalLinks.tsx`                                 | 0          | 0        | 0         | 0     |
| `src/components/result/helpDesk.tsx`                                      | 0          | 0        | 0         | 0     |
| `src/components/result/loan.tsx`                                          | 0          | 0        | 0         | 0     |
| `src/components/result/loanAccordion.tsx`                                 | 0          | 0        | 0         | 0     |
| `src/components/result/result.tsx`                                        | 0          | 0        | 0         | 0     |
| `src/components/result/shareLink.ts`                                      | 71.42      | 54.54    | 64.28     | 72.34 |
| `src/components/result/sharePresets.ts`                                   | 85.65      | 70.78    | 97.05     | 85.49 |
| `src/components/top/feature.tsx`                                          | 0          | —        | 0         | 0     |
| `src/components/top/linkButton.tsx`                                       | 0          | —        | 0         | 0     |
| `src/components/top/links.tsx`                                            | 0          | —        | 0         | 0     |
| `src/components/top/topPage.tsx`                                          | 0          | 0        | 0         | 0     |
| `src/config/介護.ts`                                                      | 0          | —        | —         | 0     |
| `src/config/仕事.ts`                                                      | 0          | —        | —         | 0     |
| `src/config/出産.ts`                                                      | 0          | —        | —         | 0     |
| `src/config/国民健康保険.ts`                                              | 0          | —        | —         | 0     |
| `src/config/国民年金.ts`                                                  | 0          | —        | —         | 0     |
| `src/config/妊娠.ts`                                                      | 0          | —        | —         | 0     |
| `src/config/子育て.ts`                                                    | 0          | —        | —         | 0     |
| `src/config/拠点病院.ts`                                                  | 0          | —        | —         | 0     |
| `src/config/生活保護.ts`                                                  | 0          | —        | —         | 0     |
| `src/config/社会福祉協議会.ts`                                            | 0          | —        | —         | 0     |
| `src/config/税.ts`                                                        | 0          | —        | —         | 0     |
| `src/config/窓口情報形式.ts`                                              | —          | —        | —         | —     |
| `src/config/障害.ts`                                                      | 0          | —        | —         | 0     |
| `src/hooks/calculate.ts`                                                  | 100        | 75       | 100       | 100   |
| `src/state/convert.ts`                                                    | 100        | 96.7     | 100       | 100   |
| `src/state/household.ts`                                                  | —          | —        | —         | —     |
| `src/state/progress.ts`                                                   | 100        | 86.95    | 100       | 100   |
| `src/state/questionDefinition.ts`                                         | 76.66      | —        | 0         | 76.66 |
| `src/state/questionState.ts`                                              | 100        | 96.92    | 100       | 100   |
| `src/utils/toHalf.ts`                                                     | 100        | —        | 100       | 100   |

### 4.3. story・Browser Mode の計測と申し送り

`openfisca-japan:dashboard` で `npm run test:ui -- --coverage` を実行したが、Storybook の設定読込時に Node の `os.networkInterfaces()` が `uv_interface_addresses returned Unknown system error 1`（`ERR_SYSTEM_ERROR`）で失敗した。ブラウザーの起動・テスト実行・網羅率生成には到達していない。story・Browser Mode の全体・ファイル別の数値は未計測であり、0% とは扱わない。

個票 2.1 の例外に従って `requires_human` とする。統合後、orchestrator がブラウザーとネットワーク情報を利用できるホスト環境で以下を実行し、ファイル別の結果と薄い箇所の優先度を本節と result の申し送りに追記する。依存と Chromium が導入済みの環境を使う。executor による依存追加・ブラウザーダウンロードは行わない。

```bash
cd dashboard
# story と Browser Mode の合算
npm run test:ui -- --coverage
# 層別に確認する場合。別々の出力先を指定する
npm run test:stories -- --coverage --coverage.reportsDirectory=coverage/stories
npm run test:browser -- --coverage --coverage.reportsDirectory=coverage/browser
```

全体は各出力先の `coverage-summary.json` の `total`、ファイル別はそれ以外のキーで確認する。HTML の未実行行・分岐を既存の story・Browser Mode の期待値と照合する。unit と UI の百分率は足さない。今回の unit の 0% は「その層では実行されていない」という意味であり、既存の story・Browser Mode・E2E にテストがないとは断定しない。

### 4.4. テストを追加する項目の案

以下は追加タスクの案であり、登録簿への新規登録や状態遷移は行っていない。UI が未計測の項目は、4.3 の計測と既存テストの確認後に重複を除いて範囲を確定する。数値だけでなく、状態の接続・ユーザー操作・移行で変わる部品を根拠に優先順位を付けた。

| 項目案                                        | 優先度・根拠                                                                                                                                             | 追加する確認とテスト層                                                                                                                                                                                                                                   |
| --------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 質問画面と状態機械の接続を検証する            | 高。`components/questions/question.tsx` は unit 0%、`state/questionDefinition.ts` の Functions は 0%。状態機械単体が高網羅率でも画面への接続は保証しない | Browser Mode で未入力時のエラーと次へ抑止、回答後の遷移、戻る際の復元、世帯員変更時の入力切替、3 モードの完了時の household 保存・結果遷移を確認。既存 E2E の正常導線との差分に絞る                                                                      |
| 結果画面で共有 URL の復元と共有操作を検証する | 高。`result.tsx` は unit 0%、`shareLink.ts` は Branches 54.54%・Functions 64.28%。URL・Recoil・ブラウザー API をまたぐ                                   | story／Browser Mode で新旧 URL の復元、壊れたデータのエラー導線、モード保持、コピー成功・拒否時の表示と QR の URL を確認。`shareLink.test.ts` の符号化往復と重複させない。HTML の未実行行を見て画像保存操作も別ケースにする                              |
| 窓口・給付・貸付のデータ分岐を検証する        | 高。`helpDesk.tsx`・`benefit.tsx`・`loan.tsx` は unit 0%。既存 story は代表的な 4 種の計算結果であり、地域や制度ごとの条件は別に確認が必要               | UI 計測後に不足する story を追加。対応／未対応の居住地、Web URL の有無、地図・電話リンク、給付の最小・最大の表示と並び、HIV 条件での窓口表示、貸付の単位を固定データで検証する                                                                           |
| 入力テンプレートの端末依存分岐を検証する      | 中。年齢・金額・子の年齢・人数の Branches は 41.46%・39.47%・56.62%・63.04%。既存 jsdom は境界値、story は復元・選択、Browser Mode はキー操作を担う      | UI 計測後の未実行分岐から、Windows Chromium／Safari の IME 変換中の重複抑止、モバイル入力属性、初期値とクリア後の有効性を確認する。UA と入力イベントの分岐は jsdom、実フォーカス・キーは Browser Mode に分ける。到達不能な条件は数値のためにテストしない |
| 送信先の環境切替を検証する                    | 中。`hooks/calculate.ts` は Lines 100% だが Branches 75%。既存テストが固定する `VITE_BRANCH` はローカルのみ                                              | unit／jsdom で `production`・`branch` とそれ以外の API URL を確認する。MSW で対象 URL を捕捉し、外部 API には送信しない。既存の正常・500・ネットワークエラーの全組合せを複製しない                                                                       |
| 共有形式と状態変換の残りの分岐を検証する      | 中。`sharePresets.ts` の Branches 70.78%、`progress.ts` 86.95%、`convert.ts` 96.7%                                                                       | unit で HTML の未実行分岐と仕様を突き合わせる。共有形式の省略値・未知の値・互換性、進捗の履歴なし・人数の既定値、変換時の未回答や任意項目について、実際に起こる入力と期待値を絞って追加する                                                              |
| トップ・同意・画面入口の操作を検証する        | 中。`App.tsx`・`topPage.tsx`・`TermsModal.tsx` は unit 0%。Chakra／Router 移行時に導線が変わりやすい                                                     | UI 計測後、既存 Browser Mode のモーダルフォーカスと E2E の同意済み導線にない取消・再表示・各モード入口・ルーティングを Browser Mode で補う。静的説明や設定データの実行率を上げるだけのテストは優先しない                                                 |

網羅率の目標と CI 強制は今回決めない。各層の役割が異なり、UI の数値が未確定であることに加え、行が通ったことと期待値による検証は一致しないため。まず不足する利用者操作・分岐のテスト追加を優先する。

### 4.5. 検証結果

- unit の網羅率計測は 939 テスト成功。JSON の全 62 ファイルと本個票の表の値が一致することを照合した。
- 製品の `npm run pretty`、`npm run pretty:check` と追加した `COVERAGE.md` の Prettier 整形は成功。個票の Prettier 整形・markdownlint も成功。
- 製品の両テスト設定を `npx tsc --ignoreConfig --noEmit --skipLibCheck --module esnext --moduleResolution bundler --target esnext --types node vite.config.mts vitest.browser.config.mts` で型検査し成功。TypeScript 6 の要件に合わせて、ファイル指定時の `--ignoreConfig` を付けて検証した。
- 登録簿の生成は `npx specdojo register build --project prj-0001 --dry-run` で検査し成功。生成結果は書き込まず、登録簿の行・個票の frontmatter・result は変更していない。
- プロジェクト・製品の `git diff --check` は成功。catalog 検査は `catalog_path` の設定がないため、schema 検査は該当スクリプトも今回編集した YAML もないため適用外。
- story・Browser Mode の検証は 4.3 の環境制限により `requires_human`。ホストでの再計測と結果の追記を申し送る。

### orchestrator の確認（2026-11-01、specdojo-orchestrator）

- `feature/frontend-test-upgrade`（`2276ec5`）を一時的な worktree に取り出し、`npm ci` から `npm run test`・`build`・`lint`・`pretty:check` が通ることを確かめた。
- 4.3 の申し送りを受けて、サンドボックスの外で網羅率を測った。

  | 対象                                   | コマンド                                                       | Statements | Branches | Functions | Lines  |
  | -------------------------------------- | -------------------------------------------------------------- | ---------- | -------- | --------- | ------ |
  | unit                                   | `npx vitest run --project unit --coverage`                     | 58.18%     | 58.06%   | 44.84%    | 57.99% |
  | story と Browser Mode（51 件が通った） | `npx vitest run --config vitest.browser.config.mts --coverage` | 27.52%     | 18.58%   | 29.52%    | 27.08% |

  2.1 の 90.88%（Lines）は、テストが読み込んだファイルだけを数えた値で、今回は `include` の `src/**/*.{ts,tsx}` の全ファイル（読み込まれないファイルは 0%）を数えている。

- 出力先の `dashboard/coverage/` は、もとからある `dashboard/.gitignore` の `/coverage` で無視される。`package.json` の変更は要らない（既存のスクリプトに `-- --coverage` を渡す）。
- 上流の変更に登録簿の ID やリンクはない（commit メッセージの `Refs:` 行を除く）。Git の local config は実行の前後で変わっていない。
- **残っていること**: 4.4 のテストを足す項目の案（5 件）を登録簿に起票すること。担当と期限が決まっていないため、naoji の判断を待つ。起票したら close する。

### テストを足す項目の起票（2026-11-02、specdojo-orchestrator）

- 4.4 の案のうち、次の 5 件を naoji の承認のもとで起票した。どれも担当は DEV、期限は 2026-11-30、由来は PJR-MS7F で、優先度は 4.4 のとおりである。

  | ID                                                                   | タイトル                                      | 優先度 |
  | -------------------------------------------------------------------- | --------------------------------------------- | ------ |
  | [[prj-0001:pjr-8307-frontend-question-screen-tests\|PJR-8307]]       | 質問画面と状態機械の接続を検証する            | high   |
  | [[prj-0001:pjr-npc4-frontend-result-share-tests\|PJR-NPC4]]          | 結果画面で共有 URL の復元と共有操作を検証する | high   |
  | [[prj-0001:pjr-n0fe-frontend-helpdesk-benefit-loan-tests\|PJR-N0FE]] | 窓口・給付・貸付のデータ分岐を検証する        | high   |
  | [[prj-0001:pjr-4mc9-frontend-calculate-endpoint-tests\|PJR-4MC9]]    | 送信先の環境切替を検証する                    | medium |
  | [[prj-0001:pjr-0p60-frontend-top-terms-entry-tests\|PJR-0P60]]       | トップ・同意・画面入口の操作を検証する        | medium |

- 4.4 の「入力テンプレートの端末依存分岐を検証する」と「共有形式と状態変換の残りの分岐を検証する」（どちらも中）は、orchestrator が承認を求めたときの一覧から漏れていたため、起票していない。起票するかは naoji の判断を待つ。この項目の完了条件（テストを足す項目に分ける）は 4.4 で満たしているため、この 2 件を待たずに close する。

## 5. 関連ドキュメント

- 由来: [[prj-0001:pjr-bsxa-frontend-chakra-ui-upgrade|PJR-BSXA]]（2026-11-01 の、移行の確かめ方の整理）
