/// Main-frame navigation stays on the packaged shell. Preview subframes may
/// use inert about: documents or same-origin blob/HTTP resources.
bool isAllowedViewerNavigation(
  Uri? target,
  Uri shell, {
  required bool isMainFrame,
}) {
  if (target == null) return false;
  if (isMainFrame) {
    return target.replace(fragment: '') == shell.replace(fragment: '');
  }
  if (target.scheme == 'about') {
    return target.path == 'blank' || target.path == 'srcdoc';
  }
  if (target.scheme == 'blob') {
    final nested = Uri.tryParse(target.path);
    return nested != null &&
        {'http', 'https'}.contains(nested.scheme) &&
        nested.origin == shell.origin;
  }
  return {'http', 'https'}.contains(target.scheme) &&
      target.origin == shell.origin;
}
