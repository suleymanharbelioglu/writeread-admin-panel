/// Content rail type. Stored on Firestore as [contentType].
/// Missing / unknown values default to [comic] so older documents never crash.
class ComicContentType {
  ComicContentType._();

  static const comic = 'comic';
  static const chatStory = 'chatStory';
  static const novel = 'novel';

  static const values = [comic, chatStory, novel];

  static String parse(dynamic raw) {
    final value = (raw is String ? raw : '$raw').trim();
    if (value == chatStory || value == novel || value == comic) return value;
    return comic;
  }

  static String label(String type) {
    switch (parse(type)) {
      case chatStory:
        return 'Chat Story';
      case novel:
        return 'Novel';
      default:
        return 'Comic';
    }
  }
}
