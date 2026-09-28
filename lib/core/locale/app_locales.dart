/// Supported content locales shared with the Chapt mobile app.
///
/// English (`en`) is canonical (root Firestore fields + legacy Storage paths).
class AppLocales {
  AppLocales._();

  static const String english = 'en';

  static const List<String> codes = [
    'en',
    'es',
    'pt',
    'fr',
    'ja',
    'ko',
    'de',
    'id',
    'th',
    'vi',
    'tr',
  ];

  /// Non-English codes (stored under `locales.{code}`).
  static List<String> get contentLocaleCodes =>
      codes.where((c) => c != english).toList(growable: false);

  static const Map<String, String> nativeNames = {
    'en': 'English',
    'es': 'Español',
    'pt': 'Português',
    'fr': 'Français',
    'ja': '日本語',
    'ko': '한국어',
    'de': 'Deutsch',
    'id': 'Bahasa Indonesia',
    'th': 'ไทย',
    'vi': 'Tiếng Việt',
    'tr': 'Türkçe',
  };

  static bool isSupported(String code) => codes.contains(code);

  static bool isEnglish(String code) => code == english;

  static String nativeName(String code) =>
      nativeNames[code] ?? code.toUpperCase();
}
