self.onmessage = async event => {
  if (event.data?.kind !== 'verify') return;
  try {
    const result = await WebAssembly.instantiateStreaming(fetch(new URL('probe.wasm', import.meta.url)));
    self.postMessage({ wasmResult: result.instance.exports.answer() });
  } catch (error) { self.postMessage({ error: error.message }); }
};
