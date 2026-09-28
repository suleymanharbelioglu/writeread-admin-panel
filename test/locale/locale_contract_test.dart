import 'package:flutter_test/flutter_test.dart';
import 'package:writeread_admin_panel/core/locale/chapter_storage_paths.dart';
import 'package:writeread_admin_panel/domain/chapter/entity/chapter_entity.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_locale_content.dart';

ComicEntity _comic({
  String title = 'Title',
  String description = 'Desc',
  String image = 'c1_cover.jpg',
  List<ChapterEntity> chapters = const [],
}) {
  return ComicEntity(
    comicId: 'c1',
    title: title,
    description: description,
    image: image,
    isSensitive: false,
    likeCount: 0,
    readCount: 0,
    chapterCount: chapters.length,
    createdDate: DateTime.utc(2024),
    categoryId: 'cat',
    categoryName: 'Cat',
    chapters: chapters,
  );
}

ChapterEntity _chapter({int pageCount = 3}) {
  return ChapterEntity(
    chapterId: 'chapter1',
    comicId: 'c1',
    pageCount: pageCount,
    chapterName: 'Ch 1',
    createdDate: DateTime.utc(2024),
  );
}

void main() {
  group('localeReadiness', () {
    test('missing when locale absent', () {
      expect(localeReadiness(const {}, 'tr'), LocaleReadiness.missing);
    });

    test('partial when only title/description', () {
      final locales = {
        'tr': const ComicLocaleContent(
          title: 'TR',
          description: 'Desc',
          categoryName: 'Cat',
        ),
      };
      expect(localeReadiness(locales, 'tr'), LocaleReadiness.partial);
    });

    test('ready when metadata and chapters with pages', () {
      final locales = {
        'tr': ComicLocaleContent(
          title: 'TR',
          description: 'Desc',
          categoryName: 'Cat',
          chapters: [
            ChapterLocaleContent(
              chapterId: 'chapter1',
              comicId: 'c1',
              chapterName: 'B1',
              pageCount: 3,
              createdDate: DateTime.utc(2024),
            ),
          ],
        ),
      };
      expect(localeReadiness(locales, 'tr'), LocaleReadiness.ready);
    });

    test('partial when chapters exist but metadata incomplete', () {
      final locales = {
        'tr': ComicLocaleContent(
          title: 'TR',
          description: '',
          categoryName: '',
          chapters: [
            ChapterLocaleContent(
              chapterId: 'chapter1',
              comicId: 'c1',
              chapterName: 'B1',
              pageCount: 2,
              createdDate: DateTime.utc(2024),
            ),
          ],
        ),
      };
      expect(localeReadiness(locales, 'tr'), LocaleReadiness.partial);
    });
  });

  group('ComicEntity.englishReadiness', () {
    test('partial when metadata but no chapters', () {
      expect(_comic().englishReadiness, LocaleReadiness.partial);
      expect(_comic().readinessFor('en'), LocaleReadiness.partial);
    });

    test('ready when metadata and chapters with pages', () {
      expect(
        _comic(chapters: [_chapter()]).englishReadiness,
        LocaleReadiness.ready,
      );
    });

    test('partial when chapters but empty title', () {
      expect(
        _comic(title: '', chapters: [_chapter()]).englishReadiness,
        LocaleReadiness.partial,
      );
    });

    test('missing when empty shell', () {
      expect(
        _comic(title: '', description: '', image: '').englishReadiness,
        LocaleReadiness.missing,
      );
    });
  });

  group('ChapterStoragePaths', () {
    test('EN and locale page/cover paths', () {
      expect(
        ChapterStoragePaths.pageObjectPath(
          comicId: 'c1',
          chapterId: 'chapter1',
          pageNumber: 1,
        ),
        'Comics/c1/chapter1/1.jpeg',
      );
      expect(
        ChapterStoragePaths.pageObjectPath(
          comicId: 'c1',
          chapterId: 'chapter1',
          pageNumber: 1,
          locale: 'tr',
        ),
        'Comics/c1/tr/chapter1/1.jpeg',
      );
      expect(
        ChapterStoragePaths.coverObjectPath(comicId: 'c1', locale: 'tr'),
        'Comics/c1/tr/cover.jpg',
      );
    });
  });
}
