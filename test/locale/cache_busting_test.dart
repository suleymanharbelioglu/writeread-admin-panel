import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writeread_admin_panel/core/locale/chapter_storage_paths.dart';
import 'package:writeread_admin_panel/data/chapter/model/chapter_model.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_locale_content.dart';

void main() {
  group('versioned covers', () {
    test('EN and locale cover names include the version', () {
      expect(
        ChapterStoragePaths.versionedCoverImageField(comicId: 'c1', version: 5),
        'c1_cover_5.jpg',
      );
      expect(
        ChapterStoragePaths.versionedCoverImageField(
          comicId: 'c1',
          locale: 'tr',
          version: 5,
        ),
        'c1/tr/cover_5.jpg',
      );
    });

    test('each upload version is a different object', () {
      expect(
        ChapterStoragePaths.versionedCoverImageField(comicId: 'c1', version: 1),
        isNot(
          ChapterStoragePaths.versionedCoverImageField(
            comicId: 'c1',
            version: 2,
          ),
        ),
      );
    });

    test('object path from Firestore field', () {
      expect(
        ChapterStoragePaths.coverObjectPathFromField('c1_cover_5.jpg'),
        'Comics/c1_cover_5.jpg',
      );
      expect(
        ChapterStoragePaths.coverObjectPathFromField(' c1/tr/cover_5.jpg '),
        'Comics/c1/tr/cover_5.jpg',
      );
    });

    test('root cover sweep matches only this comic', () {
      bool m(String name) => ChapterStoragePaths.isRootCoverNameOf(name, 'glo');
      expect(m('glo_cover.jpg'), isTrue);
      expect(m('glo_cover_1727512345000.jpg'), isTrue);
      // Another comic whose id starts with this one must not be deleted.
      expect(m('glo_cover_x_cover.jpg'), isFalse);
      expect(m('glo_2_cover.jpg'), isFalse);
      expect(m('gloria_cover.jpg'), isFalse);
      expect(m('glo_cover_12.jpeg'), isFalse);
    });
  });

  group('pagesVersion', () {
    test('nextPagesVersion is always greater than previous', () {
      final future = DateTime.now().millisecondsSinceEpoch + 1000000;
      expect(ChapterStoragePaths.nextPagesVersion(future), future + 1);
      expect(ChapterStoragePaths.nextPagesVersion(), greaterThan(0));
    });

    test('page URL appends v only when versioned', () {
      final legacy = ChapterStoragePaths.pageDownloadUrl(
        comicId: 'c1',
        chapterId: 'chapter1',
        pageNumber: 1,
      );
      expect(legacy, endsWith('?alt=media'));
      final versioned = ChapterStoragePaths.pageDownloadUrl(
        comicId: 'c1',
        chapterId: 'chapter1',
        pageNumber: 1,
        pagesVersion: 9,
      );
      expect(versioned, endsWith('?alt=media&v=9'));
    });

    test('ChapterLocaleContent keeps pagesVersion through map and copyWith', () {
      final chapter = ChapterLocaleContent.fromMap({
        'chapterId': 'chapter1',
        'comicId': 'c1',
        'chapterName': 'Bölüm 1',
        'pageCount': 3,
        'createdDate': Timestamp.fromDate(DateTime.utc(2026)),
        'pagesVersion': 77,
      });
      expect(chapter.pagesVersion, 77);
      final renamed = chapter.copyWith(chapterName: 'Yeni');
      expect(renamed.pagesVersion, 77);
      expect(renamed.toMap()['pagesVersion'], 77);
    });

    test('ComicLocaleContent.toMap keeps chapter pagesVersion', () {
      final content = ComicLocaleContent(
        title: 'T',
        description: 'D',
        categoryName: '',
        chapters: [
          ChapterLocaleContent(
            chapterId: 'chapter1',
            comicId: 'c1',
            chapterName: 'Bölüm 1',
            pageCount: 3,
            createdDate: DateTime.utc(2026),
            pagesVersion: 5,
          ),
        ],
      );
      final chapters = content.toMap()['chapters'] as List<dynamic>;
      expect((chapters.single as Map)['pagesVersion'], 5);
    });

    test('legacy chapter (no field) stays without pagesVersion', () {
      final model = ChapterModel.fromMap({
        'chapterId': 'chapter1',
        'comicId': 'c1',
        'pageCount': 1,
        'chapterName': 'Chapter 1',
        'createdDate': Timestamp.fromDate(DateTime.utc(2026)),
      });
      expect(model.pagesVersion, 0);
      expect(model.toMap().containsKey('pagesVersion'), isFalse);
      expect(model.toEntity().copyWith(pageCount: 2).pagesVersion, 0);
    });
  });
}
