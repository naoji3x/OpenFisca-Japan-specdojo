# visual-compare

OpenFisca-Japan の `dashboard` の画面を、2 つの版で同じ条件で撮り、見た目の違いを機械的に比べるための道具です（PJR-HQBE で作成）。

## 使い方

```bash
cd tools/visual-compare
npm install
# 比べる 2 つの版を、それぞれ build して preview で起動しておく（例: 30101 と 30102）
node capture.mjs http://127.0.0.1:30101 /tmp/shots-before ../../../OpenFisca-Japan/dashboard/src/mocks/calculate
node capture.mjs http://127.0.0.1:30102 /tmp/shots-after  ../../../OpenFisca-Japan/dashboard/src/mocks/calculate
node compare.mjs /tmp/shots-before /tmp/shots-after /tmp/diff
```

- `capture.mjs <baseURL> <outDir> <fixturesDir>`: 13 の画面を PC（1280×800）とスマートフォン（390×844）で撮り、画像（`.png`）と主な要素の位置・スタイル（`.json`）を出力する。日時の固定、アニメーションの停止、計算 API の固定の応答、GTM の遮断で、毎回同じ結果になるようにしている。外部のフォントは既定で止める。`ALLOW_FONTS=1` で読み込む。`ONLY=<画面名,…>` で画面を絞れる。
- `compare.mjs <dirA> <dirB> <diffOutDir> [threshold]`: 画面ごとに違う画素の割合を出し、しきい値（既定 0.001 = 0.1%）未満なら `no-diff` とする。超えた画面は差の画像（`.diff.png`）と、要素の位置・スタイルの差（`report.json` の `elementChanges`）を出力する。
- 撮った画像は、上流のリポジトリにも、このリポジトリにも commit しない。

## 先に確かめること

- 同じ版を 2 回撮って `compare.mjs` で比べ、すべて `no-diff` になること（撮り方が安定していること）。
- 撮る手順は今の画面の `data-testid` と文言に合わせている。画面が変わったら `capture.mjs` の `scenarios` を直す。
