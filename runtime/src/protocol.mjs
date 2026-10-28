export const protocolVersion = 1;

const commands = new Map([
  ['reload', []], ['getState', []], ['getViewState', []],
  ['getOperationAvailability', []], ['zoomIn', []], ['zoomOut', []],
  ['resetZoom', []], ['clearDocumentSearch', []], ['nextSearchResult', []],
  ['previousSearchResult', []], ['searchDocument', ['query']],
  ['fitToView', ['fit']], ['applyViewState', ['state']],
]);

export function createProtocolSession({ container, mount, makeOptions, send, warmUp, probeRuntime }) {
  let controller;
  let documentVersion = 0;
  let destroyed = false;
  const emit = message => send({ protocolVersion, ...message });
  const options = input => makeOptions({
    fit: 'width',
    ...input,
    toolbar: input?.toolbar === false ? false : {
      ...(input?.toolbar || {}), print: false, download: false, exportHtml: false,
    },
  });
  const create = () => {
    controller = mount(container, {
      options: options(),
      onEvent: event => emit({ ...event, documentVersion }),
    });
  };
  create();

  async function dispatch(message) {
    const { id, method, arguments: args = {} } = message;
    try {
      if (destroyed) throw Object.assign(new Error('Viewer session is disposed.'), { code: 'disposed' });
      if (message.protocolVersion !== protocolVersion || !Number.isSafeInteger(id)) {
        throw Object.assign(new Error('Incompatible bridge request.'), { code: 'protocol' });
      }
      let result;
      if (method === 'load') {
        documentVersion = message.documentVersion;
        const version = documentVersion;
        const { options: viewerOptions, ...source } = args;
        await controller.load({
          ...source, options: options(viewerOptions),
          onEvent: event => emit({ ...event, documentVersion: version }),
        });
        if (destroyed || version !== documentVersion) {
          throw Object.assign(new Error('Document was replaced.'), { code: 'cancelled' });
        }
        const state = controller.getState();
        if (state.error) throw new Error(typeof state.error === 'string' ? state.error : 'Document rendering failed.');
        result = { loaded: true };
      } else if (method === 'clear') {
        documentVersion = message.documentVersion;
        controller.destroy();
        container.replaceChildren();
        create();
        result = null;
      } else if (method === 'updateOptions') {
        await controller.update({ options: options(args.options) });
        result = null;
      } else if (method === 'warmUp') {
        result = await warmUp();
      } else if (method === 'probeRuntime') {
        result = await probeRuntime();
      } else if (method === 'pause') {
        for (const media of container.querySelectorAll('video,audio')) media.pause();
        result = null;
      } else if (method === 'resume') {
        container.dispatchEvent(new Event('resize'));
        result = null;
      } else if (commands.has(method) && typeof controller[method] === 'function') {
        result = await controller[method](...commands.get(method).map(key => args[key]));
      } else {
        throw Object.assign(new Error(`Unsupported viewer operation: ${method}`), { code: 'unsupportedOperation' });
      }
      emit({ type: 'response', id, ok: true, result: result ?? null });
    } catch (error) {
      emit({ type: 'response', id, ok: false,
        error: { code: error?.code || 'loadFailed', message: error?.message || 'Viewer operation failed.' } });
    }
  }

  emit({ type: 'shellReady' });
  return {
    dispatch,
    destroy() { if (!destroyed) { destroyed = true; controller.destroy(); container.replaceChildren(); } },
  };
}

