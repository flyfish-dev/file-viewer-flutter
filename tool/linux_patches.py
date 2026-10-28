"""Auditable, exact-context changes to the pinned Linux adapter sources."""
import re

def once(text, old, new):
    if text.count(old) != 1:
        raise RuntimeError(f'Upstream patch context changed: {old[:100]!r}')
    return text.replace(old, new, 1)

def harden(name, text):
    if name.endswith('.dart'):
        # Dart 3.13 no longer accepts final modifiers on formal parameters.
        text = re.sub(r'(?<=[(,])(\s*)final (String|Set<)', r'\1\2', text)
        annotations = {
            'lib/src/webview.dart': {
                '  get onJavascriptChannelMessage': '  void Function(String, String, String, String) get onJavascriptChannelMessage',
                '  get onToolTip': '  Function(String)? get onToolTip',
                '  get onCursorChanged': '  Function(int)? get onCursorChanged',
                '  get onFocusedNodeChangeMessage': '  Function(bool)? get onFocusedNodeChangeMessage',
                '  get onImeCompositionRangeChangedMessage': '  Function(int, int, int)? get onImeCompositionRangeChangedMessage',
                '  setWebviewListener(': '  void setWebviewListener(',
            },
            'lib/src/webview_manager.dart': {
                '  get ready': '  Future<void> get ready',
                '.onJavascriptChannelMessage?.call': '.onJavascriptChannelMessage.call',
                '.onFocusedNodeChangeMessage(editable)': '.onFocusedNodeChangeMessage?.call(editable)',
            },
            'lib/src/webview_textinput.dart': {
                '  attachTextInputClient(': '  void attachTextInputClient(',
                '  detachTextInputClient(': '  void detachTextInputClient(',
                '  updateIMEComposionPosition(': '  void updateIMEComposionPosition(',
            },
        }
        for old, new in annotations.get(name, {}).items():
            text = once(text, old, new)
    if name == 'linux/CMakeLists.txt':
        text = once(text, 'find_package(CEF REQUIRED)', '''find_package(CEF REQUIRED)
# The locked minimal distribution ships only Release engine binaries, even
# when the Flutter application and adapter use Debug or Profile compilation.
set(CEF_BINARY_DIR "${CEF_ROOT}/Release")
set(CEF_LIB_DEBUG "${CEF_LIB_RELEASE}")
foreach(CEF_NOTICE LICENSE.txt CREDITS.html)
  if(NOT EXISTS "${CEF_ROOT}/${CEF_NOTICE}")
    message(FATAL_ERROR "The locked CEF distribution is missing ${CEF_NOTICE}")
  endif()
  install(FILES "${CEF_ROOT}/${CEF_NOTICE}" DESTINATION "licenses/cef" COMPONENT Runtime)
endforeach()''')
        text = once(text, 'set(cef_library_list "")', '''set(cef_library_list "")
# CEF resolves its sandbox helper beside libcef.so. Install it as a program
# instead of passing it through Flutter's generic install(FILES) library list.
list(REMOVE_ITEM CEF_BINARY_FILES chrome-sandbox)
install(PROGRAMS "${CEF_BINARY_DIR}/chrome-sandbox" DESTINATION "lib" COMPONENT Runtime)''')
    if name == 'common/webview_app.cc':
        lines = text.splitlines(keepends=True)
        text = ''.join(line for line in lines if not any(flag in line for flag in (
            'AppendSwitch("disable-web-security")',
            'AppendSwitch("allow-running-insecure-content")',
            'AppendSwitch("no-sandbox")')))
    elif name == 'common/webview_plugin.cc':
        text = once(text, 'cefs.no_sandbox = true;', 'cefs.no_sandbox = false;')
        text = once(text, '            m_handler->onLoadEnd = [=, this]', '''            m_handler->onRenderProcessTerminated = [=, this](int browserId, int status) {
                if (!m_invokeFunc) return;
                WValue* map = webview_value_new_map();
                WValue* id = webview_value_new_int(browserId);
                WValue* reason = webview_value_new_int(status);
                webview_value_set_string(map, "browserId", id);
                webview_value_set_string(map, "status", reason);
                m_invokeFunc("onRenderProcessTerminated", map);
                webview_value_unref(id);
                webview_value_unref(reason);
                webview_value_unref(map);
            };

            m_handler->onLoadEnd = [=, this]''')
    elif name == 'common/webview_handler.h':
        text = once(text, '#include "include/cef_client.h"', '#include "include/cef_client.h"\n#include "include/cef_request_handler.h"\n#include <unordered_set>')
        text = once(text, 'public CefRenderHandler{', 'public CefRenderHandler, public CefRequestHandler{')
        text = once(text, '    // CefDisplayHandler methods:', '''    CefRefPtr<CefRequestHandler> GetRequestHandler() override { return this; }
    std::function<void(int, int)> onRenderProcessTerminated;
    void OnRenderProcessTerminated(CefRefPtr<CefBrowser> browser, TerminationStatus status,
                                   int error_code, const CefString& error_string) override {
        if (onRenderProcessTerminated) onRenderProcessTerminated(browser->GetIdentifier(), static_cast<int>(status));
    }
    bool OnBeforeBrowse(CefRefPtr<CefBrowser> browser, CefRefPtr<CefFrame> frame,
                        CefRefPtr<CefRequest> request, bool user_gesture, bool is_redirect) override {
        const std::string target = request->GetURL().ToString();
        if (frame->IsMain()) {
            return allowed_shell_urls_.find(target.substr(0, target.find('#'))) == allowed_shell_urls_.end();
        }
        if (target == "about:blank" || target == "about:srcdoc") return false;
        for (const auto& shell : allowed_shell_urls_) {
            const auto authority_end = shell.find('/', shell.find("://") + 3);
            const auto origin = shell.substr(0, authority_end);
            if (target.rfind(origin + "/", 0) == 0 || target.rfind("blob:" + origin + "/", 0) == 0) return false;
        }
        return true;
    }

    // CefDisplayHandler methods:''')
        text = once(text, '    std::unordered_map<int, browser_info> browser_map_;',
            '    std::unordered_map<int, browser_info> browser_map_;\n    std::unordered_set<std::string> allowed_shell_urls_;')
    elif name == 'common/webview_handler.cc':
        text = once(text, '        int64_t frameIdInt = atoll(frameId.c_str());\n\n', '')
        text = once(text, 'std::stoll(frame->GetIdentifier().ToString()) == frameIdInt',
            'frame && frame->GetIdentifier().ToString() == frameId')
        text = once(text, '\tstd::string message_name = message->GetName();',
            '    if (!frame || !frame->IsMain()) return false;\n\tstd::string message_name = message->GetName();')
        text = once(text, '    loadUrl(browser->GetIdentifier(), target_url);\n', '')
        text = once(text, '    CefBrowserSettings browser_settings ;',
            '    allowed_shell_urls_.insert(url.substr(0, url.find(\'#\')));\n    CefBrowserSettings browser_settings ;')
    elif name == 'lib/src/webview.dart':
        start = text.index('class WebViewState')
        controller, state = text[:start], text[start:]
        controller = once(controller, '''    await _creatingCompleter.future;
    if (!_isDisposed) {
      _isDisposed = true;
      WebviewManager().removeWebView(_browserId);
      await _pluginChannel.invokeMethod('close', _browserId);
    }
    super.dispose();''', '''    if (_isDisposed) return;
    _isDisposed = true;
    try {
      await _creatingCompleter.future;
      WebviewManager().removeWebView(_browserId);
      await _pluginChannel.invokeMethod('close', _browserId);
    } finally {
      super.dispose();
    }''')
        state = once(state, '      await _controller.ready;\n      unawaited(',
            '      await _controller.ready;\n      if (!mounted) return;\n      unawaited(')
        state = once(state, '    _controller._onFocusedNodeChangeMessage = (editable) {',
            '    _controller._onFocusedNodeChangeMessage = (editable) {\n      if (!mounted) return;')
        state = once(state, '    _controller._onImeCompositionRangeChangedMessage = (x, y, height) {',
            '    _controller._onImeCompositionRangeChangedMessage = (x, y, height) {\n      if (!mounted || _key.currentContext == null) return;')
        state = once(state, '    _controller._onToolTip = (String text) {',
            '    _controller._onToolTip = (String text) {\n      if (!mounted || _key.currentContext == null) return;')
        state = once(state, '    _controller._onCursorChanged = (int type) {',
            '    _controller._onCursorChanged = (int type) {\n      if (!mounted) return;')
        state = once(state, '    WebviewManager().hasNativeKeySupport.then((value) {',
            '    WebviewManager().hasNativeKeySupport.then((value) {\n      if (!mounted) return;')
        state = state.replace('.addPostFrameCallback((_) => _reportSurfaceSize(context));',
            '.addPostFrameCallback((_) { if (mounted) _reportSurfaceSize(context); });')
        state = state.replace('  void _reportSurfaceSize(BuildContext context) {',
            '  void _reportSurfaceSize(BuildContext context) {\n    if (!mounted || _key.currentContext == null) return;')
        state = once(state, '  void _reportSurfaceSize(BuildContext context) async {',
            '  void _reportSurfaceSize(BuildContext context) async {\n    if (!mounted || _key.currentContext == null) return;')
        state = once(state, '              Future.delayed(const Duration(milliseconds: 50), () {',
            '              Future.delayed(const Duration(milliseconds: 50), () {\n                if (!mounted) return;')
        state = once(state, '  KeyEventResult _onKeyEvent(', '''  @override
  void dispose() {
    _controller._onFocusedNodeChangeMessage = null;
    _controller._onImeCompositionRangeChangedMessage = null;
    _controller._onToolTip = null;
    _controller._onCursorChanged = null;
    detachTextInputClient();
    _tooltip?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(''')
        text = controller + state
    elif name == 'lib/src/webview_events_listener.dart':
        text = once(text, '  LoadStopCb? onLoadEnd;', '  LoadStopCb? onLoadEnd;\n  void Function(int status)? onProcessTerminated;')
        text = once(text, '    this.onLoadEnd,', '    this.onLoadEnd,\n    this.onProcessTerminated,')
    elif name == 'lib/src/webview_manager.dart':
        text = once(text, '      case "urlChanged":', '''      case "onRenderProcessTerminated":
        final browserId = call.arguments["browserId"] as int;
        _webViews[browserId]?.listener?.onProcessTerminated?.call(call.arguments["status"] as int);
        return;
      case "urlChanged":''')
    elif name == 'lib/src/webview_tooltip.dart':
        text = once(text, '  void showToolTip(String text) {', '''  bool _disposed = false;

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _timer?.cancel();
    if (_overlayEntry?.mounted == true) _overlayEntry!.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  void showToolTip(String text) {
    if (_disposed) return;''')
        text = once(text, '    _timer = Timer(const Duration(milliseconds: 500), () {',
            '    _timer = Timer(const Duration(milliseconds: 500), () {\n      if (_disposed) return;')
        text = once(text, '        _overlayEntry?.remove();',
            '        if (_overlayEntry?.mounted == true) _overlayEntry!.remove();\n        _overlayEntry?.dispose();\n        _overlayEntry = null;')
    return text

