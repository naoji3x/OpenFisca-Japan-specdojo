---
specdojo:
  id: prj-0001:pjr-t3w9-frontend-chakra-v3-readiness-tests
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
  priority: medium
  difficulty: medium
  owner: DEV
  registered_at: "2026-11-15T01:56:36Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-1EB8
  commit_type: test
---

# PJR-T3W9 Chakra UI v3 に備えて、画面の部品の動きと見た目の期待値を足す

## 1. 概要

Chakra UI v3 は部品の API・DOM・テーマ・アニメーション・アイコンが大きく変わる。移行の前に、Tooltip と Progress の表示、全部のアコーディオンの開閉とキー操作、入力の誤りの表示を確かめるテストと、開いた状態などの見た目の期待値を足す。

## 2. 入力

- naoji の判断（2026-11-15）: Chakra UI v3（[[prj-0001:pjr-erdk-frontend-chakra-ui-v3|PJR-ERDK]]）は破壊的な変更が多いので、移行の前に、画面の部品の動きと見た目を固定するテストを足す。ERDK はこの項目を先に終わっているべき項目にした。
- 2026-11-15 に orchestrator が `develop`（`dbfa6ae`）で数えた Chakra UI の使い方: 45 種類を読み込む。v3 で大きく変わるもののうち、使っているのは Accordion（給付・貸付・該当する制度）、Modal（同意の画面）、FormControl・FormLabel・Input・Select・Checkbox（質問の入力テンプレート）、Button の読み込み中（画像で保存）、Tooltip（貸付の「i」のアイコン、`loan.tsx`）、Progress（質問の進み具合のバー、`questionFrame.tsx`）、テーマ（`main.tsx` の `extendTheme`・`defineStyleConfig`）、アイコン（`@chakra-ui/icons` の `ExternalLinkIcon`・`InfoIcon`）。
- 今のテストの備え（2026-11-15 の orchestrator の整理）: Modal・入力テンプレート・Button の読み込み中は、区切り 1・2.5 のテストでほぼ足りている。足りないのは、Tooltip の開閉と中の文字（テストなし）、Progress のバーの表示（値の計算だけをテストしている）、全部のアコーディオンでの開閉の状態とキー操作、入力の誤りの表示の見た目、開いた状態などの見た目の期待値。
- 区切り 6 のあとに、上流への PR の区切り（例: 区切り 6.5）として行う。統合先は、流す前に決める。
- executor はネットワークに出られず、サンドボックスではブラウザーや Docker を起動できないことがある。`test:ui` と見た目の比較は `requires_human` としてよく、統合のあとに orchestrator が 3 回流す。`npm ci` と `npx playwright install` は流さない。依存は足さない。
- 描画のあとに現れる要素は `find…` か `expect.poll` で待って探す。子の要素と文字が混ざる要素は、役割と名前で探す。Chakra UI の内部の class 名や DOM の細かい構造には頼らない。アプリの不具合を見つけたら、正しい期待値で書いて Vitest の `it.fails` にし、「5. 対応結果」に書く（区切り 2.5 の決まり）。

## 3. 完了条件

- Tooltip（貸付の「i」のアイコン）を、マウスを乗せる・キーでフォーカスする・離れる操作で、開く・中の文字・閉じることを、Browser Mode で確かめる。
- Progress（質問の進み具合のバー）が、質問の進みに応じた値（`aria-valuenow` などの、役割と値）で表示されることを、Browser Mode で確かめる。
- 結果の画面の全部のアコーディオン（給付・貸付・該当する制度）で、開閉の状態（`aria-expanded`）と、キー（Enter・Space・矢印）での操作を確かめる。
- 入力の誤りの表示（未入力で「次へ」を押したときなど）が出ることと、その文字を確かめる。
- 見た目の期待値（`dashboard/e2e/visual/screens.spec.ts`）に、アコーディオンを開いた状態・ツールチップを開いた状態・入力の誤りの表示・画像で保存の読み込み中を足す。期待値は orchestrator が統合のあとに、`develop` の版から `bash e2e/visual/docker.sh capture` で撮る（executor は撮らない）。
- 上の部品のうち、テストで確かめたもの・確かめなかったものと理由を、部品ごとの表で「5. 対応結果」に書く。
- `dashboard` で `npm run test`・`test:ui`・`build`・`lint`・`pretty:check`・`test:e2e` が通る。アプリのコードは変えない。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。保護された設定（`dashboard/package.json`・`.github/workflows/**` など）は書き換えず、変更が要る場合は変更案を「5. 対応結果」と報告の `handoff` に書く。

## 4. 作業内容

| No  | 作業                                                        | 担当 | 状態 | メモ |
| --- | ----------------------------------------------------------- | ---- | ---- | ---- |
| 1   | 部品ごとに、今のテストの備えと足りないところを洗い出す      | DEV  | open | -    |
| 2   | Tooltip・Progress・アコーディオン・入力の誤りのテストを足す | DEV  | open | -    |
| 3   | 見た目の期待値の場面を足す（撮るのは orchestrator）         | DEV  | open | -    |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-1eb8-frontend-pr-assurance|PJR-1EB8]]
- 後続の項目: [[prj-0001:pjr-erdk-frontend-chakra-ui-v3|PJR-ERDK]]（Chakra UI v3 への移行）
