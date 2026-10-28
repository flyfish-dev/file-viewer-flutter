import { mountViewer, withFullViewerOptions } from '@file-viewer/web-full';
import { createProtocolSession, protocolVersion } from './protocol.mjs';

const preloaders = {
  pdf: () => import('file-viewer-preload:pdf'),
  docx: () => import('file-viewer-preload:docx'),
  xlsx: () => import('file-viewer-preload:xlsx'),
  pptx: () => import('file-viewer-preload:pptx'),
};
let warming;

async function warmUp() {
  return warming ??= (async () => {
    const moduleReady = [];
    for (const [name, load] of Object.entries(preloaders)) {
      await load();
      moduleReady.push(name);
      // Yield between parsers so prewarming does not monopolize the UI thread.
      await new Promise(resolve => setTimeout(resolve, 0));
    }
    // Module evaluation is measurable. Worker/WASM initialization is not claimed
    // here: renderer-specific initialization still occurs on the first document.
    return { moduleReady, engineReady: [] };
  })().catch(error => { warming = undefined; throw error; });
}

function makeOptions(input, bases) {
  const defaults = withFullViewerOptions(input, bases.base);
  const base = new URL(bases.base).href;
  const remap = value => {
    if (typeof value === 'string' && value.startsWith(base)) {
      const path = value.slice(base.length);
      const pack = path.startsWith('wasm/cad/') ? 'cad' : path.startsWith('vendor/drawio/') ? 'drawing' : path.startsWith('wasm/typst/') ? 'typst' : 'base';
      return new URL(path, bases[pack] || base).href;
    }
    if (Array.isArray(value)) return value.map(remap);
    if (value && Object.getPrototypeOf(value) === Object.prototype) return Object.fromEntries(Object.entries(value).map(([key, item]) => [key, remap(item)]));
    return value;
  };
  return remap(defaults);
}

function create(container, configuration, callback) {
  if (!(container instanceof HTMLElement)) throw new TypeError('A viewer container is required.');
  const bases = configuration.assetBases;
  if (!bases?.base) throw new Error('Offline resource base is missing.');
  return createProtocolSession({
    container, mount: mountViewer,
    makeOptions: input => makeOptions(input, bases),
    send: message => callback(JSON.stringify(message)),
    warmUp,
    async probeRuntime() {
      const worker = new Worker(new URL('probe-worker.mjs', bases.base), { type: 'module' });
      let timer;
      try {
        return await new Promise((resolve, reject) => {
          timer = setTimeout(() => reject(new Error('Packaged Worker/WASM probe timed out.')), 15000);
          worker.onmessage = event => {
            if (event.data?.wasmResult === 42) resolve({ workerExecuted: true, wasmResult: 42 });
            else reject(new Error(event.data?.error || 'Packaged WASM probe failed.'));
          };
          worker.onerror = () => reject(new Error('Packaged module Worker could not execute.'));
          worker.postMessage({ kind: 'verify' });
        });
      } finally { clearTimeout(timer); worker.terminate(); }
    },
  });
}

function bootstrapNative(configuration) {
  const send = message => {
    if (globalThis.flutter_inappwebview?.callHandler) {
      void globalThis.flutter_inappwebview.callHandler('fileViewerEvent', message);
    } else if (typeof globalThis.FileViewerCef === 'function') {
      globalThis.FileViewerCef(JSON.parse(message), () => {});
    }
  };
  globalThis.__fileViewerFlutterSession?.destroy();
  globalThis.__fileViewerFlutterSession = create(document.getElementById('viewer'), configuration, send);
  globalThis.__fileViewerFlutterDispatch = message => globalThis.__fileViewerFlutterSession.dispatch(message);
}

globalThis.FileViewerFlutter = { protocolVersion, create, warmUp, bootstrapNative };
globalThis.dispatchEvent(new Event('file-viewer-runtime-ready'));

