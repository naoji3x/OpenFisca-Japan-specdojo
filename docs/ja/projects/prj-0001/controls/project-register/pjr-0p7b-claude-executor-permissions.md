---
specdojo:
  id: prj-0001:pjr-0p7b-claude-executor-permissions
  type: project
  status: draft
  rulebook: specdojo:pjr-rulebook
  part_of:
    - prj-0001:pjr-index
  item_type: todo
  item_status: open
  priority: medium
  difficulty: medium
  registered_at: "2026-11-14T23:51:45Z"
  derived_from:
    - PJR-N0FE
  commit_type: chore
---

# PJR-0P7B exec の Claude の executor が、検査のコマンドを流し、個票を書けるようにする

## 1. 概要

exec が Claude の executor に渡す .specdojo/claude/settings.edit.json は編集だけを許し、Bash を許していない。PJR-N0FE で npm・npx・node が承認の待ちで止まり、project の個票も書けなかった。許すコマンドと範囲を決め、SpecDojo の側への要望も含めて直す。

## 2. 入力

- PJR-N0FE の 1 回目の run（opus-executor、2026-11-14）で、executor の中の `npm`・`npx`・`node` がすべて承認の待ちで止まり、project の worktree の個票への書き込みも拒まれた。executor は「未完了」と報告し、sol-executor で executor の段から再開して完了した。
- exec が Claude の executor に渡す `.specdojo/claude/settings.edit.json` は、`permissions.allow` が `Edit(**)` だけで、`Bash` を許していない（`deny` には保護された設定の編集と `git push`・`gh` がある）。Codex の executor はサンドボックスでコマンドを流せるため、この問題が起きない。
- 個票を書けなかったのは、`Edit(**)` が executor の作業ディレクトリ（プロダクトの worktree）の中に限られ、project の worktree がその外にあるためと見ている（確かめていない）。
- naoji の判断（2026-11-14、案 C）: 区切り 2.5 の残りは sol-executor で流し、この設定の直しは別の項目にする。
- `.specdojo/**` は保護された設定で、変更は naoji の承認のもとで行う。設定は SpecDojo が作ったもので、本来は SpecDojo の側で直すべきかもしれない。
- 担当と期限は未定（naoji に確かめる）。

## 3. 完了条件

- exec の Claude の executor が、検査のコマンド（例: `npm run test`・`lint`・`pretty:check`・`build`、`npx vitest`・`npx playwright test --list` など）を、承認の待ちで止まらずに流せる。許すコマンドは、検査に要るものに絞り、任意のコードを動かせる広い許可（`Bash(*)`・`Bash(node *)` など）は避けるか、避けられない理由を書く。
- Claude の executor が、project の worktree の個票を書ける。
- 直し方（このリポジトリの設定を直すか、SpecDojo の側に要望するか、その両方か）を決め、理由を「5. 対応結果」に書く。SpecDojo の側に要望する場合は、要望の文案を書く。
- 直したあと、Claude の executor で短い項目を 1 件流し、コマンドが止まらずに流れ、個票が書けることを確かめる。

## 4. 作業内容

| No  | 作業                                  | 担当                  | 状態 | メモ |
| --- | ------------------------------------- | --------------------- | ---- | ---- |
| 1   | 許すコマンドと範囲を決める            | _TODO_                | open | -    |
| 2   | 設定を直すか、SpecDojo の側に要望する | _TODO_                | open | -    |
| 3   | Claude の executor で流して確かめる   | specdojo-orchestrator | open | -    |

## 5. 対応結果

-

## 6. 関連ドキュメント

- 由来: [[prj-0001:pjr-n0fe-frontend-helpdesk-benefit-loan-tests|PJR-N0FE]]
