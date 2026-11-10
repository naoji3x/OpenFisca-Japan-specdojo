---
specdojo:
  id: prj-0001:pjr-fbvp-frontend-build-target
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
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

| No  | 作業                                               | 担当 | 状態 | メモ |
| --- | -------------------------------------------------- | ---- | ---- | ---- |
| 1   | `build.target`（と必要なら `cssTarget`）を指定する | DEV  | open | -    |
| 2   | 出力の構文と大きさを確かめる                       | DEV  | open | -    |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-1eb8-frontend-pr-assurance|PJR-1EB8]]（区切り 2 の「保証できていないこと」）
- 関連: [[prj-0001:pjr-pp9d-frontend-vite-vitest-upgrade|PJR-PP9D]]（Vite 8 への更新）、[[prj-0001:pjr-yva9-frontend-visual-baseline|PJR-YVA9]]（この項目の後に行う）
