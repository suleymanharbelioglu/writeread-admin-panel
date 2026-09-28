/// Shared customer-facing helper copy used on multiple screens.
class AppCopy {
  AppCopy._();

  static const freeComicOn =
      'All chapters unlocked — no purchase required. '
      'You still need a Store Product ID so you can switch to paid later.';

  static const freeComicOff =
      'Users must buy this comic to unlock chapters '
      '(except chapters marked Free preview).';

  static const productIdHelper =
      'Must match Play Console / App Store exactly '
      '(lowercase letters, numbers, underscores, periods). '
      'Always required — free/paid can change later. '
      'Create the store product first; the ID cannot be changed after creation.';

  static const productIdHint = 'comic_example_001';

  static const sensitiveSubtitle =
      'Marks this comic as sensitive in the reader app.';

  static const categoryHelper =
      'Shown in the app. Reuse the same name for comics in the same category '
      '(e.g. Fantasy). Cannot be changed after creating the comic.';

  static const titleHelper = 'Shown to readers as the comic title.';

  static const descriptionHelper =
      'Short synopsis shown on the comic detail screen.';

  static const coverHelper =
      'Recommended: portrait cover, JPG or PNG. You can change it later.';

  static const addComicTip =
      'Create the store product in Play Console first, then paste the same '
      'Product ID below. After saving, add chapters with page images.';

  static const chaptersTip =
      'Add chapters with page images in reading order. '
      'For paid comics, mark early chapters as Free preview if you want a sample.';

  static const addChapterTip =
      'Upload page images in the order readers should see them. '
      'At least one image is required.';

  static const freePreviewSubtitle =
      'Readers can open this chapter without purchasing. '
      'Only available for paid comics.';

  static const freePreviewTileSubtitle =
      'Open without purchase (paid comics only).';

  static const homeTip =
      'Tap a comic to manage English content and translations. '
      'Color pills show Ready / Partial languages. '
      'Chapters are per language — empty languages show “Coming soon” in the app.';

  static const localeEditorTip =
      'English is the root comic. Other languages need their own metadata and '
      'chapters (no English chapter fallback). Save metadata before switching '
      'language. Ready = title + description + at least one chapter with pages.';
}
