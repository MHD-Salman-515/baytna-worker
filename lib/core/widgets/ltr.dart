/// Phone numbers, codes and prefixes are always left-to-right, even inside
/// Arabic text. Wrapping them in Unicode directional isolates (LRI … PDI)
/// keeps "+963 911…" from being reordered by the bidi algorithm when
/// interpolated into an RTL sentence.
String ltrIsolate(String text) => '\u2066$text\u2069';
