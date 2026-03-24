import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:writeread_admin_panel/data/comment/model/comment_model.dart';
import 'package:writeread_admin_panel/data/comment/source/comment_firebase_service.dart';

class CommentFirebaseServiceImpl extends CommentFirebaseService {
  static const int _commentLimit = 50;

  static const String _comicCommentsCol = 'ComicComments';
  static const String _chapterCommentsCol = 'ChapterComments';

  CollectionReference<Map<String, dynamic>> _col(bool isChapter) =>
      FirebaseFirestore.instance.collection(
        isChapter ? _chapterCommentsCol : _comicCommentsCol,
      );

  @override
  Future<Either<String, List<CommentModel>>> getComicComments(
    String comicId,
  ) async {
    try {
      final snap = await _col(false)
          .where('comicId', isEqualTo: comicId)
          .orderBy('createdAt', descending: true)
          .limit(_commentLimit)
          .get();

      return Right(
        snap.docs.map((d) => CommentModel.fromMap(d.data())).toList(),
      );
    } on FirebaseException catch (e) {
      debugPrint('Get comic comments FirebaseException: ${e.code} ${e.message}');
      return Left('Failed to load comments: ${e.message ?? e.code}');
    } catch (e) {
      debugPrint('Get comic comments error: $e');
      return Left('Failed to load comments: $e');
    }
  }

  @override
  Future<Either<String, List<CommentModel>>> getChapterComments(
    String comicId,
    String chapterId,
  ) async {
    try {
      final snap = await _col(true)
          .where('chapterId', isEqualTo: chapterId)
          .orderBy('createdAt', descending: true)
          .limit(_commentLimit)
          .get();

      return Right(
        snap.docs.map((d) => CommentModel.fromMap(d.data())).toList(),
      );
    } on FirebaseException catch (e) {
      debugPrint(
        'Get chapter comments FirebaseException: ${e.code} ${e.message}',
      );
      return Left('Failed to load comments: ${e.message ?? e.code}');
    } catch (e) {
      debugPrint('Get chapter comments error: $e');
      return Left('Failed to load comments: $e');
    }
  }

  @override
  Future<Either<String, void>> deleteComment({
    required String commentId,
    required bool isChapterComment,
  }) async {
    try {
      await _col(isChapterComment).doc(commentId).delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      debugPrint('Delete comment FirebaseException: ${e.code} ${e.message}');
      return Left('Delete failed: ${e.message ?? e.code}');
    } catch (e) {
      debugPrint('Delete comment error: $e');
      return Left('Delete failed: $e');
    }
  }
}

