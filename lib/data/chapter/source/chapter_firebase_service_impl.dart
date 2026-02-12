import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:writeread_admin_panel/data/chapter/source/chapter_firebase_service.dart';

class ChapterFirebaseServiceImpl extends ChapterFirebaseService {
  static const String _comicsCollection = 'Comics';
  static const String _storageComicsPath = 'Comics';

  @override
  Future<Either<String, void>> deleteLastChapter(String comicId) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(_comicsCollection)
          .doc(comicId);

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

      // Delete Storage folder first. If this fails (e.g. not signed in), we show
      // the error and do NOT update Firestore, so data stays in sync.
      final deleteFolderResult = await deleteChapterStorageFolder(
        comicId,
        chapterId,
      );
      if (deleteFolderResult.isLeft()) {
        return deleteFolderResult;
      }

      final newChapters = chaptersList.sublist(0, chaptersList.length - 1);
      await docRef.update({
        'chapters': newChapters,
        'chapterCount': newChapters.length,
      });

      return const Right(null);
    } catch (e) {
      return Left('Failed to delete chapter: $e');
    }
  }

  /// Deletes the Storage folder Comics/{comicId}/{chapterId} and all its contents.
  /// Requires user to be signed in (Storage rules: allow write if request.auth != null).
  /// Firestore chapterId must match the Storage folder name exactly (e.g. "chapter8").
  Future<Either<String, void>> deleteChapterStorageFolder(
    String comicId,
    String chapterId,
  ) async {
    try {
      final folderRef = FirebaseStorage.instance
          .ref()
          .child(_storageComicsPath)
          .child(comicId)
          .child(chapterId);
      await _deleteStorageFolderRecursively(folderRef);
      return const Right(null);
    } on FirebaseException catch (e) {
      // permission-denied = not signed in; object-not-found = folder already gone
      if (e.code == 'object-not-found') {
        return const Right(null);
      }
      return Left('Storage: ${e.code} – ${e.message ?? e.toString()}');
    } catch (e) {
      return Left('Failed to delete chapter folder: $e');
    }
  }

  /// Runs [fn] on the platform (main) thread to avoid Firebase plugin
  /// "non-platform thread" crashes on Windows/desktop.
  Future<T> _runOnPlatformThread<T>(Future<T> Function() fn) async {
    final completer = Completer<T>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fn().then(completer.complete).catchError(completer.completeError);
    });
    return completer.future;
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

  @override
  Future<Either<String, void>> addChapter(
    String comicId,
    String chapterName,
    List<List<int>> imageBytesList, {
    bool isVip = true,
  }) async {
    if (imageBytesList.isEmpty) {
      return const Left('Add at least one image');
    }
    try {
      final docRef = FirebaseFirestore.instance
          .collection(_comicsCollection)
          .doc(comicId);
      final doc = await docRef.get();
      if (!doc.exists || doc.data() == null) {
        return const Left('Comic not found');
      }
      final data = doc.data()!;
      final currentCount = (data['chapterCount'] as num?)?.toInt() ?? 0;
      final newChapterId = 'chapter${currentCount + 1}';
      final newChapter = <String, dynamic>{
        'chapterId': newChapterId,
        'comicId': comicId,
        'chapterName': chapterName,
        'createdDate': Timestamp.now(),
        'pageCount': imageBytesList.length,
        'isVip': isVip,
      };
      // Update Firestore first so data is saved before Storage uploads.
      // Storage uploads can trigger platform-channel callbacks on a non-main
      // thread on Windows, which can crash the app; doing Firestore first
      // ensures the chapter is in the DB even if that happens.
      await docRef.update({
        'chapters': FieldValue.arrayUnion([newChapter]),
        'chapterCount': FieldValue.increment(1),
      });
      final folderRef = FirebaseStorage.instance
          .ref()
          .child(_storageComicsPath)
          .child(comicId)
          .child(newChapterId);
      // Run each Storage upload on the main (platform) thread to avoid
      // "channel sent a message from native to Flutter on a non-platform thread"
      // crash on Windows/desktop.
      for (var i = 0; i < imageBytesList.length; i++) {
        final pageRef = folderRef.child('${i + 1}.jpeg');
        final bytes = imageBytesList[i].isNotEmpty
            ? Uint8List.fromList(imageBytesList[i])
            : Uint8List(0);
        await _runOnPlatformThread(
          () => pageRef.putData(
            bytes,
            SettableMetadata(contentType: 'image/jpeg'),
          ),
        );
      }
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(
        'Storage/Firestore: ${e.code} – ${e.message ?? e.toString()}',
      );
    } catch (e) {
      return Left('Failed to add chapter: $e');
    }
  }

  @override
  Future<Either<String, void>> updateChapter(
    String comicId,
    String chapterId, {
    bool? isVip,
    List<List<int>>? additionalImageBytesList,
  }) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(_comicsCollection)
          .doc(comicId);
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
      if (isVip != null) chapter['isVip'] = isVip;
      int newPageCount = (chapter['pageCount'] as num?)?.toInt() ?? 0;
      if (additionalImageBytesList != null && additionalImageBytesList.isNotEmpty) {
        final folderRef = FirebaseStorage.instance
            .ref()
            .child(_storageComicsPath)
            .child(comicId)
            .child(chapterId);
        for (var i = 0; i < additionalImageBytesList.length; i++) {
          final pageNum = newPageCount + i + 1;
          final pageRef = folderRef.child('$pageNum.jpeg');
          final bytes = additionalImageBytesList[i].isNotEmpty
              ? Uint8List.fromList(additionalImageBytesList[i])
              : Uint8List(0);
          await _runOnPlatformThread(
            () => pageRef.putData(
              bytes,
              SettableMetadata(contentType: 'image/jpeg'),
            ),
          );
        }
        newPageCount += additionalImageBytesList.length;
        chapter['pageCount'] = newPageCount;
      }
      chaptersList[index] = chapter;
      await docRef.update({'chapters': chaptersList});
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(
        'Update chapter: ${e.code} – ${e.message ?? e.toString()}',
      );
    } catch (e) {
      return Left('Failed to update chapter: $e');
    }
  }

  @override
  Future<Either<String, void>> deleteAllChapterImages(
    String comicId,
    String chapterId,
  ) async {
    try {
      final deleteResult = await deleteChapterStorageFolder(comicId, chapterId);
      if (deleteResult.isLeft()) return deleteResult;
      final docRef = FirebaseFirestore.instance
          .collection(_comicsCollection)
          .doc(comicId);
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
      chaptersList[index] = chapter;
      await docRef.update({'chapters': chaptersList});
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(
        'Delete images: ${e.code} – ${e.message ?? e.toString()}',
      );
    } catch (e) {
      return Left('Failed to delete chapter images: $e');
    }
  }
}
