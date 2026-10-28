import { cp, mkdir, readFile, readdir, rm, stat, writeFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { createRequire } from 'node:module';
import { dirname, join, relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const runtime = join(root, 'runtime');
const require = createRequire(join(runtime, 'package.json'));
const { build } = await import(require.resolve('esbuild'));
const source = join(root, '.build/runtime');
const version = JSON.parse(await readFile(join(runtime, 'package.json'), 'utf8')).version;
const upstreamPackage = require.resolve('@file-viewer/web-full/package.json');
const upstreamMetadata = JSON.parse(await readFile(upstreamPackage, 'utf8'));
const upstreamVersion = upstreamMetadata.version;
if (upstreamVersion !== '3.3.0') throw new Error('Unexpected upstream version; update and review the pinned build inputs first.');
await rm(source, { recursive: true, force: true });
await mkdir(source, { recursive: true });
const copy = spawnSync(process.execPath,
  [join(dirname(upstreamPackage), upstreamMetadata.bin['file-viewer-copy-assets']), source, '--no-clean', '--json'],
  { cwd: runtime, encoding: 'utf8' });
if (copy.status !== 0) throw new Error(copy.stderr || copy.stdout);
const upstreamDist = join(dirname(require.resolve('@file-viewer/web-full/package.json')), 'dist');
for (const file of ['THIRD_PARTY_LICENSES.txt', 'THIRD_PARTY_LICENSES.assets.json']) {
  await cp(join(upstreamDist, file), join(source, file));
}

// This map is a build-time adapter to a pinned public distribution. It never
// probes user documents and fails if upstream moves an implementation module.
const preloads = {
  pdf: ['@file-viewer/renderer-pdf', 'pdf.js'],
  docx: ['@file-viewer/renderer-word', 'wordDocx.js'],
  xlsx: ['@file-viewer/renderer-spreadsheet', 'spreadsheet.js'],
  pptx: ['@file-viewer/renderer-presentation', 'pptx.js'],
};
await build({
  entryPoints: { runtime: join(runtime, 'src/index.mjs') },
  outdir: source, outExtension: { '.js': '.mjs' },
  bundle: true, format: 'esm', splitting: true, target: 'es2020', minify: true,
  chunkNames: 'chunks/[name]-[hash]', assetNames: 'media/[name]-[hash]',
  loader: { '.wasm': 'file', '.woff2': 'file', '.woff': 'file', '.ttf': 'file' },
  legalComments: 'linked', metafile: true,
  plugins: [{ name: 'pinned-renderer-preloads', setup(builder) {
    builder.onResolve({ filter: /^file-viewer-preload:/ }, args => {
      const entry = preloads[args.path.slice('file-viewer-preload:'.length)];
      if (!entry) throw new Error(`Unknown preloader: ${args.path}`);
      return { path: join(dirname(require.resolve(entry[0])), entry[1]) };
    });
  } }],
});
for (const file of ['index.html', 'loader.mjs', 'shell.css', 'probe-worker.mjs']) await cp(join(runtime, 'src', file), join(source, file));
// Tiny WASM module exporting answer() -> 42; used only by explicit diagnostics.
await writeFile(join(source, 'probe.wasm'), Buffer.from('0061736d010000000105016000017f03020100070a0106616e7377657200000a06010400412a0b', 'hex'));

const packs = {
  base: 'file_viewer_flutter_assets',
  cad: 'file_viewer_flutter_assets_cad',
  drawing: 'file_viewer_flutter_assets_drawing',
  typst: 'file_viewer_flutter_assets_typst',
};
const files = new Map(Object.keys(packs).map(key => [key, []]));
const assetDirectories = new Map(Object.keys(packs).map(key => [key, new Set(['assets/'])]));
for (const name of Object.values(packs)) {
  await rm(join(root, 'packages', name, 'assets'), { recursive: true, force: true });
  await mkdir(join(root, 'packages', name, 'assets'), { recursive: true });
}
async function walk(directory) {
  for (const entry of await readdir(directory, { withFileTypes: true })) {
    const path = join(directory, entry.name);
    if (entry.isDirectory()) { await walk(path); continue; }
    if (!entry.isFile()) throw new Error(`Non-regular runtime resource: ${path}`);
    const logical = relative(source, path).replaceAll('\\', '/');
    const pack = logical.startsWith('wasm/cad/') ? 'cad' : logical.startsWith('vendor/drawio/') ? 'drawing' : logical.startsWith('wasm/typst/') ? 'typst' : 'base';
    const destination = join(root, 'packages', packs[pack], 'assets', logical);
    await mkdir(dirname(destination), { recursive: true });
    await cp(path, destination);
    assetDirectories.get(pack).add(`assets/${dirname(logical) === '.' ? '' : `${dirname(logical)}/`}`);
    const data = await readFile(path);
    files.get(pack).push({ path: logical, size: data.length,
      contentType: contentType(logical), sha256: createHash('sha256').update(data).digest('hex') });
  }
}
function contentType(path) {
  const extension = path.split('.').at(-1).toLowerCase();
  return ({ html: 'text/html; charset=utf-8', css: 'text/css; charset=utf-8',
    mjs: 'text/javascript; charset=utf-8', js: 'text/javascript; charset=utf-8',
    json: 'application/json', wasm: 'application/wasm', svg: 'image/svg+xml',
    png: 'image/png', jpg: 'image/jpeg', jpeg: 'image/jpeg', gif: 'image/gif',
    webp: 'image/webp', woff: 'font/woff', woff2: 'font/woff2', ttf: 'font/ttf',
    otf: 'font/otf', txt: 'text/plain; charset=utf-8', xml: 'application/xml' })[extension] || 'application/octet-stream';
}
await walk(source);
for (const [key, name] of Object.entries(packs)) {
  const directory = join(root, 'packages', name);
  const entries = files.get(key).sort((a, b) => a.path < b.path ? -1 : a.path > b.path ? 1 : 0);
  const total = entries.reduce((sum, file) => sum + file.size, 0);
  if (total >= 200 * 1024 * 1024) throw new Error(`${name} exceeds its uncompressed resource budget.`);
  const manifest = { protocolVersion: 1, package: name, upstreamVersion, files: entries };
  await writeFile(join(directory, 'assets/manifest.json'), `${JSON.stringify(manifest)}\n`);
  await cp(join(root, 'LICENSE'), join(directory, 'LICENSE'));
  // Each shard retains the original upstream attribution ledger, even when its
  // own resource directory contains a narrower subset of the distribution.
  for (const file of ['THIRD_PARTY_LICENSES.txt', 'THIRD_PARTY_LICENSES.assets.json']) {
    await cp(join(upstreamDist, file), join(directory, file));
  }
  await writeFile(join(directory, 'pubspec.yaml'),
    `# Generated by tool/build-runtime.mjs from immutable public npm inputs.\nname: ${name}\ndescription: Offline ${key} resources for File Viewer Flutter.\nversion: ${version}\nrepository: https://github.com/flyfish-dev/file-viewer-flutter\nenvironment:\n  sdk: '>=3.13.0 <4.0.0'\n  flutter: '>=3.47.0'\ndependencies:\n  flutter:\n    sdk: flutter\nflutter:\n  assets:\n${[...assetDirectories.get(key)].sort().map(path => `    - ${path}`).join('\n')}\n`);
  if (key === 'drawing') {
    // The immutable upstream browser viewer contains a public Google OAuth
    // client identifier, not a client secret. Scope the pub detector exception
    // to that exact upstream file; do not suppress the package's other files.
    await writeFile(join(directory, 'pubspec.yaml'),
      `${await readFile(join(directory, 'pubspec.yaml'), 'utf8')}false_secrets:\n  - /assets/vendor/drawio/viewer-static.min.js\n`);
  }
  await writeFile(join(directory, 'README.md'), `# ${name}\n\nVersion-locked offline assets for file_viewer_flutter.\n\nGenerated from public File Viewer ${upstreamVersion}. Keep the included upstream license texts, notices and source offers.\n`);
  await writeFile(join(directory, 'CHANGELOG.md'), `# ${version}\n\nInitial offline resource package.\n`);
  await writeFile(join(directory, '.pubignore'), '!**\n.dart_tool/\nbuild/\npubspec.lock\n');
  console.log(`${name}: ${entries.length} files, ${(total / 1024 / 1024).toFixed(1)} MiB`);
}
console.log(`Built offline runtime from public File Viewer ${upstreamVersion}.`);
