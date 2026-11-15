---
specdojo:
  id: prj-0001:pjr-b1zq-frontend-recoil-to-jotai
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
  registered_at: "2026-10-31T23:37:23Z"
  due_on: "2026-11-30"
  derived_from:
    - PJR-0HYV
  depends_on:
    - PJR-0HYV
    - PJR-XE4E
---

# PJR-B1ZQ 状態管理を Recoil から React 標準の useSyncExternalStore による小さな入れ物に置き換える

## 1. 概要

Recoil 0.7.7 は 2024-02 を最後に更新がなく、React 19 で消えた内部の仕組み（`ReactCurrentDispatcher`）を使うため、React 19 では動かない（[[prj-0001:pjr-0hyv-frontend-react-upgrade|PJR-0HYV]] の調査）。React 19 に上げる前に、状態管理を置き換える。naoji の判断（2026-10-31）。

置き換えの方式は、naoji の判断（2026-11-15）で、当初の Jotai から、React 標準の `useSyncExternalStore` による小さな入れ物に変えた。アプリが使っているのは、単純な `atom`（`state.ts` の 10 個）と `useRecoilState`・`useRecoilValue`・`RecoilRoot` だけで、`selector`・`atomFamily`・非同期・永続化・スナップショットなど Recoil ならではの機能を使っていないため、依存を足さずに置き換えられる。Context と `useState` で置き換える案は、値が変わると読むすべての部品が描き直されるため採らない。

## 2. 完了条件

- `dashboard/src` に、React 標準の `useSyncExternalStore` を使う小さな入れ物を作る。値ごとに購読し、値が変わったときは、その値を読む部品だけが描き直される。呼び出し側の書き方は、Recoil の `useRecoilState`・`useRecoilValue` とほぼ同じ形（例: `useAtomState(householdAtom)`・`useAtomValue(householdAtom)`、更新関数は値か「前の値を受け取る関数」を受け付ける）にし、22 ファイルの書き換えを機械的で小さくする。入れ物の置き場所と名前は executor が決め、理由を「4. 対応結果」に書く。
- 入れ物そのものに単体テストを置く（初期値、値の更新、関数での更新、購読と解除、値ごとに描き直しが絞られること、テストごとに状態を初期に戻せること）。
- `openfisca-japan:dashboard/src` の Recoil の利用（2026-10-31 時点で 25 ファイル、`atom` 11 個、`useRecoilState` 37 か所・`useRecoilValue` 28 か所・`RecoilRoot` 6 か所。テストの補助を含む）を置き換え、`recoil` を依存から外す。`SetterOrUpdater` などの Recoil の型の利用も置き換える。
- アプリ全体で 1 つの入れ物を共有する今の挙動（初期値、画面の移動のあとも値が残ること）を変えない。テストの描画の補助と story の Provider も置き換え、各テストの間で状態が漏れない。
- 置き換えのとき、XState の状態の機械と重なっている値（`questionKeyAtom`・`questionKeyHistoryAtom` など）があるかを確かめ、要らない値を見つけた場合は消さずに「4. 対応結果」に書く（消すかは別に決める）。
- [[prj-0001:pjr-xe4e-frontend-state-flow-blackbox-tests|PJR-XE4E]] で足した、状態に触れずに画面の操作だけで流れを確かめるテストが、**期待値を変えずに**通る。ほかのテストで、準備のために状態を直接入れているものは、新しい入れ物に合わせて書き換えてよい（書き換えたテストと理由を書く）。
- `npm run test`・`test:ui`・`build`・`lint`・`pretty:check`・`test:e2e` が通る。見た目の期待値との比較（`bash e2e/visual/docker.sh compare`）も通る。サンドボックスで流せない検査は `requires_human` としてよく、統合のあとに orchestrator が流す。
- 依存の削除（`dashboard/package.json` の `recoil`）は保護された設定の変更になるので、executor は変更案を「4. 対応結果」と報告の `handoff` に書く。反映は統合のあとに orchestrator が naoji の承認のもとで行う。依存は足さない。
- 上流の文書・コード・コメントに、登録簿の ID やリンクを書かない。Git の設定と commit には触れない。

## 3. 作業内容

前提: [[prj-0001:pjr-0hyv-frontend-react-upgrade|PJR-0HYV]] と [[prj-0001:pjr-xe4e-frontend-state-flow-blackbox-tests|PJR-XE4E]] が完了していることを確かめてから着手する。

| No  | 作業                                 | 担当 | 状態 | メモ                                            |
| --- | ------------------------------------ | ---- | ---- | ----------------------------------------------- |
| 1   | 小さな入れ物と、その単体テストを作る | DEV  | open | -                                               |
| 2   | Recoil の利用を置き換える            | DEV  | open | -                                               |
| 3   | `recoil` を依存から外す変更案を書く  | DEV  | open | 反映は orchestrator が naoji の承認のもとで行う |
| 4   | すべての検査と見た目の比較を流す     | DEV  | open | -                                               |

## 4. 対応結果

-

## 5. 関連ドキュメント

- 由来: [[prj-0001:pjr-0hyv-frontend-react-upgrade|PJR-0HYV]]
- 後続の項目: [[prj-0001:pjr-6b0q-frontend-react19-upgrade|PJR-6B0Q]]
- 先に行う項目: [[prj-0001:pjr-xe4e-frontend-state-flow-blackbox-tests|PJR-XE4E]]（状態に触れずに流れを確かめるテスト）
