---
specdojo:
  id: prj-0001:pjr-49v3-frontend-question-regression
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: waiting
  priority: high
  difficulty: medium
  owner: DEV
  registered_at: "2026-10-31T04:05:37Z"
  due_on: "2026-11-30"
  block_reason: "executor reported incomplete: 描画テスト基盤、質問テンプレート8種類のテスト、テスト方針の記録を整え、指定された4検査はすべて成功。npm ci は再試行でも無出力のまま60秒を超え完了確認できず、依存のクリーンインストールが未確認のため未完了。"
  derived_from:
    - PJR-Z7FQ
---

# PJR-49V3 テストの方針と描画のテストの基盤を整え、質問テンプレートのテストを書く

## 1. 概要

依存の更新の前に、`dashboard` に画面の描画のテストの基盤を整え、質問テンプレート 8 種類の入力・境界値・状態の反映をテストで固定する。[[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ]] の方針に従い、品質は単体テストと画面のテストで保証する。

## 2. 完了条件

- `openfisca-japan:dashboard/src/components/questions/template/` の質問テンプレート 8 種類（`address`・`age`・`amountOfMoney`・`childrenAge`・`multipleSelection`・`personNum`・`selection`・`yesNo` の各 `QuestionTemplate.tsx`）について、正常入力・空入力・実装上の境界値・選択の変更の適用可否と期待結果を表にして「4. 対応結果」に記録し、該当するケースをテストにする。
- 描画のテストは Vitest と jsdom、Testing Library で書く。依存は `feature/frontend-test-upgrade` に導入済みである（`37e3eed`: `jsdom` 30、`@testing-library/react` 16、`@testing-library/dom` 10、`@testing-library/user-event` 14、`@testing-library/jest-dom` 7）。executor はネットワークに出られず `package.json` も書き換えられないため、ほかの依存が要る場合は追加せず、要る依存と理由を「4. 対応結果」に書いて止まる。jsdom を有効にする方法（ファイルごとの `// @vitest-environment jsdom` か、設定の `environment` か）は executor が決め、理由を記録する。既存の 4 ファイルは node 環境のまま流れること。
- Chakra UI・Recoil・Router など必要な Provider をまとめた描画用のヘルパーと、固定データを、テストのファイルから切り離して置く。[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]] で story からも使うためである。各テストの間で状態が漏れない。
- 既存の 4 ファイル（`state/` の 3 ファイルと `shareLink.test.ts`）を変えずに通す。
- テストの層の分担を、PJR-Z7FQ の決定内容に沿って `openfisca-japan:docs/dev_note.md` のフロントエンドの節に表で書く。表には次を含める。
  - ロジック（状態・変換・入力の検証など）は UI から切り離し、Vitest の node 環境で確かめる。
  - 画面は、今は Vitest と jsdom で確かめ、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]] のあとは Storybook の story と Vitest Browser Mode で確かめる。
  - API の応答は、[[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]] で入れる MSW で HTTP の境界で差し替える。
  - 導線は、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]] の Playwright の E2E で、主要なものだけを確かめる。
- 2026-10-31 に、今の構成で jsdom の上に `ChakraProvider` で包んだ部品を描画できることを確かめてある。それでも Vite 2.9・`@vitejs/plugin-react` 1.3 と Vitest 3 の組み合わせで描画のテストが動かない場合、Vite は更新しない（ローカルで下書きした PJR-PP9D の範囲）。阻害要因と回避案を「4. 対応結果」に記録して止まる。
- 入力処理を 1 か所わざと変えると該当するテストが失敗することを確かめ、変更は戻して結果を記録する。
- 検証は `dashboard` で `npm run test`、`npm run build`、`npm run lint`、`npm run pretty:check` を実行する。実行したコマンド・環境・成否を「4. 対応結果」に記録する。
- `npm ci` は worktree を作るときに runner が流すため、executor は流さない（executor はネットワークに出られない）。依存が足りない場合は追加せず、要る依存と理由を「4. 対応結果」に書いて止まる。
- exec で実施する場合は、その時点の設定による親の検証も通す。親の検証にフロントエンドの検査が含まれない場合も、この項目で指定した検査は省略しない。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。反映は利用者の承認のもとで行い、反映と検証が終わるまで close しない。
- CHANGELOG を更新する場合は未公開の版の節に書き、公開済みの版の節は変えない。範囲外の問題は別の項目に分ける。

## 3. 作業内容

前提: 依存の更新の前に着手する。今の構成で検査が失敗する場合は、失敗の内容を記録し、基準ができるまで後続の更新を始めない。

| No  | 作業                                                                   | 担当 | 状態 | メモ                        |
| --- | ---------------------------------------------------------------------- | ---- | ---- | --------------------------- |
| 1   | 今の質問テンプレートと既存のテストを調べ、期待する入力の動作を表にする | DEV  | open | -                           |
| 2   | 描画のテストの環境と、Provider のヘルパー・固定データを整える          | DEV  | open | 依存は導入済み（`37e3eed`） |
| 3   | 各テンプレートのテストを追加し、わざと壊して検出できることを確かめる   | DEV  | open | -                           |
| 4   | テストの層の分担を `docs/dev_note.md` に書き、検証を流す               | DEV  | open | -                           |

## 4. 対応結果

### 動作ケースと結果

| テンプレート      | 正常入力                                                                    | 空入力                             | 境界値                                               | 選択変更の適用可否・期待結果                                                     |
| ----------------- | --------------------------------------------------------------------------- | ---------------------------------- | ---------------------------------------------------- | -------------------------------------------------------------------------------- |
| address           | 都道府県と市区町村を選ぶと両方を `Address` として通知し、市区町村を表示する | いずれか未選択なら未完了           | 都道府県変更時は市区町村を空に戻す                   | 適用。都道府県を変えると市区町村選択肢も切り替わり、回答は municipality 空で通知 |
| age               | 全角数字を半角化し数値を通知                                                | 空にすると入力を空にし未完了       | 0と200を受理、201超は200へ丸める。負数は0へ          | 適用。入力変更ごとにAgeを通知                                                    |
| amountOfMoney     | 数値を万円単位で通知                                                        | 空にすると未入力                   | 0を受理、1,000,000超は0へ                            | 適用。入力変更ごとにAmountOfMoneyとunitを通知                                    |
| childrenAge       | 年齢入力を通知し学校・学年選択を表示                                        | 空なら未完了                       | 年齢は0〜200、学年入力は機関ごとの最大学年に制限     | 適用。機関選択と学年入力で対応年齢を更新                                         |
| multipleSelection | 複数項目を選択し配列で通知                                                  | 0件も有効                          | 選択解除後は空配列、専用の「いずれでもない」も空配列 | 適用。各項目をトグルでき、いずれでもない選択で全選択を解除                       |
| personNum         | 正の整数を入力し人数を通知                                                  | 空・0以下は無効。いいえは0人で有効 | `maxPersonNum`超は上限に丸める                       | 適用。はいは入力数、いいえは0人を通知                                            |
| selection         | 選択肢を押すとSelectionを通知                                               | 選択前は未完了                     | 選択肢の範囲が境界（任意の数値境界なし）             | 適用。選択変更で表示と回答を更新                                                 |
| yesNo             | はい/いいえをBooleanで通知                                                  | 選択前は未完了                     | 真偽値2択（数値境界なし）                            | 適用。どちらのボタンでも回答・選択状態を更新                                     |

### 実施内容

- Vitestのファイル単位 `jsdom` 環境を指定し、既存のstate 3ファイルと `shareLink.test.ts` はnode環境のまま維持した。
- Chakra UIとRecoilを包む描画ヘルパー、選択肢fixtureをテスト本体から分離した。
- 上記8テンプレートの正常入力・空入力・境界値・変更動作を描画テストで追加した。年齢テンプレートではRecoilの入力有効状態も確認する。
- `docs/dev_note.md` にフロントエンドのテスト層分担表を追加した。
- 破壊テストでは年齢の上限判定を200から201に一時変更し、201入力がそのまま表示されて年齢テストが失敗することを確認した後、実装を200に戻した。

### 検証

- `dashboard` で `npm ci` は前回2回と再開時1回の計3回試行したが、ネットワーク取得が無出力で60秒を超えたため再開時も完了できず中断した。依存のクリーンインストール完了は未確認。インストール済み依存を使った以下の検査は実行できた。
- `npm run test`: 成功。5ファイル、913テストが成功（既存4ファイルを含む）。
- `npm run build`: 成功。Viteから既存のバンドルサイズ警告が出た。
- `npm run lint`: 成功。
- `npm run pretty:check`: 成功。
- 再開時に同じ4検査を再実行し、すべて成功した（テスト5ファイル・913件、build・lint・pretty:check）。
- 前回、project リポジトリの `register-build` hook は sandbox 内で staged file の読み取りに `EPERM` が発生した。`pjr-index.md` は変更していないため、runner 側で通常の hook 実行を確認する。
- テスト時のReact Refresh preambleエラーはVitest module runnerでHTML preambleが読み込まれないために起きた。`vite.config.ts` の `setupFiles` から `src/testSetup.ts` を読み込み、React Refreshフラグを設定して回避した。全画面テストで確認済み。

## 5. 関連ドキュメント

- 方針: [[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ フロントエンドのテストの方針を決める]]
- 起点: `openfisca-japan:tmp/dev_analysis.md` の 2.2 節・4.1 節・推奨アクション。記載された最新バージョンやテストの数は当時の調査値として扱い、今の実装と公式の情報で確かめ直す。
- 対象リポジトリ: `openfisca-japan`（`../OpenFisca-Japan`）、対象ディレクトリ: `dashboard/`
- 後続の項目: [[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]]、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]]、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]]、[[prj-0001:pjr-pp9d-frontend-vite-vitest-upgrade|PJR-PP9D]]
