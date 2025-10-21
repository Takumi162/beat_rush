class IconPaths {
  static const Map<String, String> icons = {
    'finn': 'assets/icons/finn.png',
    'jake': 'assets/icons/jake.png',
  };

  static String resolve(String key) {
    return icons[key] ?? 'assets/icons/jake.png'; // デフォルト
  }
}
