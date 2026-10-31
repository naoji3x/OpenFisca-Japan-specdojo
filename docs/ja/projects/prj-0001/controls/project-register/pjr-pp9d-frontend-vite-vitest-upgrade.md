---
specdojo:
  id: prj-0001:pjr-pp9d-frontend-vite-vitest-upgrade
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
  priority: high
  difficulty: hard
  owner: DEV
  registered_at: "2026-10-31T05:43:45Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-Z7FQ
  depends_on:
    - PJR-49V3
    - PJR-BZGG
    - PJR-1RJE
---

# PJR-PP9D Vite・Reactプラグイン・Vitest を互換性のある構成へ更新する

## 1. 概要

回帰テストの完了後に Vite 2 系から移行し、`@vitejs/plugin-react` と Vitest を整合させる。開発サーバーの起動・HMR・本番ビルドと、既存の HTML の変換を維持する。この項目の完了は、Storybook の導入（[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]]）の前提になる。

## 2. 完了条件

- 着手の時点の公式のサポート情報・Node の要件・peerDependencies を確かめ、Vite・`@vitejs/plugin-react`・Vitest の更新先と選んだ理由、移行の順序を「4. 対応結果」に記録する。Vite は、[[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]] で入れる Storybook が求める版（2026-10-31 時点では Vite 5 以上・Vitest 4 以上）を満たす。
- Vite 2 系から移行し、依存の宣言とロックファイルが一致する（クリーンな環境での `npm ci` の成功は、統合のあとに orchestrator が確かめる）。
- 開発サーバーの起動とソースを編集したときの HMR、本番ビルドと preview、`index.html` の環境変数の置き換え、通常と GitHub Pages 向けの `base` の設定を確かめる。
- [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]] と [[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]] の画面のテストを、削除・skip せずにすべて通す。
- 検証は `dashboard` で `npm run test`、`npm run build`、`npm run lint`、`npm run pretty:check` と、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]] で追加した E2E のスクリプトを実行する。E2E は build 済みの preview に対して流す。実行したコマンド・環境・成否を「4. 対応結果」に記録する。
- `npm ci` は worktree を作るときに runner が流すため、executor は流さない（executor はネットワークに出られない）。依存の更新は、`dashboard/package.json` の変更案を「4. 対応結果」と報告の `handoff` に書いて止まる。利用者の承認のもと `exec handoff apply` で当て、ロックファイルもそこで作り直したあと、`--resume` で続ける。
- 上流の文書・コード・コメントに、登録簿の ID やリンク（`PJR-XXXX`、`[[prj-0001:…]]`）を書かない。登録簿との対応は commit メッセージの `Refs:` 行だけで取る。PJR-49V3 で `docs/dev_note.md` にリンクが入り、上流では働かなかったためである。
- exec で実施する場合は、その時点の設定による親の検証も通す。親の検証にフロントエンドの検査が含まれない場合も、この項目で指定した検査は省略しない。
- 保護された設定（`package.json`、`.github/workflows/**` など）の変更が必要な場合、executor は変更案を「4. 対応結果」に書き、pipeline では報告の `handoff` にも書く。反映は利用者の承認のもとで行い、反映と検証が終わるまで close しない。
- CHANGELOG を更新する場合は未公開の版の節に書き、公開済みの版の節は変えない。範囲外の問題は別の項目に分ける。

### 2.1. 実行の前提（2026-10-31、specdojo-orchestrator）

- 依存の更新は `feature/frontend-test-upgrade` に導入済みである（`a30f1f0`）。executor は依存を追加・変更しない。

  | パッケージ             | 更新前  | 更新後  | 選んだ理由                                                                                                |
  | ---------------------- | ------- | ------- | --------------------------------------------------------------------------------------------------------- |
  | `vite`                 | 2.9.13  | 8.3.5   | 最新。Storybook 10.6 の `@storybook/react-vite` の peer（Vite 5〜8）を満たす。Node 20.19 以上・22.12 以上 |
  | `@vitejs/plugin-react` | 1.3.2   | 6.1.2   | 最新。Vite 8 を peer に求める                                                                             |
  | `vitest`               | 3.2.4   | 5.0.5   | 最新。`@storybook/addon-vitest`（Vitest 4〜5）を満たす。Vite 6.4〜8 を peer に求める                      |
  | `@types/node`          | 18.13.0 | 22.20.5 | Vite 8 と Vitest 5 の peer（20.19 以上・22 以上）を満たすため                                             |

- orchestrator は更新のあと、コードを変えずに `npm run test`（967 件）・`build`・`lint`・`pretty:check`・`test:e2e`（5 件）が通ることを確かめた。この項目では、次を行う。
  - 更新で不要になった回避策を外す。`vite.config.ts` の `react({ fastRefresh: mode !== 'test' })` の `fastRefresh` は、プラグインの 1 系の設定で 6 系にはない。外したうえで、Vitest の描画のテストが通ることを確かめる。`src/testSetup.ts` に古い回避策が残っていれば同じく扱う。
  - build のときに出る `configLoader: 'native'` の警告（`vite.config.ts` が CommonJS として読まれる）への対処を決める。`dashboard/package.json` の `"type"` は保護された設定なので変えない。`vite.config.mts` への改名で対処するか、対処しないかを executor が決め、理由を「4. 対応結果」に書く。
  - 完了条件の HTML の環境変数の置き換えと、`GITHUB_PAGES` の `base` は、`npm run build` の出力（`dist/index.html` とアセットのパス）で確かめる。
- executor はネットワークに出られず、サンドボックスでは開発サーバーと preview を起動できない（`listen EPERM`）。開発サーバーの起動・HMR・preview・`test:e2e` を流せない場合は `requires_human` として記録し、ほかの検査が通れば完了としてよい。これらは統合のあとに orchestrator が確かめる。
- 上流の文書・コードに、登録簿の ID やリンクを書かない。

## 3. 作業内容

前提: [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]]、[[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]]、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]] が完了していることを確かめてから着手する。

| No  | 作業                                                                           | 担当 | 状態 | メモ                                   |
| --- | ------------------------------------------------------------------------------ | ---- | ---- | -------------------------------------- |
| 1   | 回帰テストの完了と、更新前の検査の結果を確かめる                               | DEV  | open | -                                      |
| 2   | 公式の移行ガイドに沿って Vite と関連のツールを段階的に更新し、必要な設定を移す | DEV  | open | 依存の更新は保護された設定の扱いに従う |
| 3   | クリーンなインストール、開発・本番の動作、すべての回帰テストを確かめる         | DEV  | open | -                                      |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 方針: [[prj-0001:pjr-z7fq-frontend-test-strategy|PJR-Z7FQ フロントエンドのテストの方針を決める]]
- 起点: `openfisca-japan:tmp/dev_analysis.md` の 2.2 節・4.1 節・推奨アクション。記載された最新バージョンやテストの数は当時の調査値として扱い、今の実装と公式の情報で確かめ直す。
- 対象リポジトリ: `openfisca-japan`（`../OpenFisca-Japan`）、対象ディレクトリ: `dashboard/`
- 先行の項目: [[prj-0001:pjr-49v3-frontend-question-regression|PJR-49V3]]、[[prj-0001:pjr-bzgg-frontend-result-error-regression|PJR-BZGG]]、[[prj-0001:pjr-1rje-frontend-playwright-e2e|PJR-1RJE]]
- 後続の項目: [[prj-0001:pjr-dfwv-frontend-storybook-component-tests|PJR-DFWV]]、[[prj-0001:pjr-2csw-frontend-typescript-eslint-upgrade|PJR-2CSW]]
