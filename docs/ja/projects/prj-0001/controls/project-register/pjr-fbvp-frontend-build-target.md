---
specdojo:
  id: prj-0001:pjr-fbvp-frontend-build-target
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: review
  priority: high
  difficulty: easy
  owner: DEV
  registered_at: "2026-11-10T22:59:04Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-1EB8
  commit_type: fix
---

# PJR-FBVP 区切り 2 で、build が対応するブラウザーの範囲を今と同じに保つ

## 1. 概要

Vite 8 は既定の build の target を Chrome 111・Safari 16.4・iOS 16.4 などに上げる。vite.config.mts に Vite 2.9 と同じ target（es2019・Chrome 87・Edge 88・Firefox 78・Safari 13.1）を指定する。

## 2. 入力

- PJR-1EB8 の区切り 2 の確認（2026-11-10、orchestrator）: Vite の既定の build の `target` は、2.9.13 では `['es2019', 'edge88', 'firefox78', 'chrome87', 'safari13.1']`、8.3.5 では `['chrome111', 'edge111', 'firefox114', 'safari16.4', 'ios16.4']`（`ESBUILD_BASELINE_WIDELY_AVAILABLE_TARGET`）である。区切り 2 の `dashboard/vite.config.mts` には `build.target` の指定がない。そのため、区切り 2 を取り込むと、対応するブラウザーの範囲が黙って狭くなる。
- naoji の判断（2026-11-10）: 案 A。今と同じ `target` を指定して、対応するブラウザーの範囲を変えない。
- product の統合先は、run ごとに `--integration-branch openfisca-japan=feature/frontend-vite8-storybook` で区切り 2 の PR 用のブランチにする（naoji の判断、2026-11-10）。区切り 2 の PR は、まだ上流に出していない。
- executor はネットワークに出られず、サンドボックスではブラウザーや preview・開発サーバー・Docker を起動できないことがある（`listen EPERM`）。流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。`npm ci` と `npx playwright install` は流さない。依存は足さない。
- `dashboard/package.json` と `.github/workflows/**` は保護された設定として扱う。executor は書き換えず、変更案（差分）を「5. 対応結果」と報告の `handoff` に書く。反映は統合のあとに orchestrator が naoji の承認のもとで行う。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。Git の設定と commit には触れない。

## 3. 完了条件

- `dashboard/vite.config.mts` の `build.target` に、Vite 2.9 の既定と同じ `['es2019', 'edge88', 'firefox78', 'chrome87', 'safari13.1']` を指定する。なぜ指定するか（Vite 8 の既定が上がったため、今と同じ範囲を保つ）をコメントに書く。CSS の対象（`build.cssTarget`）も、Vite 8 の既定が `build.target` と別に決まる場合は同じ範囲にそろえる（要否を Vite 8 の設定の仕様で確かめ、理由を「5. 対応結果」に書く）。
- `npm run build` が通り、出力の JS が `target` に合わせて書き換えられていることを確かめる。例えば、ES2020 以降の構文（`?.`・`??`・`??=` など）が bundle に残っていないことを、構文を解析して確かめる（確かめ方は executor が決め、理由を書く）。確かめられない場合は `requires_human` とし、確かめ方を書く。
- `GITHUB_PAGES=true` の build でも、アセットのパスが `/OpenFisca-Japan/assets/…` のままであることを確かめる。
- 開発サーバー（`vite`）の動きは変えない（`build.target` は build だけに効く）。
- `dashboard` で `npm run test`・`lint`・`pretty:check`・`build` が通る。`test:ui` と `test:e2e` は `requires_human` としてよい。
- bundle の大きさを、指定の前と後で「5. 対応結果」に書く（構文の書き換えで大きくなる見込み）。

## 4. 作業内容

| No  | 作業                                               | 担当 | 状態 | メモ                                                       |
| --- | -------------------------------------------------- | ---- | ---- | ---------------------------------------------------------- |
| 1   | `build.target`（と必要なら `cssTarget`）を指定する | DEV  | done | JS・CSS とも旧 target になることを解決済み設定で確認       |
| 2   | 出力の構文と大きさを確かめる                       | DEV  | done | 通常・GitHub Pages 用 build の構文・サイズ・パスを確認済み |

## 5. 対応結果

- `openfisca-japan:dashboard/vite.config.mts` の `build.target` に `['es2019', 'edge88', 'firefox78', 'chrome87', 'safari13.1']` を指定し、Vite 8 が既定値を引き上げたため Vite 2.9 の対応範囲を維持する旨をコメントに記載した。
- CSS の追加指定は不要。インストール済み Vite 8.3.5 の `dist/node/index.d.ts` は `cssTarget` の既定を `target` と定義し、`dist/node/chunks/node.js` の `resolveBuildEnvironmentOptions` も `cssTarget: merged.cssTarget ?? merged.target` と解決する。既定の CSS transformer は `postcss` で、CSS minification は `config.build.cssTarget` を使う。`resolveConfig({}, 'build')` で JS・CSS の target がどちらも上記配列になることを assert で確認した。
- 開発用の `server`・`optimizeDeps`、plugins、環境変数に応じた `base` は変更していない。`resolveConfig({}, 'serve')` で `base: '/'` と既定 port 5173 を確認し、`dev` script の port 30000・host 指定も維持されている。変更は build 設定だけであり、開発サーバーの設定には影響しない。
- `dashboard` の `npm run test`（6 ファイル・937 テスト）、`npm run lint`、`npm run pretty:check`、pre-commit 相当の `npm run pretty`、変更前後の `npm run build` が成功した。`GITHUB_PAGES=true npm run build` も成功した。500 kB 超の chunk 警告は変更前後に出るが、build は成功している。
- 構文の検証には既存のローカル依存 Acorn 8.11.2 を使用した。通常 build と GitHub Pages 用 build が出力した `dist/assets/*.js` 全件（各 1 ファイル）を `sourceType: 'module'`・`ecmaVersion: 2019` で解析し、両方で成功した。さらに最新版構文の AST を走査した結果、変更前に optional chaining 444 件・nullish coalescing 241 件・論理代入 89 件あったものが、変更後はすべて 0 件になった。文字列・コメントを誤検出するテキスト検索を避け、ES2019 を超える構文の残存も検出するため、この方法を採用した。
- GitHub Pages 用 `dist/index.html` の `src`・`href` にある `/assets/` への参照 5 件が、すべて `/OpenFisca-Japan/assets/…` で始まり、参照先ファイルも存在することを assert で確認した。
- 個票の Prettier・markdownlint と両リポジトリの `git diff --check` が成功した。登録簿一覧を書き換えないよう、pre-commit の register build 相当は `npx --no-install specdojo register build --project prj-0001 --dry-run` で検証し、成功した。`catalog_path` がないため catalog 検証は非適用、YAML の変更がないため schema 検証も非適用。

通常 build の JS bundle の比較（gzip は両方とも Node.js `gzipSync` の既定設定で圧縮し、同一条件で計測）:

| 条件                | ファイル名          | JS bytes  | gzip bytes |
| ------------------- | ------------------- | --------- | ---------- |
| 変更前              | `index-C0B8qMKR.js` | 991,792   | 307,086    |
| target 指定後       | `index-DJ7MYRBo.js` | 1,004,500 | 310,683    |
| 差分                | -                   | +12,708   | +3,597     |
| GitHub Pages 指定後 | `index-VvnOJk73.js` | 1,004,564 | 310,716    |

JS は約 1.28%、gzip は約 1.17% 増えた。構文の書き換えによる想定内の増加である。

- 申し送り: `npm run test:ui` と `npm run test:e2e` は `requires_human`。ブラウザー起動と preview サーバーの listen を伴うため、統合後に orchestrator がホスト側の `dashboard` で実行する。通常の build・AST 解析・パス検証は sandbox 内で完了している。
- 保護設定の変更案はない。`dashboard/package.json`・`.github/workflows/**` の変更や依存追加は不要。登録簿一覧・個票のステータス・Git 設定・commit・result は変更していない。result への記録は reporter / runner が本節と executor evidence を反映する。

### orchestrator の確認（2026-11-10、specdojo-orchestrator）

- `feature/frontend-vite8-storybook`（`938caa0`）を一時的な worktree に取り出し、`npm ci` から `npm run test`（937 件）・`lint`・`pretty:check`・`test:ui`（35 件）・`build` が通ることを確かめた。E2E は build のあと 5 件が 2 回とも通った。
- 出力の JS（`dist/assets/index-DJ7MYRBo.js`）を acorn 8.11.2 で解析し、`ecmaVersion: 2019` では読め、`2018` では読めないことを確かめた（確かめ方が構文の版を見分けている）。Vite 2.9 の既定の `target` も `es2019` で、対応するブラウザーの範囲は今と同じ。

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-1eb8-frontend-pr-assurance|PJR-1EB8]]（区切り 2 の「保証できていないこと」）
- 関連: [[prj-0001:pjr-pp9d-frontend-vite-vitest-upgrade|PJR-PP9D]]（Vite 8 への更新）、[[prj-0001:pjr-yva9-frontend-visual-baseline|PJR-YVA9]]（この項目の後に行う）
