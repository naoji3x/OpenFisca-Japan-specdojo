// Drive flows that other automated tests do not cover, and save artifacts for before/after comparison:
// - disaster mode from the top page to the result page (question sequence and result text)
// - share link copy, QR code, and opening the copied link
// - "save as image" download
// usage: node flows.mjs <baseURL> <outDir> [apiURL]
import { chromium } from "@playwright/test";
import { mkdirSync, writeFileSync } from "node:fs";

const [baseURL, outDir, apiURL = "http://host.docker.internal:50000"] =
  process.argv.slice(2);
mkdirSync(outDir, { recursive: true });
const FIXED = new Date("2026-01-15T12:00:00+09:00");
const STOP_MOTION =
  "*,*::before,*::after{transition:none!important;animation:none!important;caret-color:transparent!important}";

const browser = await chromium.launch();
const context = await browser.newContext({
  baseURL,
  viewport: { width: 1280, height: 800 },
  deviceScaleFactor: 1,
  reducedMotion: "reduce",
  locale: "ja-JP",
  timezoneId: "Asia/Tokyo",
  acceptDownloads: true,
});
await context.grantPermissions(["clipboard-read", "clipboard-write"], {
  origin: baseURL,
});
const report = { steps: [], errors: [] };

async function prepare(page) {
  await page.clock.setFixedTime(FIXED);
  await page.route(/googletagmanager\.com|google-analytics\.com/, (r) =>
    r.abort(),
  );
  await page.route("**/calculate", async (route) => {
    if (route.request().method() !== "POST") return route.continue();
    const response = await route.fetch({ url: `${apiURL}/calculate` });
    await route.fulfill({ response });
  });
  page.on("pageerror", (e) => report.errors.push(`pageerror: ${e.message}`));
}
const settle = async (page) => {
  await page.addStyleTag({ content: STOP_MOTION }).catch(() => {});
  await page.waitForTimeout(300);
};
const mainText = (page) =>
  page.evaluate(() => document.body.innerText.replace(/\s+/g, " ").trim());

async function answerCurrent(page) {
  const prefecture = page.getByTestId("select-prefecture");
  if (await prefecture.isVisible().catch(() => false)) {
    const options = await prefecture.locator("option").allTextContents();
    await prefecture.selectOption(
      options.includes("石川県")
        ? "石川県"
        : options.find((o) => o && !o.includes("選択")),
    );
    const city = page.getByTestId("select-city");
    await city.locator("option").nth(1).waitFor({ state: "attached" });
    await city.selectOption({ index: 1 });
    return "address";
  }
  // Questions with a count input and a 'いいえ' button (person counts): answer 'いいえ' so that
  // both versions take the same path regardless of input labels.
  const no = page.getByRole("button", { name: "いいえ", exact: true });
  if (
    await no
      .first()
      .isVisible()
      .catch(() => false)
  ) {
    await no.first().click();
    return "いいえ";
  }
  const textboxes = page.getByRole("textbox");
  const n = await textboxes.count();
  if (n > 0) {
    for (let i = 0; i < n; i++) {
      const box = textboxes.nth(i);
      const label = (await box.getAttribute("aria-label")) || "";
      await box.fill(
        /年齢|歳/.test(label) ? "30" : /人数|人/.test(label) ? "1" : "0",
      );
    }
    return `textbox x${n}`;
  }
  for (const name of ["いいえ", "いずれでもない", "はい"]) {
    const b = page.getByRole("button", { name, exact: true });
    if (
      await b
        .first()
        .isVisible()
        .catch(() => false)
    ) {
      await b.first().click();
      return name;
    }
  }
  return "none";
}

async function disaster(page) {
  await page.goto("/");
  await settle(page);
  await page.getByText("地震被災者支援制度見積もり", { exact: true }).click();
  await page.getByTestId("restrictions-checkbox").click();
  await page.getByTestId("terms-checkbox").click();
  await page.getByTestId("start-button").click();
  for (let i = 0; i < 60 && !/\/result$/.test(page.url()); i++) {
    await settle(page);
    const before = (await mainText(page)).slice(0, 160);
    const action = await answerCurrent(page);
    report.steps.push({
      i,
      url: new URL(page.url()).pathname,
      question: before,
      action,
    });
    await page.getByRole("button", { name: "次へ", exact: true }).click();
    await page.waitForTimeout(400);
  }
  await page.waitForURL(/\/result$/, { timeout: 20000 });
  await page
    .getByText("見積もり結果", { exact: true })
    .waitFor({ timeout: 20000 });
  await settle(page);
  writeFileSync(`${outDir}/disaster-result.txt`, await mainText(page));
  await page.screenshot({
    path: `${outDir}/disaster-result.png`,
    fullPage: true,
  });
}

async function shareAndImage(page) {
  // share link + QR code
  await page
    .getByRole("button", { name: "結果のリンクをコピー", exact: true })
    .click();
  await page.locator("canvas").first().waitFor({ timeout: 10000 });
  const url = await page.evaluate(() => navigator.clipboard.readText());
  writeFileSync(`${outDir}/share-url.txt`, url);
  await page
    .locator("canvas")
    .first()
    .screenshot({ path: `${outDir}/qr.png` });
  // open the copied link in a new page and capture the result text
  const page2 = await context.newPage();
  await prepare(page2);
  await page2.goto(url);
  await page2
    .getByText("見積もり結果", { exact: true })
    .waitFor({ timeout: 20000 });
  await settle(page2);
  writeFileSync(`${outDir}/shared-result.txt`, await mainText(page2));
  await page2.close();
  // save as image
  const download = page.waitForEvent("download", { timeout: 20000 });
  await page
    .getByRole("button", { name: "このページを画像で保存", exact: true })
    .click();
  const file = await download;
  await file.saveAs(`${outDir}/saved-image.png`);
  writeFileSync(`${outDir}/saved-image-name.txt`, file.suggestedFilename());
}

const page = await context.newPage();
await prepare(page);
try {
  await disaster(page);
} catch (e) {
  report.errors.push(`disaster: ${String(e.message).split("\n")[0]}`);
  await page
    .screenshot({ path: `${outDir}/disaster-FAILED.png`, fullPage: true })
    .catch(() => {});
}
try {
  if (/\/result$/.test(page.url())) await shareAndImage(page);
  else report.errors.push("share/image: skipped (no result page)");
} catch (e) {
  report.errors.push(`share/image: ${String(e.message).split("\n")[0]}`);
}
writeFileSync(`${outDir}/report.json`, JSON.stringify(report, null, 1));
await browser.close();
console.log(`steps=${report.steps.length} errors=${report.errors.length}`);
if (report.errors.length) console.log(report.errors.join("\n"));
