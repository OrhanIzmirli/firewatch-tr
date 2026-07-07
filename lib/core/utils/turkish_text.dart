/// ASCII-folds Turkish text for loose matching (case/diacritic-insensitive).
/// Needed because region names come from several backend sources that don't
/// agree on diacritics (e.g. risk API: "Ic Anadolu", news scraper:
/// "İç Anadolu") — comparing raw strings would silently fail to match.
String foldTurkish(String s) {
  const map = {
    'ç': 'c', 'Ç': 'c',
    'ğ': 'g', 'Ğ': 'g',
    'ı': 'i', 'İ': 'i', 'I': 'i',
    'ö': 'o', 'Ö': 'o',
    'ş': 's', 'Ş': 's',
    'ü': 'u', 'Ü': 'u',
  };
  final buffer = StringBuffer();
  for (final rune in s.runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(map[ch] ?? ch.toLowerCase());
  }
  return buffer.toString();
}
