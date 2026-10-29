import { createServer } from 'node:http';
import { mkdir, readFile, stat, writeFile } from 'node:fs/promises';
import { createRequire } from 'node:module';
import { dirname, extname, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const webRoot = resolve(process.argv[2] || resolve(root, 'example/build/web'));
const output = resolve(process.argv[3] || resolve(root, '.release/web'));
await mkdir(output, { recursive: true });
const require = createRequire(resolve(root, 'runtime/package.json'));
const { chromium } = require('playwright');
const types = { '.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript',
  '.json': 'application/json', '.wasm': 'application/wasm', '.css': 'text/css', '.svg': 'image/svg+xml',
  '.png': 'image/png', '.woff2': 'font/woff2', '.ttf': 'font/ttf', '.otf': 'font/otf' };
const requests = [];
const server = createServer(async (request, response) => {
  try {
    const pathname = decodeURIComponent(new URL(request.url, 'http://localhost').pathname);
    const path = resolve(webRoot, `.${pathname === '/' ? '/index.html' : pathname}`);
    if (!path.startsWith(`${webRoot}${sep}`)) { response.writeHead(403).end(); return; }
    const info = await stat(path);
    if (!info.isFile()) { response.writeHead(404).end(); return; }
    const type = types[extname(path)] || 'application/octet-stream';
    response.writeHead(200, { 'Content-Type': type, 'Content-Length': info.size, 'Cache-Control': 'no-store' });
    requests.push({ path: pathname, type, size: info.size });
    if (request.method === 'HEAD') response.end(); else response.end(await readFile(path));
  } catch (_) { response.writeHead(404).end(); }
});
await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
const origin = `http://127.0.0.1:${server.address().port}`;
const executablePath = process.env.CHROME_EXECUTABLE || (process.platform === 'darwin' ? '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' : undefined);
const browser = await chromium.launch({ executablePath, headless: true });
try {
  const context = await browser.newContext({ viewport: { width: 1280, height: 900 } });
  await context.addInitScript(() => {
    globalThis.__viewerEvidence = { events: [], sessions: [] };
    addEventListener('file-viewer-runtime-ready', () => {
      const create = FileViewerFlutter.create;
      FileViewerFlutter.create = (container, config, callback) => {
        const session = create(container, config, message => {
          __viewerEvidence.events.push(JSON.parse(message));
          callback(message);
        });
        __viewerEvidence.sessions.push(session);
        return session;
      };
    });
  });
  const external = [], errors = [];
  await context.route('**/*', route => {
    const url = new URL(route.request().url());
    if (['http:', 'https:'].includes(url.protocol) && url.origin !== origin) {
      external.push(`${url.origin}${url.pathname}`); return route.abort('blockedbyclient');
    }
    return route.continue();
  });
  const page = await context.newPage();
  page.on('pageerror', error => { errors.push(error.message); });
  await page.goto(origin);
  await page.waitForSelector('flt-glass-pane', { state: 'attached', timeout: 60000 });
  const accessibility = page.locator('flt-semantics-placeholder');
  await accessibility.waitFor({ state: 'attached', timeout: 15000 }).catch(() => {});
  if (await accessibility.count()) await accessibility.evaluate(element => element.click());
  await page.waitForFunction(() => Boolean(globalThis.FileViewerFlutter), undefined, { timeout: 60000 });
  await page.screenshot({ path: resolve(output, 'home.png'), fullPage: true });
  const accessibilityTree = await page.locator('body').ariaSnapshot();
  const documents = [];
  for (const name of ['Text', 'PDF', 'Word', 'Excel', 'PowerPoint']) {
    const started = Date.now();
    const before = await page.evaluate(() => __viewerEvidence.events.filter(event => event.type === 'load-complete').length);
    await page.getByRole('button', { name, exact: true }).click();
    try {
      await page.waitForFunction(count => __viewerEvidence.events.filter(event => event.type === 'load-complete').length > count,
        before, { timeout: 60000 });
    } catch (error) {
      await page.screenshot({ path: resolve(output, 'failure.png'), fullPage: true });
      await writeFile(resolve(output, 'failure.json'), JSON.stringify({ name, external, errors,
        events: await page.evaluate(() => __viewerEvidence.events), tree: await page.locator('body').ariaSnapshot() }, null, 2));
      throw error;
    }
    // The renderer's first paint happens after load-complete. The responsive
    // workspace keeps one preview surface while the document selector changes.
    await page.waitForTimeout(500);
    await page.evaluate(async () => { await document.fonts.ready; await new Promise(requestAnimationFrame); });
    await page.screenshot({ path: resolve(output, `${name.toLowerCase()}.png`) });
    documents.push({ name, elapsedMs: Date.now() - started });
  }
  const workerProbe = await page.evaluate(async () => {
    const evidence = __viewerEvidence;
    await evidence.sessions.at(-1).dispatch({ protocolVersion: 1, id: 1000000000, method: 'probeRuntime' });
    return evidence.events.find(event => event.id === 1000000000);
  });
  if (!workerProbe?.ok || workerProbe.result?.wasmResult !== 42) throw new Error('Worker/WASM probe failed.');
  const evidence = { browser: browser.version(), external, errors, requests, accessibilityTree, documents, workerProbe };
  await writeFile(resolve(output, 'CURRENT.json'), `${JSON.stringify(evidence, null, 2)}\n`);
  console.log(JSON.stringify({ browser: evidence.browser, external, errors, documents }, null, 2));
  if (external.length || errors.length) throw new Error('Offline browser verification found external requests or JavaScript errors.');
} finally {
  await browser.close();
  await new Promise(resolve => server.close(resolve));
}
