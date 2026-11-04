---
specdojo:
  id: prj-0001:pjr-49v3-frontend-question-regression
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
  registered_at: "2026-10-31T04:05:37Z"
  due_on: "2026-11-30"
  completed_at: "2026-10-31T11:51:15Z"
  conclusion: 質問テンプレート 8 種類の描画のテスト 35 件と、jsdom・Testing Library の基盤、テストの分担の表を整えた（openfisca-japan の 3636260、9933fbc）
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

### 2.1. 再開時の指示（2026-10-31、specdojo-orchestrator）

2 回の実行で、次の点が完了条件を満たさなかった。再開した executor は、既存の worktree の成果を生かしてこれを直す。

- 前回の申し送りにある `npm ci` の確認は、orchestrator が 2026-10-31 に済ませた。product の worktree で `npm ci` は 15 秒で成功し、`npm run test` は 5 ファイル・913 件が通った。`npm ci` は流さない。
- `openfisca-japan:docs/dev_note.md` は、フロントエンドの節に書き足すだけにする。ファイル全体を整形しない。今の worktree にある、フロントエンドの節以外の書式の変更は元に戻す。
- テンプレートごとの入力・境界値・選択の変更の表と、わざと壊して確かめた結果は、この個票の「4. 対応結果」に書く。書いたかどうかは差分で確かめる。報告だけで済ませない。

## 3. 作業内容

前提: 依存の更新の前に着手する。今の構成で検査が失敗する場合は、失敗の内容を記録し、基準ができるまで後続の更新を始めない。

| No  | 作業                                                   | 担当 | 状態 | メモ                                                |
| --- | ------------------------------------------------------ | ---- | ---- | --------------------------------------------------- |
| 1   | 質問テンプレートと既存テストを調べ、入力動作を表にする | DEV  | done | 下表に 8 種類の適用可否と期待結果を記録             |
| 2   | 描画テスト環境と Provider ヘルパー・固定データを整える | DEV  | done | 導入済みの依存のみ使用。ファイル単位で jsdom を指定 |
| 3   | テストを追加し、わざと壊して検出できることを確かめる   | DEV  | done | 35 ケースを追加。上限判定の一時変更を検出して復元   |
| 4   | テスト層の分担を `docs/dev_note.md` に書き、検証する   | DEV  | done | フロントエンド節への追記のみ。指定の 4 検査に成功   |

## 4. 対応結果

### 動作ケースと結果

すべて `questionTemplates.test.tsx` の描画テストで確認する。「空入力」は数値の消去または選択前の状態を指し、選択ボタンに存在しない空値を注入しない。数値境界のないテンプレートも、未選択・選択解除・選択変更の境界を確認する。

| テンプレート        | 正常入力                                                     | 空入力                                                                                  | 実装上の境界値                                                                                                                                             | 選択変更の適用可否・期待結果                                                                      |
| ------------------- | ------------------------------------------------------------ | --------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `address`           | 東京都・千代田区で `Address` を通知、表示と有効状態を更新    | 初期値なし・市区町村消去・都道府県消去はいずれも無効                                    | 数値境界は非適用。都道府県のみでは無効、両方選ぶと有効                                                                                                     | 適用。大阪府に変えると市区町村を空にして通知し、千代田区の選択肢が消え大阪市の選択肢が現れる      |
| `age`               | 全角の「１２」を 12 にして `Age` を通知                      | 入力後の消去で表示を空にし無効に戻す                                                    | 0・200 を受理し、201 は 200 にする。0 から下矢印でも 0 を維持                                                                                              | 適用。数値変更で回答・表示・Recoil の有効状態を更新                                               |
| `amountOfMoney`     | 全角の「１２」を 12 万円として通知                           | 初期状態と消去後は無効                                                                  | 0・1,000,000 を受理し、1,000,001 は 0 万円で通知                                                                                                           | 適用。変更ごとに `AmountOfMoney` と `unit` を通知して表示を更新                                   |
| `childrenAge`       | 全角の「７」を 7 にし `Age` を通知。学校・学年から年齢も更新 | 年齢の消去で無効。学年だけの消去は年齢を保持し有効                                      | 0・200 を受理、201 は 200。1 月固定で小学校 6 年→7 年は中学校 1 年（13 歳）、中学校 3 年→4 年は高校 1 年（16 歳）、高校 3 年→4 年は高校卒業後相当（19 歳） | 適用。学校変更で年齢を再計算。7 歳の表示は 1 月で小学 1 年、4 月で小学 2 年となる現在の計算を固定 |
| `multipleSelection` | 2 項目を選び配列で通知、選択表示も更新                       | 未選択の 0 件でも有効                                                                   | 数値境界は非適用。最後の 1 件を解除すると空配列。「いずれでもない」も全解除して空配列                                                                      | 適用。追加・個別解除・全解除で回答と各ボタンの表示を更新                                          |
| `personNum`         | 全角の「２」を 2 人として通知し有効                          | 初期状態と空のまま「はい」は無効。入力消去は 0 人を通知し、「はい」を押すと無効に再計算 | 0 入力は表示を空にし無効。上限 5 は受理、6 は 5 に丸める                                                                                                   | 適用。「いいえ」は 0 人で有効。「はい」に戻すと入力済み人数を通知                                 |
| `selection`         | 「会社員」を選ぶと `Selection` を通知し有効                  | 選択前は無効。空に戻す UI はなく、消去は非適用                                          | 数値境界は非適用。選択肢の 2 択を確認                                                                                                                      | 適用。「自営業」への変更で回答と両ボタンの選択表示を更新                                          |
| `yesNo`             | 「はい」で true、「いいえ」で false を `Boolean` として通知  | 選択前は無効。空に戻す UI はなく、消去は非適用                                          | 数値境界は非適用。false も有効な回答                                                                                                                       | 適用。両方向の回答・選択表示・有効状態を確認                                                      |

### 実施内容と判断根拠

- 個票の完了条件を基準とし、既存 4 ファイルを変更せず 905 件を維持し、質問テンプレートの 35 件を追加した。8 種類すべてで入力・選択変更と有効状態、保存済み回答の表示を確認する。0 や false の復元も有効として扱う。
- jsdom はテストファイル冒頭の `// @vitest-environment jsdom` で指定した。全体設定を jsdom にするとロジックまで DOM 環境になるため、既存の state 3 ファイルと `shareLink.test.ts` は既定の node 環境を維持する。
- `questionTemplateTestUtils.tsx` に ChakraProvider・RecoilRoot の描画ヘルパー、選択肢・初期回答・学年境界の固定データを分離した。各描画で新しい RecoilRoot を作り、テスト終了時は cleanup と時計の復元を行う。再描画で前の有効状態が漏れない専用ケースも追加した。対象部品は Router を使用しないため、Router Provider は現時点では不要と判断した。
- jsdom は Chakra の CSS 変数を背景の計算済みスタイルに解決しないため、ボタンに実際に適用された CSS ルールを確認する。Emotion のクラス名のハッシュは固定せず、描画されたクラスからルールを調べる。実ブラウザーでの見た目の検証は後続の Storybook 移行で扱う。
- Vite 2.9・React plugin 1.3 の Fast Refresh は Vitest では HTML preamble がなく初期化エラーになる。前回のフラグだけの回避策では `$RefreshSig$` エラーが残るため、`vite.config.ts` で `mode` が `test` のときだけ Fast Refresh を無効にした。開発時の機能と依存の版は維持し、`src/testSetup.ts` は共通の jest-dom matcher 登録に使用する。
- `docs/dev_note.md` のフロントエンド節に、ロジック・画面・API・導線の分担表、テストコマンド、描画ヘルパーの説明を追記した。前回のファイル全体への整形を戻し、追加部分だけを整形した。PJR-Z7FQ の決定と後続 3 項目へのリンクを表に反映した。
- `package.json`・lockfile・CI など保護された設定の変更や、新しい依存の追加は不要だった。

### 破壊テスト

- `ageQuestionTemplate.tsx` の入力上限条件 `numValue > 200` だけを一時的に `numValue > 201` に変更し、`dashboard` で `npm run test` の全件を実行した。
- `normalizes age 201 to 200 and invalidates a cleared answer` が失敗し、期待する表示 200 に対して実際は 201 となった。終了コード 1、1 件失敗・939 件成功で、既存 4 ファイルは成功した。
- `finally` で実装を元に戻した。復元後の全件テストが 5 ファイル・940 件成功し、実装ファイルに差分がないことを確認した。

### 検証

- 実行環境: 2026-10-31、Linux の task worktree、Node.js v22.23.3、npm 10.9.9。Vitest 3.2.4、Vite 2.9.13、導入済みの jsdom と Testing Library を使用した。
- `npm ci` は今回実行しなかった。再開指示 2.1 のとおり、orchestrator が product worktree で 15 秒での成功と 913 件の成功を確認済みであり、前回の未確認事項は解消している。
- `dashboard` の `npm run test`: 成功。既存の 905 件と追加の 35 件、計 5 ファイル・940 件が成功した。
- `dashboard` の `npm run build`: 成功。既存の 500 KiB 超のバンドルサイズ警告のみ。
- `dashboard` の `npm run lint`: 成功。
- `dashboard` の `npm run pretty:check`: 成功。対象は dashboard 内であり、開発メモ全体の整形は行わない。
- project の個票に Prettier と markdownlint を適用し成功した。
- project の `register-build` hook は今回も `spawnSync git EPERM` となり、sandbox 内で staged file の検査を実行できなかった。ホスト側の runner で `node tools/specdojo-pre-commit.mjs register-build` を実行する。executor は `pjr-index.md`・イベント・個票のステータス項目を変更していない。
- project に `catalog_path`、schema 検証 script、typecheck script、実体のある test script はなく、これらの検査は適用外。product の markdownlint は未導入のため適用外。`specdojo index build` は runner の担当なので実行していない。

### 申し送り

- `personNum` には、正の人数の入力後、同じ「はい」のまま入力を空にすると Recoil の有効状態が直後には true のまま残り、改めて「はい」を押すと false になる既存挙動がある。今回の回帰テストでその遷移を明示した。原因は有効状態を再計算する effect の依存に `formValidated` がないこと。本タスクでは実装変更せず、別項目で入力直後に再計算する修正と期待値の更新を検討する。
- runner は sandbox 外で `register-build` hook を確認する。result の記入と状態遷移は reporter / runner に委ねる。

### orchestrator の確認（2026-10-31、specdojo-orchestrator）

- `openfisca-japan` の `feature/frontend-test-upgrade`（`3636260`）を一時的な worktree に取り出し、`dashboard` で `npm ci`（4 秒）、`npm run test`（5 ファイル・940 件）、`npm run build`、`npm run lint`、`npm run pretty:check` がすべて成功することを確かめた。
- 差分は完了条件の範囲に収まり、既存の 4 つのテストのファイルと保護された設定は変わっていない。commit メッセージに `Refs: prj-0001:PJR-49V3` がある。
- `docs/dev_note.md` の分担の表に、上流の文書では働かない登録簿のリンク（`[[prj-0001:…]]`）が入っていたため、説明の文に置き換えた（`9933fbc`）。原因は、この個票の完了条件をリンクの形で書いたことである。
- 申し送りの `personNum` の既存の不具合は、別の issue として起票した。

### 上流の PR #507 での直し（2026-11-04、specdojo-orchestrator）

- 区切り 1 の PR（#507、`feature/frontend-test-foundation`）で、Netlify のプレビューのデプロイが失敗した。この項目で `vite.config.ts` が `defineConfig` を `'vitest/config'` から読み込むようにしたため、Vitest が持つ ES Module だけの Vite（7.3.1）が build のときにも読み込まれ、Node.js 18 では `ERR_REQUIRE_ESM` で build が失敗する。Netlify のプレビューと、GitHub Pages にデプロイする workflow（`develop.yml`・`jekyll-gh-pages.yml`）は Node.js 18 で build している。Docker の Node.js 18・20・22 で再現し、18 のときだけ失敗することを確かめた（`develop` は 18 でも通る）。
- naoji の指示で、`d3475d0`（`fix(dashboard): …`）を `feature/frontend-test-foundation` に積んだ。`defineConfig` は `'vite'` から読み込み、Vitest の設定の型は `import type` で使う。今の `develop` に取り込んだ状態で、`npm run test`（967 件）・`lint`・`pretty:check`・`build`、E2E（5 件を 2 回）、Node.js 18・22 での `npm ci` と build が通った。build の出力は、圧縮した変数の名前の割り当てを除いて `develop` と同じ。
- 区切り 2 以降は Vite 8 のため Node.js 20.19 以上が要る。Cloudflare Pages（上流の `docs/dev_note.md` によると本番と開発版の配信先）と Netlify の Node.js の版は、上流の管理者に確かめる必要がある。区切り 2 以降のブランチには、`develop` を merge するときに `vite.config.ts` の衝突を解く（区切り 2 の設定を採る）。

## 5. 関連ドキュメント

- 方針: [[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ フロントエンドのテストの方針を決める]]
- 起点: `openfisca-japan:tmp/dev_analysis.md` の 2.2 節・4.1 節・推奨アクション。記載された最新バージョンやテストの数は当時の調査値として扱い、今の実装と公式の情報で確かめ直す。
- 対象リポジトリ: `openfisca-japan`（`../OpenFisca-Japan`）、対象ディレクトリ: `dashboard/`
- 後続の項目: [[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]]、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]]、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]]、[[prj-0001:pjr-pp9d-frontend-vite-vitest-upgrade|PJR-PP9D]]
