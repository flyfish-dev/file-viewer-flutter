import test from 'node:test';
import assert from 'node:assert/strict';
import { createProtocolSession } from '../src/protocol.mjs';

function fixture() {
  const messages = [], loads = [], mountedOptions = [];
  let resolveLoad;
  let delayed = false;
  const controller = { destroy() {}, getState() { return {}; }, async update() {},
    async load(options) { loads.push(options); if (delayed) await new Promise(resolve => { resolveLoad = resolve; }); },
    searchDocument(query) { return { query }; },
  };
  const session = createProtocolSession({ container: { replaceChildren() {}, querySelectorAll() { return []; } },
    mount(_, options) { mountedOptions.push(options); return controller; }, makeOptions: options => options,
    send: message => messages.push(message), warmUp: async () => ({ moduleReady: ['pdf'], engineReady: [] }) });
  let id = 0;
  return { session, messages, loads, mountedOptions,
    request: (method, args = {}, documentVersion = 1) => session.dispatch({ protocolVersion: 1, id: ++id, method, arguments: args, documentVersion }),
    delay() { delayed = true; }, finish() { delayed = false; resolveLoad(); } };
}

test('unknown commands and protocol versions produce typed errors', async () => {
  const f = fixture(); await f.request('notAnOperation');
  assert.equal(f.messages.at(-1).error.code, 'unsupportedOperation');
  await f.session.dispatch({ protocolVersion: 2, id: 5, method: 'reload' });
  assert.equal(f.messages.at(-1).error.code, 'protocol');
});
test('replacement cancels a stale load and binds its lifecycle events to the old version', async () => {
  const f = fixture(); f.delay(); const old = f.request('load', { filename: 'first.txt' }, 1);
  await f.request('clear', {}, 2); f.finish(); await old;
  assert.equal(f.messages.at(-1).error.code, 'cancelled');
  f.loads[0].onEvent({ type: 'rendered' });
  assert.equal(f.messages.at(-1).documentVersion, 1);
});
test('toolbar false is preserved and browser-only output actions stay disabled', async () => {
  const f = fixture(); await f.request('load', { options: { toolbar: false } });
  assert.equal(f.loads[0].options.toolbar, false);
  await f.request('load', { options: { theme: 'dark' } }, 2);
  assert.equal(f.loads[1].options.theme, 'dark');
  assert.equal(f.loads[1].options.toolbar.exportHtml, false);
});
test('format-aware fit is used for warm-up and loads without overriding explicit fit', async () => {
  const f = fixture();
  assert.equal(f.mountedOptions[0].options.fit, 'auto');
  await f.request('load', { filename: 'sheet.xlsx' });
  assert.equal(f.loads[0].options.fit, 'auto');
  await f.request('load', { options: { fit: { mode: 'contain', maxScale: 1 } } }, 2);
  assert.deepEqual(f.loads[1].options.fit, { mode: 'contain', maxScale: 1 });
});
test('module warm-up never claims that document engines are already initialized', async () => {
  const f = fixture(); await f.request('warmUp');
  assert.deepEqual(f.messages.at(-1).result, { moduleReady: ['pdf'], engineReady: [] });
});
