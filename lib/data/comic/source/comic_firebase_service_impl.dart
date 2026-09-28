import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:writeread_admin_panel/core/constants/firestore_collections.dart';
import 'package:writeread_admin_panel/core/error/firebase_error_mapper.dart';
import 'package:writeread_admin_panel/core/firebase/firestore_write_helper.dart';
import 'package:writeread_admin_panel/core/firebase/soft_deadline.dart';
import 'package:writeread_admin_panel/core/locale/app_locales.dart';
import 'package:writeread_admin_panel/core/locale/chapter_storage_paths.dart';
import 'package:writeread_admin_panel/data/comic/model/comic_model.dart';
import 'package:writeread_admin_panel/data/comic/source/comic_firebase_service.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_content_type.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_locale_content.dart';

class ComicFirebaseServiceImpl extends ComicFirebaseService {
  static const String _comicsCollection = FirestoreCollections.comics;
  static const String _storageComicsPath = FirestoreCollections.comics;
  static const Duration _storageTimeout = Duration(seconds: 60);
  static const int _maxComicIdLength = 80;
  static const int _maxIdSuffixAttempts = 50;

  String _titleToComicId(String title) {
    final slug = title
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
    final base = slug.isEmpty ? 'comic' : slug;
    if (base.length > _maxComicIdLength) {
      return base.substring(0, _maxComicIdLength);
    }
    return base;
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

  Future<void> _deleteStorageFileIfExists(Reference ref) async {
    try {
      await ref.delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }

  /// Best-effort cover cleanup; a leftover file must never fail the save.
  Future<void> _deleteCoverQuietly(String? imageField) async {
    if (imageField == null || imageField.trim().isEmpty) return;
    try {
      await _deleteStorageFileIfExists(
        FirebaseStorage.instance.ref().child(
          ChapterStoragePaths.coverObjectPathFromField(imageField),
        ),
      );
    } catch (e) {
      debugPrint('Cover cleanup skipped for $imageField: $e');
    }
  }

  Future<Either<String, String>> _allocateComicId(
    CollectionReference<Map<String, dynamic>> colRef,
    String title,
  ) async {
    try {
      var baseId = _titleToComicId(title);
      if (baseId.isEmpty) baseId = 'comic';

      for (var suffix = 0; suffix < _maxIdSuffixAttempts; suffix++) {
        final id = suffix == 0 ? baseId : '${baseId}_$suffix';
        final doc = await softDeadline(
          colRef.doc(id).get(),
          deadline: _storageTimeout,
          onDeadline: () => throw StateError(
            'Looking up comic id timed out. Check your connection.',
          ),
        );
        if (!doc.exists) return Right(id);
      }
      return const Left(
        'Could not create a unique comic id. Change the title and try again.',
      );
    } catch (e, stackTrace) {
      return Left(
        FirebaseErrorMapper.map(
          e,
          action: 'Allocate comic id',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<String?> _uploadCover(String filename, List<int> imageBytes) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child(_storageComicsPath)
          .child(filename);
      await softDeadlineVoid(
        ref.putData(
          Uint8List.fromList(imageBytes),
          SettableMetadata(contentType: 'image/jpeg'),
        ),
        deadline: _storageTimeout,
        onDeadline: () =>
            throw StateError('Cover upload timed out. Check your connection.'),
      );
      return null;
    } catch (e, stackTrace) {
      return FirebaseErrorMapper.map(
        e,
        action: 'Cover upload',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Either<String, ComicModel>> addComic(
    String title,
    String description,
    String categoryName, {
    required bool isSensitive,
    required String contentType,
    required bool isFree,
    required String productId,
    List<int>? imageBytes,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Left('Not signed in. Sign in again, then save.');
      }

      final colRef = FirebaseFirestore.instance.collection(_comicsCollection);
      final comicIdResult = await _allocateComicId(colRef, title);
      if (comicIdResult.isLeft()) {
        return Left(comicIdResult.fold((l) => l, (_) => ''));
      }
      final comicId = comicIdResult.getOrElse(() => '');
      final docRef = colRef.doc(comicId);

      String imageFilename = '';
      if (imageBytes != null && imageBytes.isNotEmpty) {
        imageFilename = ChapterStoragePaths.versionedCoverImageField(
          comicId: comicId,
          version: DateTime.now().millisecondsSinceEpoch,
        );
        final uploadError = await _uploadCover(imageFilename, imageBytes);
        if (uploadError != null) return Left(uploadError);
      }

      final categoryTrimmed = categoryName.trim();
      final createdDate = DateTime.now().toUtc();
      final parsedContentType = ComicContentType.parse(contentType);
      // Use List<dynamic> (not List<Map>) — typed empty lists can break
      // Firestore JS interop on Flutter Web.
      final data = <String, dynamic>{
        'comicId': comicId,
        'title': title.trim(),
        'description': description.trim(),
        'image': imageFilename,
        'isSensitive': isSensitive,
        'contentType': parsedContentType,
        'isFree': isFree,
        'productId': productId.trim(),
        'likeCount': 0,
        'readCount': 0,
        'chapterCount': 0,
        'createdDate': Timestamp.fromDate(createdDate),
        'categoryId': categoryTrimmed.isEmpty ? '' : categoryTrimmed,
        'categoryName': categoryTrimmed,
        'chapters': <dynamic>[],
      };

      try {
        final write = await FirestoreWriteHelper.setDocument(docRef, data);
        if (!write.isSuccess) {
          if (write.error is FirebaseException) {
            await _deleteCoverQuietly(imageFilename);
          }
          return Left(
            FirebaseErrorMapper.map(write.error!, action: 'Save comic'),
          );
        }
      } catch (e, stackTrace) {
        return Left(
          FirebaseErrorMapper.map(
            e,
            action: 'Save comic',
            stackTrace: stackTrace,
          ),
        );
      }

      try {
        return Right(ComicModel.fromMap(data));
      } catch (e, stackTrace) {
        // Write already succeeded — still return a usable model.
        debugPrint('Parse comic after save failed: $e\n$stackTrace');
        return Right(
          ComicModel(
            comicId: comicId,
            title: title.trim(),
            description: description.trim(),
            image: imageFilename,
            isSensitive: isSensitive,
            contentType: parsedContentType,
            isFree: isFree,
            productId: productId.trim(),
            likeCount: 0,
            readCount: 0,
            chapterCount: 0,
            createdDate: createdDate,
            categoryId: categoryTrimmed,
            categoryName: categoryTrimmed,
            chapters: const [],
            locales: const {},
          ),
        );
      }
    } catch (e, stackTrace) {
      return Left(
        FirebaseErrorMapper.map(e, action: 'Add comic', stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<Either<String, ComicModel>> updateComic(
    String comicId, {
    required String title,
    required String description,
    required bool isSensitive,
    required String contentType,
    required bool isFree,
    required String productId,
    String? oldImageFilename,
    List<int>? newImageBytes,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Left('Not signed in. Sign in again, then save.');
      }

      final docRef = FirebaseFirestore.instance
          .collection(_comicsCollection)
          .doc(comicId);
      String? newImageFilename;
      String? replacedImageFilename;

      if (newImageBytes != null && newImageBytes.isNotEmpty) {
        final current = await softDeadline(
          docRef.get(),
          deadline: _storageTimeout,
          onDeadline: () => throw StateError(
            'Reading comic timed out. Check your connection.',
          ),
        );
        final currentImage = current.data()?['image'];
        replacedImageFilename =
            currentImage is String && currentImage.trim().isNotEmpty
            ? currentImage.trim()
            : oldImageFilename;
        newImageFilename = ChapterStoragePaths.versionedCoverImageField(
          comicId: comicId,
          version: DateTime.now().millisecondsSinceEpoch,
        );
        final uploadError = await _uploadCover(newImageFilename, newImageBytes);
        if (uploadError != null) return Left(uploadError);
      }

      try {
        final write = await FirestoreWriteHelper.updateDocument(docRef, {
          'title': title.trim(),
          'description': description.trim(),
          'isSensitive': isSensitive,
          'contentType': ComicContentType.parse(contentType),
          'isFree': isFree,
          'productId': productId.trim(),
          'image': ?newImageFilename,
        });
        if (!write.isSuccess) {
          if (write.error is FirebaseException) {
            await _deleteCoverQuietly(newImageFilename);
          }
          return Left(
            FirebaseErrorMapper.map(write.error!, action: 'Update comic'),
          );
        }
      } catch (e, stackTrace) {
        return Left(
          FirebaseErrorMapper.map(
            e,
            action: 'Update comic',
            stackTrace: stackTrace,
          ),
        );
      }

      if (replacedImageFilename != null &&
          replacedImageFilename != newImageFilename) {
        await _deleteCoverQuietly(replacedImageFilename);
      }

      final snap = await softDeadline(
        docRef.get(),
        deadline: _storageTimeout,
        onDeadline: () => throw StateError(
          'Reading updated comic timed out. Check your connection.',
        ),
      );
      if (!snap.exists || snap.data() == null) {
        return const Left('Comic not found after update');
      }
      return Right(_mapToModel(comicId, snap.data()!));
    } catch (e, stackTrace) {
      return Left(
        FirebaseErrorMapper.map(
          e,
          action: 'Update comic',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<String, void>> deleteComic(String comicId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Left('Not signed in. Sign in again, then delete.');
      }

      final docRef = FirebaseFirestore.instance
          .collection(_comicsCollection)
          .doc(comicId);
      final doc = await docRef.get();
      final storageRef = FirebaseStorage.instance.ref().child(
        _storageComicsPath,
      );

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        final imageValue = data['image'];
        final imageFilename = imageValue is String ? imageValue.trim() : null;
        if (imageFilename != null && imageFilename.isNotEmpty) {
          final nameOnly = imageFilename.contains('/')
              ? imageFilename.split('/').last
              : imageFilename;
          await _deleteStorageFileIfExists(storageRef.child(nameOnly));
        }

        final rawChapters = (data['chapters'] as List<dynamic>?) ?? [];
        for (final ch in rawChapters) {
          final map = ch is Map ? Map<String, dynamic>.from(ch) : null;
          final chapterId = map?['chapterId'] as String?;
          if (chapterId != null && chapterId.isNotEmpty) {
            final chapterFolderRef = storageRef.child(comicId).child(chapterId);
            try {
              await _deleteStorageFolderRecursively(chapterFolderRef);
            } on FirebaseException catch (e) {
              if (e.code != 'object-not-found') {
                return Left(
                  FirebaseErrorMapper.map(e, action: 'Delete chapter files'),
                );
              }
            }
          }
        }
      }

      await _deleteCoverQuietly(
        ChapterStoragePaths.coverImageField(comicId: comicId),
      );
      try {
        final rootList = await storageRef.listAll();
        for (final item in rootList.items) {
          if (ChapterStoragePaths.isRootCoverNameOf(item.name, comicId)) {
            await _deleteStorageFileIfExists(item);
          }
        }
      } catch (e) {
        debugPrint('Old cover sweep skipped for $comicId: $e');
      }
      await _deleteStorageFileIfExists(storageRef.child('$comicId.jpg'));
      await _deleteStorageFileIfExists(storageRef.child('$comicId.jpeg'));

      final comicFolderRef = storageRef.child(comicId);
      try {
        await _deleteStorageFolderRecursively(comicFolderRef);
      } on FirebaseException catch (e) {
        if (e.code != 'object-not-found') {
          return Left(
            FirebaseErrorMapper.map(e, action: 'Delete comic folder'),
          );
        }
      }

      try {
        await docRef.delete();
      } catch (e, stackTrace) {
        return Left(
          FirebaseErrorMapper.map(
            e,
            action: 'Delete comic',
            stackTrace: stackTrace,
          ),
        );
      }
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        FirebaseErrorMapper.map(
          e,
          action: 'Delete comic',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<String, List<ComicModel>>> getAllComics() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_comicsCollection)
          .get();
      final list = <ComicModel>[];
      for (final doc in snapshot.docs) {
        try {
          list.add(_docToModel(doc));
        } catch (e, stackTrace) {
          return Left(
            FirebaseErrorMapper.map(
              e,
              action: 'Parse comic ${doc.id}',
              stackTrace: stackTrace,
            ),
          );
        }
      }
      return Right(list);
    } catch (e, stackTrace) {
      return Left(
        FirebaseErrorMapper.map(
          e,
          action: 'Load comics',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  ComicModel _docToModel(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return _mapToModel(doc.id, doc.data());
  }

  ComicModel _mapToModel(String comicId, Map<String, dynamic> raw) {
    final data = Map<String, dynamic>.from(raw);
    data['comicId'] = comicId;
    return ComicModel.fromMap(data);
  }

  Either<String, void> _validateContentLocale(String locale) {
    if (!AppLocales.isSupported(locale) || AppLocales.isEnglish(locale)) {
      return const Left('Invalid content locale');
    }
    return const Right(null);
  }

  Future<Either<String, ComicModel>> _readComicModel(
    DocumentReference<Map<String, dynamic>> docRef,
    String comicId,
  ) async {
    final snap = await softDeadline(
      docRef.get(),
      deadline: _storageTimeout,
      onDeadline: () =>
          throw StateError('Reading comic timed out. Check your connection.'),
    );
    if (!snap.exists || snap.data() == null) {
      return const Left('Comic not found');
    }
    return Right(_mapToModel(comicId, snap.data()!));
  }

  @override
  Future<Either<String, ComicModel>> updateLocaleMetadata(
    String comicId,
    String locale, {
    required String title,
    required String description,
    required String categoryName,
  }) async {
    try {
      final localeCheck = _validateContentLocale(locale);
      if (localeCheck.isLeft()) {
        return Left(localeCheck.fold((l) => l, (_) => ''));
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Left('Not signed in. Sign in again, then save.');
      }

      final docRef = FirebaseFirestore.instance
          .collection(_comicsCollection)
          .doc(comicId);
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
          : null;

      final updated = ComicLocaleContent(
        title: title.trim(),
        description: description.trim(),
        categoryName: categoryName.trim(),
        image: existing?.image ?? '',
        chapters: existing?.chapters ?? const [],
      );

      final write = await FirestoreWriteHelper.updateDocument(docRef, {
        'locales.$locale': updated.toMap(),
      });
      if (!write.isSuccess) {
        return Left(
          FirebaseErrorMapper.map(
            write.error!,
            action: 'Update locale metadata',
          ),
        );
      }
      return _readComicModel(docRef, comicId);
    } catch (e, stackTrace) {
      return Left(
        FirebaseErrorMapper.map(
          e,
          action: 'Update locale metadata',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<String, ComicModel>> upsertLocaleChapter(
    String comicId,
    String locale,
    ChapterLocaleContent chapter,
  ) async {
    try {
      final localeCheck = _validateContentLocale(locale);
      if (localeCheck.isLeft()) {
        return Left(localeCheck.fold((l) => l, (_) => ''));
      }
      if (chapter.chapterId.isEmpty) {
        return const Left('Chapter id required');
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Left('Not signed in. Sign in again, then save.');
      }

      final docRef = FirebaseFirestore.instance
          .collection(_comicsCollection)
          .doc(comicId);
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

      final chapters = List<ChapterLocaleContent>.from(existing.chapters);
      final index = chapters.indexWhere(
        (c) => c.chapterId == chapter.chapterId,
      );
      final normalized = chapter.copyWith(
        comicId: chapter.comicId.isNotEmpty ? chapter.comicId : comicId,
      );
      if (index >= 0) {
        // Server copy owns pages/music/version; the caller may hold stale values.
        chapters[index] = chapters[index].copyWith(
          chapterName: normalized.chapterName,
          isFreePreview: normalized.isFreePreview,
        );
      } else {
        chapters.add(normalized);
      }

      final write = await FirestoreWriteHelper.updateDocument(docRef, {
        'locales.$locale': existing.copyWith(chapters: chapters).toMap(),
      });
      if (!write.isSuccess) {
        return Left(
          FirebaseErrorMapper.map(
            write.error!,
            action: 'Upsert locale chapter',
          ),
        );
      }
      return _readComicModel(docRef, comicId);
    } catch (e, stackTrace) {
      return Left(
        FirebaseErrorMapper.map(
          e,
          action: 'Upsert locale chapter',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<String, ComicModel>> clearLocaleChapterPages(
    String comicId,
    String locale,
    String chapterId,
  ) async {
    try {
      final localeCheck = _validateContentLocale(locale);
      if (localeCheck.isLeft()) {
        return Left(localeCheck.fold((l) => l, (_) => ''));
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Left('Not signed in. Sign in again, then clear.');
      }

      final folderRef = FirebaseStorage.instance.ref().child(
        ChapterStoragePaths.chapterFolderObjectPath(
          comicId: comicId,
          chapterId: chapterId,
          locale: locale,
        ),
      );
      try {
        await _deleteStorageFolderRecursively(folderRef);
      } on FirebaseException catch (e) {
        if (e.code != 'object-not-found') {
          return Left(
            FirebaseErrorMapper.map(e, action: 'Clear locale chapter pages'),
          );
        }
      }

      final docRef = FirebaseFirestore.instance
          .collection(_comicsCollection)
          .doc(comicId);
      final doc = await docRef.get();
      if (!doc.exists || doc.data() == null) {
        return const Left('Comic not found');
      }

      final data = doc.data()!;
      final rawLocales = data['locales'];
      if (rawLocales is! Map || rawLocales[locale] is! Map) {
        return const Left('Locale not found');
      }

      final existing = ComicLocaleContent.fromMap(
        Map<String, dynamic>.from(rawLocales[locale] as Map),
      );
      final chapters = List<ChapterLocaleContent>.from(existing.chapters);
      final index = chapters.indexWhere((c) => c.chapterId == chapterId);
      if (index < 0) {
        return _readComicModel(docRef, comicId);
      }

      chapters[index] = chapters[index].copyWith(
        pageCount: 0,
        clearMusicUrl: true,
        pagesVersion: ChapterStoragePaths.nextPagesVersion(
          chapters[index].pagesVersion,
        ),
      );

      final write = await FirestoreWriteHelper.updateDocument(docRef, {
        'locales.$locale': existing.copyWith(chapters: chapters).toMap(),
      });
      if (!write.isSuccess) {
        return Left(
          FirebaseErrorMapper.map(
            write.error!,
            action: 'Clear locale chapter pages',
          ),
        );
      }
      return _readComicModel(docRef, comicId);
    } catch (e, stackTrace) {
      return Left(
        FirebaseErrorMapper.map(
          e,
          action: 'Clear locale chapter pages',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<String, ComicModel>> deleteLocale(
    String comicId,
    String locale,
  ) async {
    try {
      final localeCheck = _validateContentLocale(locale);
      if (localeCheck.isLeft()) {
        return Left(localeCheck.fold((l) => l, (_) => ''));
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Left('Not signed in. Sign in again, then delete.');
      }

      final localeFolderRef = FirebaseStorage.instance.ref().child(
        ChapterStoragePaths.localeFolderObjectPath(
          comicId: comicId,
          locale: locale,
        ),
      );
      try {
        await _deleteStorageFolderRecursively(localeFolderRef);
      } on FirebaseException catch (e) {
        if (e.code != 'object-not-found') {
          return Left(
            FirebaseErrorMapper.map(e, action: 'Delete locale folder'),
          );
        }
      }

      final docRef = FirebaseFirestore.instance
          .collection(_comicsCollection)
          .doc(comicId);
      final write = await FirestoreWriteHelper.updateDocument(docRef, {
        'locales.$locale': FieldValue.delete(),
      });
      if (!write.isSuccess) {
        return Left(
          FirebaseErrorMapper.map(write.error!, action: 'Delete locale'),
        );
      }
      return _readComicModel(docRef, comicId);
    } catch (e, stackTrace) {
      return Left(
        FirebaseErrorMapper.map(
          e,
          action: 'Delete locale',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<String?> _uploadCoverAtObjectPath(
    String objectPath,
    List<int> imageBytes,
  ) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(objectPath);
      await softDeadlineVoid(
        ref.putData(
          Uint8List.fromList(imageBytes),
          SettableMetadata(contentType: 'image/jpeg'),
        ),
        deadline: _storageTimeout,
        onDeadline: () =>
            throw StateError('Cover upload timed out. Check your connection.'),
      );
      return null;
    } catch (e, stackTrace) {
      return FirebaseErrorMapper.map(
        e,
        action: 'Locale cover upload',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Either<String, ComicModel>> uploadLocaleCover(
    String comicId,
    String locale,
    List<int> imageBytes,
  ) async {
    try {
      final localeCheck = _validateContentLocale(locale);
      if (localeCheck.isLeft()) {
        return Left(localeCheck.fold((l) => l, (_) => ''));
      }
      if (imageBytes.isEmpty) {
        return const Left('Cover image required');
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Left('Not signed in. Sign in again, then upload.');
      }

      final docRef = FirebaseFirestore.instance
          .collection(_comicsCollection)
          .doc(comicId);
      final doc = await docRef.get();
      if (!doc.exists || doc.data() == null) {
        return const Left('Comic not found');
      }

      final imageField = ChapterStoragePaths.versionedCoverImageField(
        comicId: comicId,
        locale: locale,
        version: DateTime.now().millisecondsSinceEpoch,
      );
      final uploadError = await _uploadCoverAtObjectPath(
        ChapterStoragePaths.coverObjectPathFromField(imageField),
        imageBytes,
      );
      if (uploadError != null) return Left(uploadError);

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

      final previousImage = existing.image.trim();
      final updated = existing.copyWith(image: imageField);
      final write = await FirestoreWriteHelper.updateDocument(docRef, {
        'locales.$locale': updated.toMap(),
      });
      if (!write.isSuccess) {
        if (write.error is FirebaseException) {
          await _deleteCoverQuietly(imageField);
        }
        return Left(
          FirebaseErrorMapper.map(write.error!, action: 'Save locale cover'),
        );
      }
      if (previousImage.startsWith('$comicId/$locale/') &&
          previousImage != imageField) {
        await _deleteCoverQuietly(previousImage);
      }
      return _readComicModel(docRef, comicId);
    } catch (e, stackTrace) {
      return Left(
        FirebaseErrorMapper.map(
          e,
          action: 'Upload locale cover',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<String, ComicModel>> clearLocaleCover(
    String comicId,
    String locale,
  ) async {
    try {
      final localeCheck = _validateContentLocale(locale);
      if (localeCheck.isLeft()) {
        return Left(localeCheck.fold((l) => l, (_) => ''));
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Left('Not signed in. Sign in again, then clear cover.');
      }

      final docRef = FirebaseFirestore.instance
          .collection(_comicsCollection)
          .doc(comicId);
      final doc = await docRef.get();
      if (!doc.exists || doc.data() == null) {
        return const Left('Comic not found');
      }

      final data = doc.data()!;
      final rawLocales = data['locales'];
      if (rawLocales is! Map || rawLocales[locale] is! Map) {
        return _readComicModel(docRef, comicId);
      }

      final existing = ComicLocaleContent.fromMap(
        Map<String, dynamic>.from(rawLocales[locale] as Map),
      );

      final previousImage = existing.image.trim();
      final updated = existing.copyWith(clearImage: true);
      final write = await FirestoreWriteHelper.updateDocument(docRef, {
        'locales.$locale': updated.toMap(),
      });
      if (!write.isSuccess) {
        return Left(
          FirebaseErrorMapper.map(write.error!, action: 'Clear locale cover'),
        );
      }
      if (previousImage.startsWith('$comicId/$locale/')) {
        await _deleteCoverQuietly(previousImage);
      }
      await _deleteCoverQuietly(
        ChapterStoragePaths.coverImageField(comicId: comicId, locale: locale),
      );
      return _readComicModel(docRef, comicId);
    } catch (e, stackTrace) {
      return Left(
        FirebaseErrorMapper.map(
          e,
          action: 'Clear locale cover',
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
