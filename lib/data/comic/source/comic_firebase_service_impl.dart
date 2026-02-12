import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:writeread_admin_panel/data/comic/model/comic_model.dart';
import 'package:writeread_admin_panel/data/comic/source/comic_firebase_service.dart';

class ComicFirebaseServiceImpl extends ComicFirebaseService {
  static const String _comicsCollection = 'Comics';
  static const String _storageComicsPath = 'Comics';

  /// Set to true to temporarily skip Storage upload (debug freeze).
  static const bool _skipStorageUploadForDebug = false;

  /// Runs [fn] on the platform (main) thread to avoid Firebase plugin
  /// "non-platform thread" crashes on Windows/desktop/web.
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

  static const int _maxComicIdLength = 1500;

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

  @override
  Future<Either<String, ComicModel>> addComic(
    String title,
    String description,
    String categoryName, {
    List<int>? imageBytes,
  }) async {
    try {
      final colRef = FirebaseFirestore.instance.collection(_comicsCollection);
      String baseId = _titleToComicId(title);
      if (baseId.isEmpty) baseId = 'comic';
      String comicId = baseId;
      int suffix = 0;
      while (true) {
        final id = suffix == 0 ? comicId : '${comicId}_$suffix';
        final doc = await colRef.doc(id).get();
        if (!doc.exists) {
          comicId = id;
          break;
        }
        suffix++;
      }
      final docRef = colRef.doc(comicId);

      String imageFilename = '';
      if (!_skipStorageUploadForDebug &&
          imageBytes != null &&
          imageBytes.isNotEmpty) {
        imageFilename = '${comicId}_cover.jpg';
        final ref = FirebaseStorage.instance
            .ref()
            .child(_storageComicsPath)
            .child(imageFilename);
        try {
          print('UPLOAD START');
          await ref.putData(
            Uint8List.fromList(imageBytes),
            SettableMetadata(contentType: 'image/jpeg'),
          );
          print('UPLOAD DONE');
        } catch (e, stackTrace) {
          print('UPLOAD FAILED: $e');
          print(stackTrace);
          return Left('Storage upload failed: $e');
        }
      }

      final categoryTrimmed = categoryName.trim();
      final now = Timestamp.now();
      final data = <String, dynamic>{
        'title': title.trim(),
        'description': description.trim(),
        'image': imageFilename,
        'likeCount': 0,
        'readCount': 0,
        'chapterCount': 0,
        'createdDate': now,
        'categoryId': categoryTrimmed.isEmpty ? '' : categoryTrimmed,
        'categoryName': categoryTrimmed,
        'chapters': [],
      };
      print('SET START');
      await _runOnPlatformThread(() => docRef.set(data));
      print('SET DONE');

      print('MODEL BUILD START');
      final forModel = Map<String, dynamic>.from(data);
      forModel['comicId'] = comicId;
      final model = ComicModel.fromMap(forModel);
      print('MODEL BUILD DONE');
      return Right(model);
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('Add comic FirebaseException: ${e.code} – ${e.message ?? e}');
      debugPrint(stackTrace.toString());
      return Left('Add comic failed: ${e.code} – ${e.message ?? e.toString()}');
    } catch (e, stackTrace) {
      debugPrint('Add comic error: $e');
      debugPrint(stackTrace.toString());
      return Left('Failed to add comic: $e');
    }
  }

  @override
  Future<Either<String, void>> updateComic(
    String comicId, {
    required String title,
    required String description,
    String? oldImageFilename,
    List<int>? newImageBytes,
  }) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(_comicsCollection)
          .doc(comicId);
      String? newImageFilename;
      if (newImageBytes != null && newImageBytes.isNotEmpty) {
        if (oldImageFilename != null && oldImageFilename.isNotEmpty) {
          final oldRef = FirebaseStorage.instance
              .ref()
              .child(_storageComicsPath)
              .child(oldImageFilename);
          try {
            await oldRef.delete();
          } on FirebaseException catch (_) {}
        }
        newImageFilename = '${comicId}_cover.jpg';
        final newRef = FirebaseStorage.instance
            .ref()
            .child(_storageComicsPath)
            .child(newImageFilename);
        await newRef.putData(
          Uint8List.fromList(newImageBytes),
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }
      await docRef.update({
        'title': title.trim(),
        'description': description.trim(),
        if (newImageFilename != null) 'image': newImageFilename,
      });
      return const Right(null);
    } on FirebaseException catch (e, stackTrace) {
      print('Update comic FirebaseException: ${e.code} – ${e.message ?? e}');
      print(stackTrace);
      return Left('Update failed: ${e.code} – ${e.message ?? e.toString()}');
    } catch (e, stackTrace) {
      print('Update comic error: $e');
      print(stackTrace);
      return Left('Failed to update comic: $e');
    }
  }

  Future<void> _deleteStorageFileIfExists(Reference ref) async {
    try {
      await ref.delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }

  /// Deletes the comic: comic image and chapter folder on Storage, and Comics/{comicId} doc on database.
  /// Aligned with [ImageDisplayHelper]:
  /// - Comic image URL → Storage: Comics/{image filename}. Delete that file.
  /// - Chapter image URLs → Storage: Comics/{comicId}/{chapterId}/... . Delete folder Comics/{comicId}/.
  /// - Database: Comics/{comicId} document. Delete it.
  @override
  Future<Either<String, void>> deleteComic(String comicId) async {
    try {
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
          final map = ch is Map<String, dynamic> ? ch : null;
          final chapterId = map?['chapterId'] as String?;
          if (chapterId != null && chapterId.isNotEmpty) {
            final chapterFolderRef = storageRef.child(comicId).child(chapterId);
            try {
              await _deleteStorageFolderRecursively(chapterFolderRef);
            } on FirebaseException catch (e) {
              if (e.code != 'object-not-found') rethrow;
            }
          }
        }
      }

      await _deleteStorageFileIfExists(
        storageRef.child('${comicId}_cover.jpg'),
      );
      await _deleteStorageFileIfExists(storageRef.child('$comicId.jpg'));
      await _deleteStorageFileIfExists(storageRef.child('$comicId.jpeg'));

      final comicFolderRef = storageRef.child(comicId);
      try {
        await _deleteStorageFolderRecursively(comicFolderRef);
      } on FirebaseException catch (e) {
        if (e.code != 'object-not-found') rethrow;
      }

      await docRef.delete();
      return const Right(null);
    } on FirebaseException catch (e, stackTrace) {
      print('Delete comic FirebaseException: ${e.code} – ${e.message ?? e}');
      print(stackTrace);
      return Left('Delete failed: ${e.code} – ${e.message ?? e.toString()}');
    } catch (e, stackTrace) {
      print('Delete comic error: $e');
      print(stackTrace);
      return Left('Failed to delete comic: $e');
    }
  }

  @override
  Future<Either<String, List<ComicModel>>> getAllComics() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_comicsCollection)
          .get();
      final list = snapshot.docs.map((doc) => _docToModel(doc)).toList();
      return Right(list);
    } catch (e, stackTrace) {
      print('GetAllComics error: $e');
      print(stackTrace);
      return Left('Failed to load comics');
    }
  }

  ComicModel _docToModel(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data());
    data['comicId'] = doc.id;
    return ComicModel.fromMap(data);
  }
}
