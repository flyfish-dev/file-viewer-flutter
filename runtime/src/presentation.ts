import { PptxViewer, RECOMMENDED_ZIP_LIMITS } from '@file-viewer/pptx';
import {
  createFileViewerTranslator,
  createFileViewerZoomChangeEmitter,
  createFileViewerViewStateChangeEmitter,
  getFileViewerShadowRootForNode,
  registerFileViewerZoomProvider,
  unregisterFileViewerZoomProvider,
  registerFileViewerViewStateProvider,
  unregisterFileViewerViewStateProvider,
  resolveFileViewerFitScale,
  type FileRenderHandler,
  type FileViewerFitRequest,
  type FileViewerFitResult,
  type FileViewerViewState,
  type FileViewerViewStateChangeSource,
  type FileViewerViewStateChangeAction,
} from '@file-viewer/core';

// Flutter owns a bounded native viewport rather than a natural-height document
// page. Keep parsing, drawing, charts, media and slideshow in the immutable
// upstream engine; this adapter owns only viewport controls and core providers.
export const renderPresentation: FileRenderHandler = async (buffer, target, _type, context) => {
  const document = target.ownerDocument;
  const t = createFileViewerTranslator(context?.options);
  const zoomEvents = createFileViewerZoomChangeEmitter();
  const viewEvents = createFileViewerViewStateChangeEmitter();
  const element = (tag: string, className: string) => {
    const node = document.createElement(tag);
    node.className = className;
    return node;
  };
  const style = document.createElement('style');
  style.textContent = `
.fv-presentation{position:relative;display:flex;flex-direction:column;width:100%;height:100%;min-height:0;overflow:hidden;box-sizing:border-box;background:var(--file-viewer-render-surface-background,#edf2f7);color:var(--file-viewer-text,#172033)}
.fv-presentation-nav{display:flex;align-items:center;justify-content:space-between;flex:0 0 36px;padding:0 10px;gap:8px;border-bottom:1px solid var(--file-viewer-border,rgba(20,35,53,.08));font:12px/1.4 system-ui,sans-serif}
.fv-presentation-pages{display:flex;align-items:center;gap:8px;white-space:nowrap}
.fv-presentation button{border:0;border-radius:6px;background:transparent;color:inherit;padding:5px 8px;font:inherit;cursor:pointer}
.fv-presentation button:hover{background:rgba(100,116,139,.12)}
.fv-presentation button:focus-visible{outline:2px solid #0891b2;outline-offset:1px}
.fv-presentation button:disabled{opacity:.35;cursor:default}
.fv-presentation-scroll{position:relative;flex:1 1 0;min-height:0;min-width:0;overflow:auto;overscroll-behavior:contain;padding:16px;box-sizing:border-box}
.fv-presentation-surface{position:relative;min-height:100%;width:100%;box-sizing:border-box}
.fv-presentation .flyfish-pptx-scale-box{max-width:none;margin:0 auto}
.fv-presentation .slide{box-shadow:0 8px 24px rgba(15,23,42,.12);color-scheme:only light;forced-color-adjust:none}
.fv-presentation .flyfish-pptx-slide-slot:last-child .slide,.fv-presentation .flyfish-pptx-content>.slide:last-child{margin-bottom:0}
[data-viewer-theme='dark'] .fv-presentation,:host([data-viewer-theme='dark']) .fv-presentation{background:var(--file-viewer-render-surface-background,#101820)}
@media(prefers-color-scheme:dark){[data-viewer-theme='system'] .fv-presentation,:host([data-viewer-theme='system']) .fv-presentation{background:var(--file-viewer-render-surface-background,#101820)}}
@media(max-width:480px){.fv-presentation-scroll{padding:10px}}
`;
  const shell = element('section', 'fv-presentation');
  shell.setAttribute('aria-label', 'Presentation preview');
  const nav = element('div', 'fv-presentation-nav');
  const pages = element('div', 'fv-presentation-pages');
  const previous = document.createElement('button');
  previous.type = 'button';
  previous.textContent = '‹';
  previous.setAttribute('aria-label', 'Previous slide');
  const counter = document.createElement('span');
  counter.setAttribute('aria-live', 'polite');
  const next = document.createElement('button');
  next.type = 'button';
  next.textContent = '›';
  next.setAttribute('aria-label', 'Next slide');
  const slideshow = document.createElement('button');
  slideshow.type = 'button';
  const scroller = element('div', 'fv-presentation-scroll');
  const surface = element('div', 'fv-presentation-surface');
  scroller.append(surface);
  pages.append(previous, counter, next);
  nav.append(pages, slideshow);
  shell.append(nav, scroller);
  // The stock core intentionally leaves presentation surfaces at natural
  // height. Establish the native viewport contract on both shadow boundaries.
  const host = context?.surface?.host || target;
  const oldHostHeight = host.style.height;
  const oldTargetHeight = target.style.height;
  host.style.height = '100%';
  target.style.height = '100%';
  target.replaceChildren(style, shell);

  let viewer: PptxViewer | undefined;
  let disposed = false;
  let page = 1;
  let scale = 1;
  let layoutChanges = 0;
  const layoutFrames = new Set<number>();
  const pendingFrames = new Map<number, () => void>();
  let presentationTransition = 0;
  let restoringReadingPage = false;
  let readingRestored = Promise.resolve();
  const nextLayoutFrame = () => new Promise<void>(resolve => {
    const frame = document.defaultView!.requestAnimationFrame(() => {
      pendingFrames.delete(frame);
      resolve();
    });
    pendingFrames.set(frame, resolve);
  });
  let rejectReady: ((error: unknown) => void) | undefined;
  const readViewport = () => {
    const css = document.defaultView!.getComputedStyle(scroller);
    return {
      width: scroller.clientWidth - parseFloat(css.paddingLeft) - parseFloat(css.paddingRight),
      height: scroller.clientHeight - parseFloat(css.paddingTop) - parseFloat(css.paddingBottom),
    };
  };
  const syncViewportLayout = () => {
    if (!viewer || disposed) return;
    const engineScale = Math.max(0.25, scale);
    // The public engine clamps its own scale to 25%. CSS layout zoom supplies
    // the remaining downscale for small native panels, including scroll extents.
    // Above that floor the compositor ratio is exactly 1.
    viewer.scaleBox.style.zoom = viewer.presenting ? '1' : String(scale / engineScale);
    const dimensions = viewer.slideDimensions;
    surface.style.paddingTop = !viewer.presenting && viewer.slideCount === 1 && dimensions
      ? `${Math.max(0, (readViewport().height - dimensions.height * scale) / 2)}px`
      : '0px';
  };
  const resizeObserver = new ResizeObserver(syncViewportLayout);
  resizeObserver.observe(scroller);
  const zoomState = () => ({
    scale, label: `${Math.round(scale * 100)}%`, minScale: 0.05, maxScale: 3,
    canZoomIn: scale < 3, canZoomOut: scale > 0.05, canReset: Math.abs(scale - 1) > 0.001,
  });
  const renderedSlideSize = () => {
    for (const slide of Array.from(viewer?.content.querySelectorAll('.slide') || [])) {
      const rect = slide.getBoundingClientRect();
      if (rect.width && rect.height) return { width: rect.width, height: rect.height };
    }
    return null;
  };
  const viewState = (): FileViewerViewState => ({
    renderer: 'pptx', page, pageCount: viewer?.slideCount || 0, scale, zoom: zoomState(),
    scroll: {
      top: scroller.scrollTop, left: scroller.scrollLeft,
      width: scroller.scrollWidth, height: scroller.scrollHeight,
      clientWidth: scroller.clientWidth, clientHeight: scroller.clientHeight,
    },
    extra: { slideDimensions: viewer?.slideDimensions, viewport: readViewport(), renderedSlide: renderedSlideSize(), presentationAvailable: true, presenting: viewer?.presenting || false, presentationPage: viewer?.presenting ? viewer.presentationSlideNumber : null },
  });
  const notify = (action: FileViewerViewStateChangeAction, source: FileViewerViewStateChangeSource) => {
    viewEvents.emit({ state: viewState(), action, source, timestamp: Date.now() });
  };
  const syncNavigation = () => {
    const count = viewer?.slideCount || 0;
    counter.textContent = count ? `${page} / ${count}` : '…';
    previous.disabled = page <= 1;
    next.disabled = page >= count;
    slideshow.disabled = !count;
    slideshow.textContent = viewer?.presenting ? t('presentation.slideshow.exit') : t('presentation.slideshow.start');
    slideshow.setAttribute('aria-pressed', viewer?.presenting ? 'true' : 'false');
  };
  const setScale = async (value: number, action: FileViewerViewStateChangeAction = 'zoom-change', source: FileViewerViewStateChangeSource = 'api') => {
    if (!Number.isFinite(value) || value <= 0) return zoomState();
    scale = Math.min(3, Math.max(0.05, value));
    layoutChanges++;
    await viewer?.setZoom(Math.max(0.25, scale) * 100);
    if (disposed) return zoomState();
    syncViewportLayout();
    const frame = document.defaultView!.requestAnimationFrame(() => { layoutChanges--; layoutFrames.delete(frame); });
    layoutFrames.add(frame);
    zoomEvents.emit();
    notify(action, source);
    return zoomState();
  };
  const fit = async (request: FileViewerFitRequest): Promise<FileViewerFitResult> => {
    const dimensions = viewer?.slideDimensions;
    const result = { mode: request.mode, resize: request.resize, source: request.source, provider: 'view-state' as const };
    if (!dimensions || !scroller.clientWidth || !scroller.clientHeight) {
      return { ...result, applied: false, reason: 'pending' };
    }
    const viewport = readViewport();
    const width = viewport.width - request.padding * 2;
    const height = viewport.height - request.padding * 2;
    const value = resolveFileViewerFitScale({
      mode: request.mode === 'auto' ? 'contain' : request.mode,
      viewportWidth: width, viewportHeight: height,
      contentWidth: dimensions.width, contentHeight: dimensions.height,
      minScale: request.minScale ?? 0.05, maxScale: request.maxScale ?? 3,
    });
    if (!value) return { ...result, applied: false, reason: 'unmeasurable' };
    await setScale(value, 'fit', request.source);
    return { ...result, applied: true, scale, state: viewState() };
  };
  const goTo = async (requested: number, source: FileViewerViewStateChangeSource = 'user') => {
    if (!viewer?.slideCount || !Number.isFinite(requested)) return;
    const requestedPage = Math.max(1, Math.min(viewer.slideCount, Math.round(requested)));
    const presenting = viewer.presenting;
    if (presenting && requestedPage === page) return;
    // Upstream exposes presentation entry/exit and the active page, but no
    // public presentation seek method. Reuse those APIs in one task, keeping
    // parsing and rendering alive while changing the active slide.
    if (presenting) viewer.exitPresentation();
    page = requestedPage;
    const slide = viewer.ensureSlideRendered(page) || viewer.content.children[page - 1];
    if (slide instanceof document.defaultView!.HTMLElement) {
      scroller.scrollTop += slide.getBoundingClientRect().top - scroller.getBoundingClientRect().top - parseFloat(document.defaultView!.getComputedStyle(scroller).paddingTop);
    }
    if (presenting) await viewer.enterPresentation(page);
    syncNavigation();
    notify('page-change', source);
  };
  const onScroll = () => {
    if (!viewer || viewer.presenting || restoringReadingPage) return;
    const top = scroller.getBoundingClientRect().top;
    const slots = Array.from(viewer.content.children).filter(slot => slot.matches('.flyfish-pptx-slide-slot,.slide'));
    const index = slots.findIndex(slot => slot.getBoundingClientRect().bottom > top + 24);
    if (index >= 0) page = index + 1;
    syncNavigation();
    notify('scroll', layoutChanges ? 'viewer' : 'user');
  };
  previous.onclick = () => goTo(page - 1);
  next.onclick = () => goTo(page + 1);
  slideshow.onclick = () => { void viewer?.togglePresentation(page); };
  const onKey = (event: KeyboardEvent) => {
    if (event.altKey || event.ctrlKey || event.metaKey || (event.target as HTMLElement)?.matches('input,textarea,[contenteditable]')) return;
    if (event.key === 'F5' || event.key.toLowerCase() === 'p') {
      event.preventDefault();
      void viewer?.togglePresentation(page);
    }
  };
  shell.addEventListener('keydown', onKey);
  scroller.addEventListener('scroll', onScroll, { passive: true });
  registerFileViewerZoomProvider(shell, {
    zoomIn: () => setScale(scale + 0.1), zoomOut: () => setScale(scale - 0.1),
    resetZoom: () => setScale(1), setZoom: value => setScale(value),
    fit, getState: zoomState, subscribe: zoomEvents.subscribe,
  });
  registerFileViewerViewStateProvider(shell, {
    getState: viewState, fit, subscribe: viewEvents.subscribe,
    async applyState(state) {
      const value = state.scale ?? state.zoom?.scale;
      if (value !== undefined) await setScale(value);
      if (state.page !== undefined) await goTo(state.page, 'api');
      if (state.scroll?.top !== undefined) scroller.scrollTop = state.scroll.top;
      if (state.scroll?.left !== undefined) scroller.scrollLeft = state.scroll.left;
      const presenting = state.extra?.presenting;
      if (viewer && typeof presenting === 'boolean' && presenting !== viewer.presenting) {
        if (presenting) await viewer.enterPresentation(page);
        else {
          viewer.exitPresentation();
          await readingRestored;
        }
      }
      return viewState();
    },
  });
  const cleanup = () => {
    if (disposed) return;
    disposed = true;
    rejectReady?.(context?.signal?.reason || new DOMException('Presentation disposed.', 'AbortError'));
    resizeObserver.disconnect();
    for (const frame of layoutFrames) document.defaultView!.cancelAnimationFrame(frame);
    for (const [frame, complete] of pendingFrames) {
      document.defaultView!.cancelAnimationFrame(frame);
      complete();
    }
    pendingFrames.clear();
    viewer?.destroy();
    shell.removeEventListener('keydown', onKey);
    scroller.removeEventListener('scroll', onScroll);
    unregisterFileViewerZoomProvider(shell);
    unregisterFileViewerViewStateProvider(shell);
    context?.signal?.removeEventListener('abort', cleanup);
    host.style.height = oldHostHeight;
    target.style.height = oldTargetHeight;
    target.replaceChildren();
  };
  context?.signal?.addEventListener('abort', cleanup, { once: true });
  syncNavigation();
  try {
    if (context?.signal?.aborted) throw context.signal.reason;
    const workerUrl = context?.options?.presentation?.workerUrl;
    if (!workerUrl) throw new Error('The packaged PPTX Worker URL is missing.');
    let complete!: () => void;
    let fail!: (error: unknown) => void;
    const ready = new Promise<void>((resolve, reject) => { complete = resolve; fail = reject; });
    rejectReady = fail;
    void ready.catch(() => {});
    const nextViewer = await PptxViewer.open(buffer, surface, {
      styleRoot: context?.surface?.shadowRoot || getFileViewerShadowRootForNode(target) || undefined,
      // The shared core provider supplies one absolute scale. Never multiply a
      // second internal fit factor into a toolbar/API zoom request.
      fitMode: 'none', zoomPercent: 100, workerUrl,
      workerType: context?.options?.presentation?.workerType,
      zipLimits: RECOMMENDED_ZIP_LIMITS, lazySlides: true, lazyMedia: true,
      listOptions: { windowed: true, initialSlides: 3, batchSize: 4, overscanViewport: 1.5 },
      presentationFullscreen: false,
      presentationLabels: { exit: t('presentation.slideshow.exit'), hint: t('presentation.slideshow.hint') },
      onPresentationChange: state => {
        if (disposed) return;
        const transition = ++presentationTransition;
        page = state.slideNumber;
        syncViewportLayout();
        viewer?.refreshLayout();
        restoringReadingPage = !state.active;
        if (!state.active) {
          const readingPage = page;
          readingRestored = (async () => {
            // Let upstream restore the reading transform and old scroll first.
            // Then align the slide the user actually reached during slideshow.
            for (let frame = 0; frame < 2; frame++) {
              if (disposed) return;
              await nextLayoutFrame();
            }
            if (disposed || transition !== presentationTransition || viewer?.presenting) return;
            await goTo(readingPage, 'viewer');
            restoringReadingPage = false;
          })();
        }
        syncNavigation();
        notify('page-change', 'user');
      },
      onSlideRendered: () => context?.onProgressiveRender?.(),
      onRenderComplete: complete, onError: fail,
    });
    viewer = nextViewer;
    if (disposed) { nextViewer.destroy(); throw context?.signal?.reason || new Error('Presentation was disposed.'); }
    await ready;
    syncViewportLayout();
    syncNavigation();
    zoomEvents.emit();
    return { $el: shell, unmount: cleanup };
  } catch (error) {
    cleanup();
    throw error;
  }
};
