import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:writeread_admin_panel/core/constants/firestore_collections.dart';
import 'package:writeread_admin_panel/core/error/firebase_error_mapper.dart';
import 'package:writeread_admin_panel/core/firebase/firestore_write_helper.dart';
import 'package:writeread_admin_panel/core/firebase/soft_deadline.dart';
import 'package:writeread_admin_panel/data/comic/model/comic_model.dart';
import 'package:writeread_admin_panel/data/comic/source/comic_firebase_service.dart';

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
        onDeadline: () => throw StateError(
          'Cover upload timed out. Check your connection.',
        ),
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
        imageFilename = '${comicId}_cover.jpg';
        final uploadError = await _uploadCover(imageFilename, imageBytes);
        if (uploadError != null) return Left(uploadError);
      }

      final categoryTrimmed = categoryName.trim();
      final createdDate = DateTime.now().toUtc();
      // Use List<dynamic> (not List<Map>) — typed empty lists can break
      // Firestore JS interop on Flutter Web.
      final data = <String, dynamic>{
        'comicId': comicId,
        'title': title.trim(),
        'description': description.trim(),
        'image': imageFilename,
        'isSensitive': isSensitive,
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
          return Left(
            FirebaseErrorMapper.map(
              write.error!,
              action: 'Save comic',
            ),
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
            isFree: isFree,
            productId: productId.trim(),
            likeCount: 0,
            readCount: 0,
            chapterCount: 0,
            createdDate: createdDate,
            categoryId: categoryTrimmed,
            categoryName: categoryTrimmed,
            chapters: const [],
          ),
        );
      }
    } catch (e, stackTrace) {
      return Left(
        FirebaseErrorMapper.map(
          e,
          action: 'Add comic',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<String, ComicModel>> updateComic(
    String comicId, {
    required String title,
    required String description,
    required bool isSensitive,
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

      if (newImageBytes != null && newImageBytes.isNotEmpty) {
        if (oldImageFilename != null && oldImageFilename.isNotEmpty) {
          final oldRef = FirebaseStorage.instance
              .ref()
              .child(_storageComicsPath)
              .child(oldImageFilename);
          try {
            await oldRef.delete();
          } on FirebaseException catch (e) {
            if (e.code != 'object-not-found') {
              return Left(
                FirebaseErrorMapper.map(e, action: 'Delete old cover'),
              );
            }
          }
        }
        newImageFilename = '${comicId}_cover.jpg';
        final uploadError = await _uploadCover(newImageFilename, newImageBytes);
        if (uploadError != null) return Left(uploadError);
      }

      try {
        final write = await FirestoreWriteHelper.updateDocument(docRef, {
          'title': title.trim(),
          'description': description.trim(),
          'isSensitive': isSensitive,
          'isFree': isFree,
          'productId': productId.trim(),
          'image': ?newImageFilename,
        });
        if (!write.isSuccess) {
          return Left(
            FirebaseErrorMapper.map(
              write.error!,
              action: 'Update comic',
            ),
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

      await _deleteStorageFileIfExists(
        storageRef.child('${comicId}_cover.jpg'),
      );
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
}
