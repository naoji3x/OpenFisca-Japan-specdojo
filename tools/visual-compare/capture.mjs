// Capture screenshots and element styles of the dashboard for visual comparison.
// usage: node capture.mjs <baseURL> <outDir> <fixturesDir>
import { chromium } from '@playwright/test';
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';

const [baseURL, outDir, fixturesDir] = process.argv.slice(2);
mkdirSync(outDir, { recursive: true });
const fixture = (name) =>
  JSON.parse(readFileSync(`${fixturesDir}/${name}.response.json`, 'utf8'));
const viewports = {
  desktop: { width: 1280, height: 800 },
  mobile: { width: 390, height: 844 },
};
const FIXED = new Date('2026-01-15T12:00:00+09:00');
const STOP_MOTION = `*,*::before,*::after{transition:none!important;animation:none!important;caret-color:transparent!important}`;

async function settle(page) {
  await page.addStyleTag({ content: STOP_MOTION }).catch(() => {});
  await page.waitForLoadState('networkidle').catch(() => {});
  await page.evaluate(() => document.fonts && document.fonts.ready).catch(() => {});
  await page.waitForTimeout(400);
}

async function styles(page) {
  return page.evaluate(() => {
    const sel = 'h1,h2,h3,h4,h5,h6,p,button,a,input,select,label,[role="button"],[role="checkbox"],[role="dialog"],img';
    const out = [];
    const seen = {};
    for (const el of document.querySelectorAll(sel)) {
      const r = el.getBoundingClientRect();
      if (r.width === 0 && r.height === 0) continue;
      const cs = getComputedStyle(el);
      if (cs.visibility === 'hidden' || cs.display === 'none') continue;
      const text = (el.getAttribute('aria-label') || el.textContent || el.getAttribute('alt') || '').trim().replace(/\s+/g, ' ').slice(0, 40);
      const base = `${el.tagName.toLowerCase()}|${text}`;
      seen[base] = (seen[base] || 0) + 1;
      out.push({
        key: `${base}|${seen[base]}`,
        box: [r.x, r.y + window.scrollY, r.width, r.height].map((v) => Math.round(v)),
        color: cs.color, bg: cs.backgroundColor, fontSize: cs.fontSize, fontWeight: cs.fontWeight,
        fontFamily: cs.fontFamily.split(',')[0], padding: cs.padding, margin: cs.margin,
        radius: cs.borderRadius, border: `${cs.borderTopWidth} ${cs.borderTopStyle} ${cs.borderTopColor}`,
        lineHeight: cs.lineHeight,
      });
    }
    return out;
  });
}

async function shoot(page, name, vp) {
  await settle(page);
  await page.screenshot({ path: `${outDir}/${name}.${vp}.png`, fullPage: true });
  writeFileSync(`${outDir}/${name}.${vp}.json`, JSON.stringify(await styles(page), null, 1));
}

async function start(page, mode) {
  await page.goto('/');
  await settle(page);
  await page.getByTestId(mode === 'simple' ? 'calculate-simple-button' : 'calculate-detail-button').click();
}

async function agree(page) {
  await page.getByTestId('restrictions-checkbox').click();
  await page.getByTestId('terms-checkbox').click();
  await page.getByTestId('start-button').click();
}

const next = (page) => page.getByRole('button', { name: '次へ', exact: true }).click();

async function simpleToResult(page, response) {
  await page.route('**/calculate', (route) =>
    route.request().method() === 'POST'
      ? response === 500
        ? route.fulfill({ status: 500, body: 'Calculation failed' })
        : route.fulfill({ json: response })
      : route.continue());
  await start(page, 'simple');
  await agree(page);
  await page.getByTestId('select-prefecture').selectOption('東京都');
  await page.getByTestId('select-city').selectOption('渋谷区');
  await next(page);
  await page.getByTestId('amount-input').fill('0');
  await next(page);
  await page.getByRole('button', { name: 'いいえ', exact: true }).click();
  await next(page);
  await page.getByRole('button', { name: 'いいえ', exact: true }).click();
  await next(page);
  await page.waitForTimeout(800);
}

const scenarios = {
  'top': async (p) => { await p.goto('/'); },
  'terms-modal': async (p) => { await start(p, 'simple'); },
  'simple-q1-address': async (p) => { await start(p, 'simple'); await agree(p); },
  'simple-q2-income': async (p) => {
    await start(p, 'simple'); await agree(p);
    await p.getByTestId('select-prefecture').selectOption('東京都');
    await p.getByTestId('select-city').selectOption('渋谷区');
    await next(p);
  },
  'simple-q3-spouse': async (p) => {
    await start(p, 'simple'); await agree(p);
    await p.getByTestId('select-prefecture').selectOption('東京都');
    await p.getByTestId('select-city').selectOption('渋谷区');
    await next(p); await p.getByTestId('amount-input').fill('0'); await next(p);
  },
  'detailed-q1-address': async (p) => { await start(p, 'detailed'); await agree(p); },
  'result-benefit-only': (p) => simpleToResult(p, fixture('benefit-only')),
  'result-loan-only': (p) => simpleToResult(p, fixture('loan-only')),
  'result-both': (p) => simpleToResult(p, fixture('both')),
  'result-none': (p) => simpleToResult(p, fixture('none')),
  'error-api-500': (p) => simpleToResult(p, 500),
  'not-found': async (p) => { await p.goto('/no-such-page'); },
  'disaster-q1': async (p) => {
    await p.goto('/'); await settle(p);
    await p.getByText('地震被災者支援制度見積もり', { exact: true }).click();
    await agree(p);
  },
};

const only = process.env.ONLY ? process.env.ONLY.split(',') : null;
const browser = await chromium.launch();
const failures = [];
for (const [vp, size] of Object.entries(viewports)) {
  for (const [name, run] of Object.entries(scenarios)) {
    if (only && !only.includes(name)) continue;
    const context = await browser.newContext({ baseURL, viewport: size, deviceScaleFactor: 1, reducedMotion: 'reduce', locale: 'ja-JP', timezoneId: 'Asia/Tokyo' });
    const page = await context.newPage();
    await page.clock.setFixedTime(FIXED);
    await page.route(process.env.ALLOW_FONTS ? /googletagmanager\.com|google-analytics\.com/ : /fonts\.(googleapis|gstatic)\.com|googletagmanager\.com|google-analytics\.com/, (r) => r.abort());
    try { await run(page); await shoot(page, name, vp); }
    catch (e) { failures.push(`${name}.${vp}: ${String(e.message).split('\n')[0]}`); await page.screenshot({ path: `${outDir}/${name}.${vp}.FAILED.png`, fullPage: true }).catch(() => {}); }
    await context.close();
  }
}
await browser.close();
writeFileSync(`${outDir}/_failures.txt`, failures.join('\n'));
console.log(`captured into ${outDir}; failures: ${failures.length}`);
if (failures.length) console.log(failures.join('\n'));
