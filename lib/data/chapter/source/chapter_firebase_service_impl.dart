import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:writeread_admin_panel/core/constants/firestore_collections.dart';
import 'package:writeread_admin_panel/core/error/firebase_error_mapper.dart';
import 'package:writeread_admin_panel/core/firebase/firestore_write_helper.dart';
import 'package:writeread_admin_panel/core/firebase/soft_deadline.dart';
import 'package:writeread_admin_panel/data/chapter/model/chapter_model.dart';
import 'package:writeread_admin_panel/data/chapter/source/chapter_firebase_service.dart';

class ChapterFirebaseServiceImpl extends ChapterFirebaseService {
  static const String _comicsCollection = FirestoreCollections.comics;
  static const String _storageComicsPath = FirestoreCollections.comics;
  static const Duration _storageTimeout = Duration(seconds: 60);

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
    } on FirebaseException catch (e, stackTrace) {
      if (e.code == 'object-not-found') {
        return const Right(null);
      }
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
      onDeadline: () => throw StateError(
        'Upload timed out. Check your connection.',
      ),
    );
  }

  @override
  Future<Either<String, ChapterModel>> addChapter(
    String comicId,
    String chapterName,
    List<List<int>> imageBytesList, {
    bool isFreePreview = false,
    List<int>? musicBytes,
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
      final createdDate = Timestamp.now();
      final newChapter = <String, dynamic>{
        'chapterId': newChapterId,
        'comicId': comicId,
        'chapterName': chapterName,
        'createdDate': createdDate,
        'pageCount': imageBytesList.length,
        'isFreePreview': isFreePreview,
      };

      // Upload music to Storage first so we can store the URL in Firestore.
      if (musicBytes != null && musicBytes.isNotEmpty) {
        final folderRef = FirebaseStorage.instance
            .ref()
            .child(_storageComicsPath)
            .child(comicId)
            .child(newChapterId);
        final musicRef = folderRef.child('music.mp3');
        await _putBytes(
          musicRef,
          Uint8List.fromList(musicBytes),
          'audio/mpeg',
        );
        final musicUrl = await softDeadline(
          musicRef.getDownloadURL(),
          deadline: _storageTimeout,
          onDeadline: () => throw StateError(
            'Getting music URL timed out. Check your connection.',
          ),
        );
        newChapter['musicUrl'] = musicUrl;
      }

      final write = await FirestoreWriteHelper.updateDocument(docRef, {
        'chapters': FieldValue.arrayUnion([newChapter]),
        'chapterCount': FieldValue.increment(1),
      });
      if (!write.isSuccess) {
        return Left(
          FirebaseErrorMapper.map(write.error!, action: 'Add chapter'),
        );
      }
      final folderRef = FirebaseStorage.instance
          .ref()
          .child(_storageComicsPath)
          .child(comicId)
          .child(newChapterId);
      for (var i = 0; i < imageBytesList.length; i++) {
        final pageRef = folderRef.child('${i + 1}.jpeg');
        final bytes = imageBytesList[i].isNotEmpty
            ? Uint8List.fromList(imageBytesList[i])
            : Uint8List(0);
        await _putBytes(pageRef, bytes, 'image/jpeg');
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

  @override
  Future<Either<String, String?>> updateChapter(
    String comicId,
    String chapterId, {
    bool? isFreePreview,
    List<List<int>>? additionalImageBytesList,
    List<int>? musicBytes,
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
      if (isFreePreview != null) chapter['isFreePreview'] = isFreePreview;

      final folderRef = FirebaseStorage.instance
          .ref()
          .child(_storageComicsPath)
          .child(comicId)
          .child(chapterId);

      String? resultMusicUrl;
      if (musicBytes != null && musicBytes.isNotEmpty) {
        final musicRef = folderRef.child('music.mp3');
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
        await _putBytes(
          musicRef,
          Uint8List.fromList(musicBytes),
          'audio/mpeg',
        );
        final musicUrl = await softDeadline(
          musicRef.getDownloadURL(),
          deadline: _storageTimeout,
          onDeadline: () => throw StateError(
            'Getting music URL timed out. Check your connection.',
          ),
        );
        chapter['musicUrl'] = musicUrl;
        resultMusicUrl = musicUrl;
      }

      int newPageCount = (chapter['pageCount'] as num?)?.toInt() ?? 0;
      if (additionalImageBytesList != null && additionalImageBytesList.isNotEmpty) {
        for (var i = 0; i < additionalImageBytesList.length; i++) {
          final pageNum = newPageCount + i + 1;
          final pageRef = folderRef.child('$pageNum.jpeg');
          final bytes = additionalImageBytesList[i].isNotEmpty
              ? Uint8List.fromList(additionalImageBytesList[i])
              : Uint8List(0);
          await _putBytes(pageRef, bytes, 'image/jpeg');
        }
        newPageCount += additionalImageBytesList.length;
        chapter['pageCount'] = newPageCount;
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
