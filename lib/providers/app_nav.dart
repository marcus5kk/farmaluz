class AppNav {
  static void Function(int)? _switchTab;

  static void register(void Function(int) fn) => _switchTab = fn;

  static void goTo(int index) => _switchTab?.call(index);

  static void goHome() => _switchTab?.call(0);
}
