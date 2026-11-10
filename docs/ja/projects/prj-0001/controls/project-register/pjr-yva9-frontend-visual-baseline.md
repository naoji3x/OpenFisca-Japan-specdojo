---
specdojo:
  id: prj-0001:pjr-yva9-frontend-visual-baseline
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: waiting
  priority: high
  difficulty: hard
  owner: DEV
  registered_at: "2026-11-10T22:59:14Z"
  due_on: "2026-11-30"
  block_reason: "integrate failed: project: Result Markdown notation violation before commit: docs/ja/projects/prj-0001/execution/exec/results/pjr-yva9-20261110T231235Z-37cbf413-result.md:37:1208 error MD038/no-space-…"
  derived_from:
    - PJR-1EB8
    - PJR-X4PS
  depends_on:
    - PJR-FBVP
  commit_type: test
---

# PJR-YVA9 区切り 2 の PR に、更新の前の画面の期待値と比べるテストを入れる

## 1. 概要

更新の前の develop の画面を、画像（toHaveScreenshot）と画面の構造（ARIA スナップショット）の期待値として保存し、区切り 2 のあとに Playwright の Docker イメージの中で比べるテストと CI を作る。

## 2. 入力

- naoji との検討（2026-11-10）: 区切り 2 では、更新の前の画面を期待値（oracle）として保存し、更新のあとに比べる形にする。期待値は区切り 2 の PR と一緒に上流のリポジトリに入れる。実装は sol-executor に任せる。
- 今までの見た目の比較（[[prj-0001:pjr-hqbe-frontend-visual-comparison|PJR-HQBE]]）は、更新の前（`823818e`）と区切り 3 のあと（`378eb36`）を並べて撮ったもので、期待値を保存していない。撮り方は、このリポジトリ（project）の `tools/visual-compare/capture.mjs` にある。PC（1280×800）とスマートフォン（390×844）、`deviceScaleFactor: 1`、`reducedMotion: 'reduce'`、`ja-JP`・`Asia/Tokyo`、日時を `2026-01-15T12:00:00+09:00` に固定、アニメーションを止める CSS、`src/mocks/calculate/*.response.json` を返す固定の応答で、トップ・同意・結果（給付だけ・貸付だけ・両方・対象なし）・404 などの 13 画面を撮る。
- 期待値は、更新の前のコード（今の `develop`、`6e5a6c6`。Vite 2.9 と区切り 1 のテストの道具を含む）から撮る。区切り 2 のブランチのコードからは撮らない。
- 画素は OS・フォント・ブラウザーの版で変わるため、撮るのも比べるのも Playwright の公式の Docker イメージ `mcr.microsoft.com/playwright:v1.64.1-noble`（`@playwright/test` 1.64.1 と同じ版。2026-11-10 にあることを確かめた）の中で行う。
- PJR-FBVP（`build.target`）の後に行う。
- product の統合先は、run ごとに `--integration-branch openfisca-japan=feature/frontend-vite8-storybook` で区切り 2 の PR 用のブランチにする（naoji の判断、2026-11-10）。区切り 2 の PR は、まだ上流に出していない。
- executor はネットワークに出られず、サンドボックスではブラウザーや preview・開発サーバー・Docker を起動できないことがある（`listen EPERM`）。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。依存は足さない。
- `dashboard/package.json` と `.github/workflows/**` は保護された設定として扱う。executor は書き換えず、変更案（差分）を「5. 対応結果」と報告の `handoff` に書く。反映は統合のあとに orchestrator が naoji の承認のもとで行う。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。Git の設定と commit には触れない。
- executor は期待値を撮らない（ブラウザーと Docker を使えないため）。統合のあとに orchestrator が、`develop` を build して Docker の中で撮り、naoji の承認のもとで区切り 2 のブランチに commit する。

## 3. 完了条件

- `dashboard/e2e/visual/`（置き場所は executor が決めてよい）に、13 画面 × PC・スマートフォンの比較のテストを置く。画像は `toHaveScreenshot`、画面の構造（見出し・ボタン・ラベル・文字）は `toMatchAriaSnapshot` で比べる。撮る条件は「入力」の `capture.mjs` と同じにする。比べる許容の値（`maxDiffPixels` など）は 0 を基本とし、変える場合は理由を書く。
- 見た目の比較は Chromium だけで流す。通常の E2E（`npm run test:e2e`）には含めず、別の設定のファイル（例: `playwright.visual.config.ts`）で流す。通常の E2E の件数（区切り 2 では 5 件）と動きは変えない。期待値の置き場所（`snapshotPathTemplate`）は、OS を名前に含めない形にし、Docker の中で撮ることを前提にする（理由を書く）。
- 期待値を撮るコマンドと、比べるコマンドを用意する。どちらも Docker のイメージ `mcr.microsoft.com/playwright:v1.64.1-noble` の中で流す形にし、`develop` から期待値を撮る手順（build してから撮る）も含める。`dashboard/package.json` にスクリプトを足すのが要る場合は変更案を書く。流し方と、見た目を変える PR では期待値を撮り直して差分をレビューする運用を、`docs/dev_note.md` に書く。
- CI（`.github/workflows/test_frontend.yml`）に、同じイメージの中で比べる段（または job）を足す変更案を書く。差が出たときに、差分の画像を成果物として残す案も書く。
- テストのコードが、期待値のないときに分かりやすく失敗することを確かめる（期待値は orchestrator が統合のあとに撮る）。
- アプリのコード（`dashboard/src` の本番のコード）は変えない。
- `dashboard` で `npm run test`・`lint`・`pretty:check`・`build` が通る。テストの一覧（`npx playwright test --config <見た目の設定> --list`）で、13 画面 × 2 の件数が出ることを確かめる。実際に撮る・比べるのは `requires_human` としてよい。
- 統合のあとに orchestrator が、`develop` から期待値を撮って commit し、区切り 2 のブランチ（`build.target` の指定のあと）で比べて差がないことを確かめる。差が出た場合は、差の内容を PJR-1EB8 に記録し、naoji と扱いを決める。

## 4. 作業内容

| No  | 作業                                            | 担当                  | 状態 | メモ                                                  |
| --- | ----------------------------------------------- | --------------------- | ---- | ----------------------------------------------------- |
| 1   | 撮影条件と13画面を移し、画像・ARIA の比較を書く | DEV                   | done | PC・スマートフォンの26件、画素差0・ARIA の deep-equal |
| 2   | 専用設定・Docker コマンド・開発手順を書く       | DEV                   | done | develop の commit を archive して独立に build する    |
| 3   | CI の変更案を書く                               | DEV                   | done | 下記差分。保護設定への反映は統合後                    |
| 4   | develop から撮影・commit し、区切り2で比較する  | specdojo-orchestrator | open | `requires_human`。naoji の承認後にホストで行う        |

## 5. 対応結果

### 実装と変更ファイル

- `openfisca-japan:dashboard/e2e/visual/screens.spec.ts`: 元の `capture.mjs` の13画面・操作・固定応答・撮影条件を移した。画像は全ページの `toHaveScreenshot`、構造は body の `toMatchAriaSnapshot` で比較する。同じケースの両方の差を残すため soft assertion を使う。結果画面はURLの到達も確認する。
- `openfisca-japan:dashboard/playwright.visual.config.ts`: Chromium、PC 1280×800・スマートフォン390×844の26件。`deviceScaleFactor: 1`、`reducedMotion: 'reduce'`、`ja-JP`・`Asia/Tokyo`、固定日時、Google Fonts・計測通信の遮断、アニメーション停止CSS、400ms・結果後800msの待機を採用。`threshold: 0`・`maxDiffPixels: 0`、ARIA は `deep-equal`。撮影と比較を同じDocker・CPUアーキテクチャで行うので、期待値名にOSを含めない。比較時は `updateSnapshots: 'none'`。
- `openfisca-japan:dashboard/e2e/visual/baselines.ts`: 期待値のないときにPNG・ARIAの不足パスと撮影手順を示して失敗させる。撮影以外のCLIによる更新指定もテスト側で拒否する。
- `openfisca-japan:dashboard/e2e/visual/docker.sh`: `compare` は現在のソースをbuild、`capture` は既定で `6e5a6c6` の `dashboard` を `git archive` で取り出し、そのlockfileで独立にinstall・buildする。旧buildを新しいテストで撮影するため、区切り2の出力が初回の期待値に混ざらない。同じ公式イメージ・`linux/amd64`・コンテナ専用の依存volumeを使い、Playwrightの実版も1.64.1か検査する。撮影成功後は `snapshots/source.json` に出典commit・イメージ・版・platformを記録する。executor はスクリプト内のinstall・Docker実行を行っていない。
- `openfisca-japan:dashboard/playwright.config.ts`: `testIgnore: '**/visual/**'` を追加し、通常E2Eの5件を維持。`openfisca-japan:dashboard/e2e/tsconfig.json` は専用設定も型検査する。
- `openfisca-japan:docs/dev_note.md`: 旧developからの撮影、比較、見た目を変えるPRでcommitを指定して撮り直す運用、差分レビュー、出典、失敗時の画像・ARIA・trace・HTML reportの場所を追記。既存のstoryに関する記述も適用範囲を明確にした。
- この個票の作業内容・対応結果を更新した。本番の `dashboard/src`、依存、lockfile、保護設定、登録簿一覧、個票のステータス、result、Git設定・commitは変更していない。

### 検証

- `dashboard` の `npm run test` は6ファイル・937件成功。`npm run lint`・`npm run pretty:check`・pre-commit相当の `npm run pretty`・`npm run build` は成功。buildには従来どおり500kB超chunkの警告がある。
- `npx --no-install tsc --project e2e/tsconfig.json` と `bash -n e2e/visual/docker.sh` が成功。見た目用 `--list` は13画面×2の26件、通常の `--list` は3ファイル・5件を確認した。
- 期待値不足は、`tmp/` の一時設定で元の設定から `webServer` だけを無効化し、desktop の top を実行して検証した。終了コード1、不足するPNGとARIAのパス、撮影コマンド、ブラウザー起動前の失敗を確認するassertionが成功。期待値は生成されていない。一時設定とログは削除した。
- 個票のPrettier・markdownlint、登録簿buildのdry-run、両リポジトリの `git diff --check` が成功した。`catalog_path` がないためcatalog検査は非適用、executorのYAML変更がないためschema検査は非適用。projectには適用可能なtest・typecheck scriptがなく、productルートにはMarkdown検査用のpackage定義がない。

### 保護設定の変更案

`dashboard/package.json` の変更は不要。依存を足さず、実行コマンドは `bash e2e/visual/docker.sh capture` と `bash e2e/visual/docker.sh compare` として用意した。

`.github/workflows/test_frontend.yml` に次のjobを追加する案。既存のtest jobを維持し、同じ公式イメージ内で比較し、失敗時に画像・ARIAの差分、trace、HTML reportをartifactとして残す。反映は統合後に orchestrator が naoji の承認のもとで行う。

```diff
--- a/.github/workflows/test_frontend.yml
+++ b/.github/workflows/test_frontend.yml
@@ -39,3 +39,37 @@
       - name: Playwright smoke
         run: npm run test:e2e
         working-directory: ./dashboard
+
+  visual:
+    runs-on: ubuntu-latest
+    container:
+      image: mcr.microsoft.com/playwright:v1.64.1-noble
+      options: --ipc=host
+    defaults:
+      run:
+        working-directory: dashboard
+    env:
+      HUSKY: '0'
+    steps:
+      - name: Checkout
+        uses: actions/checkout@v4
+      - name: Set up Node
+        uses: actions/setup-node@v4
+        with:
+          node-version: 26.4.0
+      - name: Install packages
+        run: npm ci
+      - name: Check Playwright version
+        run: node -e "require('node:assert/strict').equal(require('@playwright/test/package.json').version, '1.64.1')"
+      - name: Build
+        run: npm run build
+      - name: Compare visual and ARIA snapshots
+        run: npx --no-install playwright test --config playwright.visual.config.ts
+      - name: Upload visual differences
+        if: failure()
+        uses: actions/upload-artifact@v4
+        with:
+          name: playwright-visual-differences
+          path: tmp/playwright-visual/
+          if-no-files-found: warn
+          retention-days: 14
```

### 統合後の申し送り

- `requires_human`: 実際のDocker撮影・比較はsandboxでは行わない。orchestrator は `--integration-branch openfisca-japan=feature/frontend-vite8-storybook` で統合した後、ホストの `dashboard` で `bash e2e/visual/docker.sh capture` を実行する。出典が旧developの `6e5a6c6` であることを `snapshots/source.json` で確認し、PNG26枚・ARIA26件と出典をレビューして、naoji の承認のもとで区切り2のブランチへcommitする。その後 `bash e2e/visual/docker.sh compare` で差がないことを確認する。`build.target` 指定は先行タスクで統合済み。
- 差が出た場合は期待値や許容値を黙って変更せず、内容を [[prj-0001:pjr-1eb8-frontend-pr-assurance|PJR-1EB8]] に記録して naoji と扱いを決める。通常E2Eの実走もホストで確認する。
- 上のCI差分を naoji の承認後に反映し、期待値を含むPRでvisual jobが通ること、意図した画面差分を加えた場合に失敗してartifactにexpected・actual・diffが残ることを確認する。画像とARIAの実際の差分検出は期待値撮影後の人間側検証に含める。
- reporter / runner は本節とexecutor evidenceをresultに反映する。executorはresultを直接編集しない。

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-1eb8-frontend-pr-assurance|PJR-1EB8]]（区切り 2 の見た目の保証）、[[prj-0001:pjr-x4ps-frontend-visual-regression-upstream|PJR-X4PS]]（見た目の回帰テストを上流に入れる）
- 関連: [[prj-0001:pjr-fbvp-frontend-build-target|PJR-FBVP]]（先に行う）、[[prj-0001:pjr-hqbe-frontend-visual-comparison|PJR-HQBE]]（今までの見た目の比較）
