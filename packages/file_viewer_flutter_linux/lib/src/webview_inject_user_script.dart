// Public enum values use SCREAMING_CAPS to preserve the existing API surface.
// ignore_for_file: constant_identifier_names

/// Native browser load stage at which a user script is executed.
enum ScriptInjectTime {
  /// Executes when the adapter receives the document load-start event.
  LOAD_START,
  /// Executes when the adapter receives the document load-end event.
  LOAD_END,
}

/// JavaScript source paired with the native load event that triggers it.
class UserScript {
  /// Trusted JavaScript source to execute in the loaded page.
  final String script;
  /// Load event at which [script] is executed.
  final ScriptInjectTime injectTime;

  /// Creates a script for the selected [injectTime].
  UserScript(this.script, this.injectTime);
}

/// Collection of scripts grouped by the native load event that executes them.
class InjectUserScripts {
  /// Scripts in insertion order; each script declares its own injection stage.
  List<UserScript> userScripts = [];

  /// Appends [script] to the collection.
  void add(UserScript script) {
    userScripts.add(script);
  }

  /// Returns scripts configured for the load-start stage in insertion order.
  List<UserScript> retrieveLoadStartInjectScripts() {
    return userScripts.where((e) => e.injectTime == ScriptInjectTime.LOAD_START).toList();
  }

  /// Returns scripts configured for the load-end stage in insertion order.
  List<UserScript> retrieveLoadEndInjectScripts() {
    return userScripts.where((e) => e.injectTime == ScriptInjectTime.LOAD_END).toList();
  }
}
