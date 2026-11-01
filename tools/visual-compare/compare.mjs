// Compare two capture directories: pixel diff ratio per screen, and element/style diff above threshold.
// usage: node compare.mjs <dirA> <dirB> <diffOutDir> [thresholdRatio]
import { readdirSync, readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { PNG } from 'pngjs';
import pixelmatch from 'pixelmatch';

const [a, b, out, thr = '0.001'] = process.argv.slice(2);
const threshold = Number(thr);
mkdirSync(out, { recursive: true });
const pad = (img, w, h) => {
  const p = new PNG({ width: w, height: h });
  p.data.fill(255);
  PNG.bitblt(img, p, 0, 0, img.width, img.height, 0, 0);
  return p;
};
const STYLE_KEYS = ['color', 'bg', 'fontSize', 'fontWeight', 'fontFamily', 'padding', 'margin', 'radius', 'border', 'lineHeight'];
const rows = [];
for (const f of readdirSync(a).filter((f) => f.endsWith('.png') && !f.includes('FAILED')).sort()) {
  if (!existsSync(`${b}/${f}`)) { rows.push({ screen: f, status: 'missing-in-B' }); continue; }
  const A = PNG.sync.read(readFileSync(`${a}/${f}`));
  const B = PNG.sync.read(readFileSync(`${b}/${f}`));
  const w = Math.max(A.width, B.width), h = Math.max(A.height, B.height);
  const diff = new PNG({ width: w, height: h });
  const n = pixelmatch(pad(A, w, h).data, pad(B, w, h).data, diff.data, w, h, { threshold: 0.1 });
  const ratio = n / (w * h);
  const row = { screen: f.replace('.png', ''), sizeA: `${A.width}x${A.height}`, sizeB: `${B.width}x${B.height}`, diffPixels: n, ratio: Number((ratio * 100).toFixed(3)), verdict: ratio < threshold && A.height === B.height ? 'no-diff' : 'diff' };
  if (row.verdict === 'diff') {
    writeFileSync(`${out}/${f.replace('.png', '.diff.png')}`, PNG.sync.write(diff));
    const ja = JSON.parse(readFileSync(`${a}/${f.replace('.png', '.json')}`, 'utf8'));
    const jb = JSON.parse(readFileSync(`${b}/${f.replace('.png', '.json')}`, 'utf8'));
    const mb = new Map(jb.map((e) => [e.key, e]));
    const ma = new Map(ja.map((e) => [e.key, e]));
    const changes = [];
    for (const ea of ja) {
      const eb = mb.get(ea.key);
      if (!eb) { changes.push({ key: ea.key, change: 'removed' }); continue; }
      const d = {};
      for (const k of STYLE_KEYS) if (ea[k] !== eb[k]) d[k] = [ea[k], eb[k]];
      const boxDelta = ea.box.map((v, i) => eb.box[i] - v);
      if (boxDelta.some((v) => Math.abs(v) > 1)) d.box = [ea.box, eb.box];
      if (Object.keys(d).length) changes.push({ key: ea.key, ...d });
    }
    for (const eb of jb) if (!ma.has(eb.key)) changes.push({ key: eb.key, change: 'added' });
    row.elementChanges = changes;
  }
  rows.push(row);
}
writeFileSync(`${out}/report.json`, JSON.stringify(rows, null, 1));
for (const r of rows) console.log(`${r.verdict}\t${r.ratio}%\t${r.sizeA}->${r.sizeB}\t${r.screen}\t${r.elementChanges ? r.elementChanges.length + ' element changes' : ''}`);
