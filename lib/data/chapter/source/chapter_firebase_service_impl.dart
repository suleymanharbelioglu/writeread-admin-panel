import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:writeread_admin_panel/core/constants/firestore_collections.dart';
import 'package:writeread_admin_panel/core/error/firebase_error_mapper.dart';
import 'package:writeread_admin_panel/core/firebase/firestore_write_helper.dart';
import 'package:writeread_admin_panel/core/firebase/soft_deadline.dart';
import 'package:writeread_admin_panel/core/locale/app_locales.dart';
import 'package:writeread_admin_panel/core/locale/chapter_storage_paths.dart';
import 'package:writeread_admin_panel/data/chapter/model/chapter_model.dart';
import 'package:writeread_admin_panel/data/chapter/source/chapter_firebase_service.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_locale_content.dart';

class ChapterFirebaseServiceImpl extends ChapterFirebaseService {
  static const String _comicsCollection = FirestoreCollections.comics;
  static const Duration _storageTimeout = Duration(seconds: 60);

  static int nextPagesVersion([int previous = 0]) =>
      ChapterStoragePaths.nextPagesVersion(previous);

  DocumentReference<Map<String, dynamic>> _docRef(String comicId) =>
      FirebaseFirestore.instance.collection(_comicsCollection).doc(comicId);

  Reference _folderRef({
    required String comicId,
    required String chapterId,
    required String locale,
  }) {
    return FirebaseStorage.instance.ref().child(
      ChapterStoragePaths.chapterFolderObjectPath(
        comicId: comicId,
        chapterId: chapterId,
        locale: locale,
      ),
    );
  }

  Future<void> _deleteStorageFolderRecursively(Reference ref) async {
    final listResult = await ref.listAll();
    for (final itemRef in listResult.items) {
      await itemRef.delete();
    }
    for (final prefixRef in listResult.prefixes) {
      await _deleteStorageFolderRecursively(prefixRef);
    }
  }

  Future<void> _putBytes(Reference ref, Uint8List bytes, String contentType) {
    return softDeadlineVoid(
      ref.putData(bytes, SettableMetadata(contentType: contentType)),
      deadline: _storageTimeout,
      onDeadline: () =>
          throw StateError('Upload timed out. Check your connection.'),
    );
  }

  Future<Either<String, void>> _safeDeleteFolder(Reference folderRef) async {
    try {
      await _deleteStorageFolderRecursively(folderRef);
      return const Right(null);
    } on FirebaseException catch (e, stackTrace) {
      if (e.code == 'object-not-found') return const Right(null);
      return Left(
        FirebaseErrorMapper.map(
          e,
          action: 'Delete chapter folder',
          stackTrace: stackTrace,
        ),
      );
    } catch (e, stackTrace) {
      return Left(
        FirebaseErrorMapper.map(
          e,
          action: 'Delete chapter folder',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  /// Deletes Storage for one chapter in one locale only.
  /// Prefer this over wiping every language for the same chapterId.
  Future<Either<String, void>> deleteChapterStorageFolder(
    String comicId,
    String chapterId, {
    String locale = AppLocales.english,
  }) async {
    return _safeDeleteFolder(
      _folderRef(comicId: comicId, chapterId: chapterId, locale: locale),
    );
  }

  @override
  Future<Either<String, void>> deleteLastChapter(
    String comicId, {
    String locale = AppLocales.english,
  }) async {
    try {
      if (!AppLocales.isEnglish(locale)) {
        if (!AppLocales.isSupported(locale)) {
          return const Left('Invalid content locale');
        }
        return _deleteLastLocaleChapter(comicId, locale);
      }

      final docRef = _docRef(comicId);
      final doc = await docRef.get();
      if (!doc.exists || doc.data() == null) {
        return const Left('Comic not found');
      }

      final data = doc.data()!;
      final chaptersList = data['chapters'] as List<dynamic>?;
      if (chaptersList == null || chaptersList.isEmpty) {
        return const Left('No chapters to delete');
      }

      final lastChapter = chaptersList.last as Map<String, dynamic>;
      final chapterId = lastChapter['chapterId'] as String?;
      if (chapterId == null || chapterId.isEmpty) {
        return const Left('Invalid chapter data');
      }

      // Independent chapters: only delete English storage for this chapter.
      final deleteFolderResult = await _safeDeleteFolder(
        _folderRef(
          comicId: comicId,
          chapterId: chapterId,
          locale: AppLocales.english,
        ),
      );
      if (deleteFolderResult.isLeft()) {
        return deleteFolderResult;
      }

      final newChapters = chaptersList.sublist(0, chaptersList.length - 1);
      final write = await FirestoreWriteHelper.updateDocument(docRef, {
        'chapters': newChapters,
        'chapterCount': newChapters.length,
      });
      if (!write.isSuccess) {
        return Left(
          FirebaseErrorMapper.map(write.error!, action: 'Delete chapter'),
        );
      }

      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        FirebaseErrorMapper.map(
          e,
          action: 'Delete chapter',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Either<String, void>> _deleteLastLocaleChapter(
    String comicId,
    String locale,
  ) async {
    final docRef = _docRef(comicId);
    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) {
      return const Left('Comic not found');
    }

    final data = doc.data()!;
    final rawLocales = data['locales'];
    final existing = (rawLocales is Map && rawLocales[locale] is Map)
        ? ComicLocaleContent.fromMap(
            Map<String, dynamic>.from(rawLocales[locale] as Map),
          )
        : const ComicLocaleContent(
            title: '',
            description: '',
            categoryName: '',
          );

    if (existing.chapters.isEmpty) {
      return const Left('No chapters to delete');
    }

    final last = existing.chapters.last;
    final deleteFolderResult = await _safeDeleteFolder(
      _folderRef(comicId: comicId, chapterId: last.chapterId, locale: locale),
    );
    if (deleteFolderResult.isLeft()) {
      return deleteFolderResult;
    }

    final updated = existing.copyWith(
      chapters: existing.chapters.sublist(0, existing.chapters.length - 1),
    );
    final write = await FirestoreWriteHelper.updateDocument(docRef, {
      'locales.$locale': updated.toMap(),
    });
    if (!write.isSuccess) {
      return Left(
        FirebaseErrorMapper.map(write.error!, action: 'Delete locale chapter'),
      );
    }
    return const Right(null);
  }

  @override
  Future<Either<String, ChapterModel>> addChapter(
    String comicId,
    String chapterName,
    List<List<int>> imageBytesList, {
    bool isFreePreview = false,
    List<int>? musicBytes,
    String locale = AppLocales.english,
  }) async {
    if (imageBytesList.isEmpty) {
      return const Left('Add at least one image');
    }
    try {
      if (!AppLocales.isEnglish(locale)) {
        if (!AppLocales.isSupported(locale)) {
          return const Left('Invalid content locale');
        }
        return _addLocaleChapter(
          comicId,
          chapterName,
          imageBytesList,
          locale: locale,
          isFreePreview: isFreePreview,
          musicBytes: musicBytes,
        );
      }

      final docRef = _docRef(comicId);
      final doc = await docRef.get();
      if (!doc.exists || doc.data() == null) {
        return const Left('Comic not found');
      }
      final data = doc.data()!;
      final existingChapters = (data['chapters'] as List<dynamic>?) ?? [];
      final newChapterId = 'chapter${existingChapters.length + 1}';
      final createdDate = Timestamp.now();
      final newChapter = <String, dynamic>{
        'chapterId': newChapterId,
        'comicId': comicId,
        'chapterName': chapterName,
        'createdDate': createdDate,
        'pageCount': imageBytesList.length,
        'isFreePreview': isFreePreview,
        'pagesVersion': nextPagesVersion(),
      };

      final folderRef = _folderRef(
        comicId: comicId,
        chapterId: newChapterId,
        locale: AppLocales.english,
      );

      // Upload Storage first so Firestore is never left with orphan metadata.
      if (musicBytes != null && musicBytes.isNotEmpty) {
        final musicRef = folderRef.child(ChapterStoragePaths.musicFileName);
        await _putBytes(musicRef, Uint8List.fromList(musicBytes), 'audio/mpeg');
        final musicUrl = await softDeadline(
          musicRef.getDownloadURL(),
          deadline: _storageTimeout,
          onDeadline: () => throw StateError(
            'Getting music URL timed out. Check your connection.',
          ),
        );
        newChapter['musicUrl'] = musicUrl;
      }

      for (var i = 0; i < imageBytesList.length; i++) {
        final pageRef = folderRef.child('${i + 1}.jpeg');
        final bytes = imageBytesList[i].isNotEmpty
            ? Uint8List.fromList(imageBytesList[i])
            : Uint8List(0);
        await _putBytes(pageRef, bytes, 'image/jpeg');
      }

      final write = await FirestoreWriteHelper.updateDocument(docRef, {
        'chapters': FieldValue.arrayUnion([newChapter]),
        'chapterCount': existingChapters.length + 1,
      });
      if (!write.isSuccess) {
        await _safeDeleteFolder(folderRef);
        return Left(
          FirebaseErrorMapper.map(write.error!, action: 'Add chapter'),
        );
      }
      return Right(ChapterModel.fromMap(newChapter));
    } catch (e, stackTrace) {
      return Left(
        FirebaseErrorMapper.map(
          e,
          action: 'Add chapter',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Either<String, ChapterModel>> _addLocaleChapter(
    String comicId,
    String chapterName,
    List<List<int>> imageBytesList, {
    required String locale,
    bool isFreePreview = false,
    List<int>? musicBytes,
  }) async {
    final docRef = _docRef(comicId);
    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) {
      return const Left('Comic not found');
    }
    final data = doc.data()!;
    final rawLocales = data['locales'];
    final existing = (rawLocales is Map && rawLocales[locale] is Map)
        ? ComicLocaleContent.fromMap(
            Map<String, dynamic>.from(rawLocales[locale] as Map),
          )
        : const ComicLocaleContent(
            title: '',
            description: '',
            categoryName: '',
          );

    final newChapterId = 'chapter${existing.chapters.length + 1}';
    final createdDate = DateTime.now().toUtc();
    var musicUrl = '';

    final folderRef = _folderRef(
      comicId: comicId,
      chapterId: newChapterId,
      locale: locale,
    );

    if (musicBytes != null && musicBytes.isNotEmpty) {
      final musicRef = folderRef.child(ChapterStoragePaths.musicFileName);
      await _putBytes(musicRef, Uint8List.fromList(musicBytes), 'audio/mpeg');
      musicUrl = await softDeadline(
        musicRef.getDownloadURL(),
        deadline: _storageTimeout,
        onDeadline: () => throw StateError(
          'Getting music URL timed out. Check your connection.',
        ),
      );
    }

    for (var i = 0; i < imageBytesList.length; i++) {
      final pageRef = folderRef.child('${i + 1}.jpeg');
      final bytes = imageBytesList[i].isNotEmpty
          ? Uint8List.fromList(imageBytesList[i])
          : Uint8List(0);
      await _putBytes(pageRef, bytes, 'image/jpeg');
    }

    final localeChapter = ChapterLocaleContent(
      chapterId: newChapterId,
      comicId: comicId,
      chapterName: chapterName,
      pageCount: imageBytesList.length,
      createdDate: createdDate,
      isFreePreview: isFreePreview,
      musicUrl: musicUrl.isEmpty ? null : musicUrl,
      pagesVersion: nextPagesVersion(),
    );

    final updated = existing.copyWith(
      chapters: [...existing.chapters, localeChapter],
    );

    final write = await FirestoreWriteHelper.updateDocument(docRef, {
      'locales.$locale': updated.toMap(),
    });
    if (!write.isSuccess) {
      await _safeDeleteFolder(folderRef);
      return Left(
        FirebaseErrorMapper.map(write.error!, action: 'Add locale chapter'),
      );
    }

    return Right(
      ChapterModel(
        chapterId: localeChapter.chapterId,
        comicId: comicId,
        chapterName: localeChapter.chapterName,
        pageCount: localeChapter.pageCount,
        createdDate: localeChapter.createdDate,
        isFreePreview: localeChapter.isFreePreview,
        musicUrl: localeChapter.musicUrl,
        pagesVersion: localeChapter.pagesVersion,
      ),
    );
  }

  Future<Either<String, String?>> _updateEnglishChapter(
    DocumentReference<Map<String, dynamic>> docRef,
    Map<String, dynamic> data,
    String comicId,
    String chapterId, {
    bool? isFreePreview,
    List<List<int>>? additionalImageBytesList,
    List<int>? musicBytes,
    String? chapterName,
  }) async {
    final rawChapters = (data['chapters'] as List<dynamic>?) ?? [];
    final chaptersList = rawChapters
        .map((e) => Map<String, dynamic>.from(e as Map<String, dynamic>))
        .toList();
    final index = chaptersList.indexWhere(
      (c) => (c['chapterId'] as String?) == chapterId,
    );
    if (index < 0) return const Left('Chapter not found');
    final chapter = Map<String, dynamic>.from(chaptersList[index]);
    if (isFreePreview != null) chapter['isFreePreview'] = isFreePreview;
    if (chapterName != null) chapter['chapterName'] = chapterName;

    final folderRef = _folderRef(
      comicId: comicId,
      chapterId: chapterId,
      locale: AppLocales.english,
    );

    String? resultMusicUrl;
    if (musicBytes != null && musicBytes.isNotEmpty) {
      resultMusicUrl = await _uploadMusic(folderRef, musicBytes);
      chapter['musicUrl'] = resultMusicUrl;
    }

    var newPageCount = (chapter['pageCount'] as num?)?.toInt() ?? 0;
    if (additionalImageBytesList != null &&
        additionalImageBytesList.isNotEmpty) {
      await _uploadPages(
        folderRef,
        additionalImageBytesList,
        startPage: newPageCount + 1,
      );
      newPageCount += additionalImageBytesList.length;
      chapter['pageCount'] = newPageCount;
    }

    final pagesChanged =
        resultMusicUrl != null ||
        (additionalImageBytesList != null &&
            additionalImageBytesList.isNotEmpty);
    if (pagesChanged) {
      chapter['pagesVersion'] = nextPagesVersion(
        (chapter['pagesVersion'] as num?)?.toInt() ?? 0,
      );
    }

    chaptersList[index] = chapter;
    final write = await FirestoreWriteHelper.updateDocument(docRef, {
      'chapters': chaptersList,
    });
    if (!write.isSuccess) {
      return Left(
        FirebaseErrorMapper.map(write.error!, action: 'Update chapter'),
      );
    }
    return Right(resultMusicUrl);
  }

  Future<Either<String, String?>> _updateLocaleChapter(
    DocumentReference<Map<String, dynamic>> docRef,
    Map<String, dynamic> data,
    String comicId,
    String chapterId,
    String locale, {
    List<List<int>>? additionalImageBytesList,
    List<int>? musicBytes,
    String? chapterName,
    bool? isFreePreview,
  }) async {
    if (!AppLocales.isSupported(locale) || AppLocales.isEnglish(locale)) {
      return const Left('Invalid content locale');
    }

    final rawLocales = data['locales'];
    final localesMap = rawLocales is Map
        ? Map<String, dynamic>.from(rawLocales)
        : <String, dynamic>{};
    final existingLocale = localesMap[locale];
    final localeContent = existingLocale is Map
        ? ComicLocaleContent.fromMap(Map<String, dynamic>.from(existingLocale))
        : const ComicLocaleContent(
            title: '',
            description: '',
            categoryName: '',
          );

    final chapters = List<ChapterLocaleContent>.from(localeContent.chapters);
    final index = chapters.indexWhere((c) => c.chapterId == chapterId);
    if (index < 0) {
      return const Left('Chapter not found in this language');
    }
    var overlay = chapters[index];

    if (chapterName != null) {
      overlay = overlay.copyWith(chapterName: chapterName);
    }
    if (isFreePreview != null) {
      overlay = overlay.copyWith(isFreePreview: isFreePreview);
    }

    final folderRef = _folderRef(
      comicId: comicId,
      chapterId: chapterId,
      locale: locale,
    );

    String? resultMusicUrl;
    if (musicBytes != null && musicBytes.isNotEmpty) {
      resultMusicUrl = await _uploadMusic(folderRef, musicBytes);
      overlay = overlay.copyWith(musicUrl: resultMusicUrl);
    }

    var newPageCount = overlay.pageCount;
    if (additionalImageBytesList != null &&
        additionalImageBytesList.isNotEmpty) {
      await _uploadPages(
        folderRef,
        additionalImageBytesList,
        startPage: newPageCount + 1,
      );
      newPageCount += additionalImageBytesList.length;
      overlay = overlay.copyWith(pageCount: newPageCount);
    }

    final pagesChanged =
        resultMusicUrl != null ||
        (additionalImageBytesList != null &&
            additionalImageBytesList.isNotEmpty);
    if (pagesChanged) {
      overlay = overlay.copyWith(
        pagesVersion: nextPagesVersion(overlay.pagesVersion),
      );
    }

    chapters[index] = overlay;

    final updated = localeContent.copyWith(chapters: chapters);
    final write = await FirestoreWriteHelper.updateDocument(docRef, {
      'locales.$locale': updated.toMap(),
    });
    if (!write.isSuccess) {
      return Left(
        FirebaseErrorMapper.map(write.error!, action: 'Update locale chapter'),
      );
    }
    return Right(resultMusicUrl);
  }

  Future<String> _uploadMusic(Reference folderRef, List<int> musicBytes) async {
    final musicRef = folderRef.child(ChapterStoragePaths.musicFileName);
    try {
      await softDeadlineVoid(
        musicRef.delete(),
        deadline: _storageTimeout,
        onDeadline: () => throw StateError(
          'Deleting music timed out. Check your connection.',
        ),
      );
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
    await _putBytes(musicRef, Uint8List.fromList(musicBytes), 'audio/mpeg');
    return softDeadline(
      musicRef.getDownloadURL(),
      deadline: _storageTimeout,
      onDeadline: () => throw StateError(
        'Getting music URL timed out. Check your connection.',
      ),
    );
  }

  Future<void> _uploadPages(
    Reference folderRef,
    List<List<int>> imageBytesList, {
    required int startPage,
  }) async {
    for (var i = 0; i < imageBytesList.length; i++) {
      final pageNum = startPage + i;
      final pageRef = folderRef.child('$pageNum.jpeg');
      final bytes = imageBytesList[i].isNotEmpty
          ? Uint8List.fromList(imageBytesList[i])
          : Uint8List(0);
      await _putBytes(pageRef, bytes, 'image/jpeg');
    }
  }

  @override
  Future<Either<String, String?>> updateChapter(
    String comicId,
    String chapterId, {
    bool? isFreePreview,
    List<List<int>>? additionalImageBytesList,
    List<int>? musicBytes,
    String? chapterName,
    String locale = AppLocales.english,
  }) async {
    try {
      final docRef = _docRef(comicId);
      final doc = await docRef.get();
      if (!doc.exists || doc.data() == null) {
        return const Left('Comic not found');
      }
      final data = doc.data()!;

      if (AppLocales.isEnglish(locale)) {
        return _updateEnglishChapter(
          docRef,
          data,
          comicId,
          chapterId,
          isFreePreview: isFreePreview,
          additionalImageBytesList: additionalImageBytesList,
          musicBytes: musicBytes,
          chapterName: chapterName,
        );
      }

      return _updateLocaleChapter(
        docRef,
        data,
        comicId,
        chapterId,
        locale,
        additionalImageBytesList: additionalImageBytesList,
        musicBytes: musicBytes,
        chapterName: chapterName,
        isFreePreview: isFreePreview,
      );
    } catch (e, stackTrace) {
      return Left(
        FirebaseErrorMapper.map(
          e,
          action: 'Update chapter',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<String, void>> deleteAllChapterImages(
    String comicId,
    String chapterId, {
    String locale = AppLocales.english,
  }) async {
    try {
      if (AppLocales.isEnglish(locale)) {
        // Clear EN pages/music only — locale overlays keep their own Storage.
        final deleteResult = await _safeDeleteFolder(
          _folderRef(
            comicId: comicId,
            chapterId: chapterId,
            locale: AppLocales.english,
          ),
        );
        if (deleteResult.isLeft()) return deleteResult;

        final docRef = _docRef(comicId);
        final doc = await docRef.get();
        if (!doc.exists || doc.data() == null) {
          return const Left('Comic not found');
        }
        final data = doc.data()!;
        final rawChapters = (data['chapters'] as List<dynamic>?) ?? [];
        final chaptersList = rawChapters
            .map((e) => Map<String, dynamic>.from(e as Map<String, dynamic>))
            .toList();
        final index = chaptersList.indexWhere(
          (c) => (c['chapterId'] as String?) == chapterId,
        );
        if (index < 0) return const Left('Chapter not found');
        final chapter = Map<String, dynamic>.from(chaptersList[index]);
        chapter['pageCount'] = 0;
        chapter.remove('musicUrl');
        chapter['pagesVersion'] = nextPagesVersion(
          (chapter['pagesVersion'] as num?)?.toInt() ?? 0,
        );
        chaptersList[index] = chapter;
        final write = await FirestoreWriteHelper.updateDocument(docRef, {
          'chapters': chaptersList,
        });
        if (!write.isSuccess) {
          return Left(
            FirebaseErrorMapper.map(
              write.error!,
              action: 'Delete chapter images',
            ),
          );
        }
        return const Right(null);
      }

      // Locale-only: delete that locale's chapter folder + zero pageCount.
      final folderResult = await _safeDeleteFolder(
        _folderRef(comicId: comicId, chapterId: chapterId, locale: locale),
      );
      if (folderResult.isLeft()) return folderResult;

      final docRef = _docRef(comicId);
      final doc = await docRef.get();
      if (!doc.exists || doc.data() == null) {
        return const Left('Comic not found');
      }
      final data = doc.data()!;
      final rawLocales = data['locales'];
      if (rawLocales is! Map || rawLocales[locale] == null) {
        return const Left('Locale not found');
      }
      final localeContent = ComicLocaleContent.fromMap(
        Map<String, dynamic>.from(rawLocales[locale] as Map),
      );
      final chapters = List<ChapterLocaleContent>.from(localeContent.chapters);
      final index = chapters.indexWhere((c) => c.chapterId == chapterId);
      if (index < 0) {
        // Nothing to clear in Firestore.
        return const Right(null);
      }
      chapters[index] = chapters[index].copyWith(
        pageCount: 0,
        clearMusicUrl: true,
        pagesVersion: nextPagesVersion(chapters[index].pagesVersion),
      );
      final write = await FirestoreWriteHelper.updateDocument(docRef, {
        'locales.$locale': localeContent.copyWith(chapters: chapters).toMap(),
      });
      if (!write.isSuccess) {
        return Left(
          FirebaseErrorMapper.map(
            write.error!,
            action: 'Clear locale chapter pages',
          ),
        );
      }
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        FirebaseErrorMapper.map(
          e,
          action: 'Delete chapter images',
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
