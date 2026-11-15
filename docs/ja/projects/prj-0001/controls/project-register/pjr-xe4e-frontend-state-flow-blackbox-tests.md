---
specdojo:
  id: prj-0001:pjr-xe4e-frontend-state-flow-blackbox-tests
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
  registered_at: "2026-11-15T01:56:39Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-1EB8
  commit_type: test
---

# PJR-XE4E Recoil に依存しない、画面の操作だけで流れを確かめるテストを足す

## 1. 概要

今のテストの多くは準備で RecoilRoot に状態を直接入れており、状態管理の置き換えでテストも書き換えることになる。準備で状態に触れず、画面の操作だけで、答える・結果・戻って答え直す・共有 URL で開き直す流れを確かめるテストを足す。

## 2. 入力

- naoji の判断（2026-11-15）: 状態管理を Recoil から React 標準の `useSyncExternalStore` による小さな入れ物に置き換える（[[prj-0001:pjr-b1zq-frontend-recoil-to-jotai|PJR-B1ZQ]]）前に、状態に触れずに画面の操作だけで流れを確かめるテストを足す。B1ZQ はこの項目を先に終わっているべき項目にした。
- 今のテストの多くは、準備で `RecoilRoot` に状態を直接入れている（区切り 1 の `questionTemplateTestUtils.tsx`・`resultTestUtils.tsx`、区切り 2.5 の `calculate.test.tsx`・`shareResultTestUtils.tsx` など）。状態管理を置き換えると、これらのテストの準備も書き換えることになり、置き換えの前後の比較には使えない。
- 区切り 6 のあとに、上流への PR の区切りとして行う。統合先は、流す前に決める。
- executor はネットワークに出られず、サンドボックスではブラウザーや Docker を起動できないことがある。`test:ui` と見た目の比較は `requires_human` としてよく、統合のあとに orchestrator が 3 回流す。`npm ci` と `npx playwright install` は流さない。依存は足さない。
- 描画のあとに現れる要素は `find…` か `expect.poll` で待って探す。子の要素と文字が混ざる要素は、役割と名前で探す。Chakra UI の内部の class 名や DOM の細かい構造には頼らない。アプリの不具合を見つけたら、正しい期待値で書いて Vitest の `it.fails` にし、「5. 対応結果」に書く（区切り 2.5 の決まり）。

## 3. 完了条件

- テストの準備で、状態（Recoil の `RecoilRoot` の初期値、`atom` の値など）に直接触れない。アプリ全体（ルーティングを含む `App` かそれに近いもの）を描画し、計算の API の応答だけを差し替えて、画面の操作だけで次の流れを確かめる（Browser Mode）。
  - かんたん・くわしく・災害の各モードで、トップから同意・答える・結果まで進み、結果の画面に期待する制度が出る。
  - 結果の画面から戻って答えを変え、もう一度結果まで進むと、結果が答えに合わせて変わる（前の答えや結果が残らない）。
  - 結果の画面の共有 URL を、新しい描画（状態が空の状態）で開くと、同じ結果とモードが出る。
  - 途中で戻ると、前の答えが入った状態で表示される。
- 状態管理の置き換え（PJR-B1ZQ）のあとも、**このテストを書き換えずに**通すことを前提にする。そのため、状態の名前・型・置き場所に依存するコードをテストに書かない（読み込む補助も含む）。依存してしまう箇所があれば、その理由を書く。
- 今のテストのうち、準備で状態に直接触れているものを一覧にし、「5. 対応結果」に書く（B1ZQ で書き換える対象になる）。
- `dashboard` で `npm run test`・`test:ui`・`build`・`lint`・`pretty:check`・`test:e2e` が通る。アプリのコードは変えない。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。保護された設定（`dashboard/package.json`・`.github/workflows/**` など）は書き換えず、変更が要る場合は変更案を「5. 対応結果」と報告の `handoff` に書く。

## 4. 作業内容

| No  | 作業                                       | 担当 | 状態 | メモ |
| --- | ------------------------------------------ | ---- | ---- | ---- |
| 1   | 状態に直接触れているテストを一覧にする     | DEV  | open | -    |
| 2   | 画面の操作だけで流れを確かめるテストを足す | DEV  | open | -    |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-1eb8-frontend-pr-assurance|PJR-1EB8]]
- 後続の項目: [[prj-0001:pjr-b1zq-frontend-recoil-to-jotai|PJR-B1ZQ]]（状態管理の置き換え）
