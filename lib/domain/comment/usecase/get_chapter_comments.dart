import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/comment/entity/comment.dart';
import 'package:writeread_admin_panel/domain/comment/repository/comment.dart';
import 'package:writeread_admin_panel/service_locator.dart';

class GetChapterCommentsParams {
  final String comicId;
  final String chapterId;

  const GetChapterCommentsParams({
    required this.comicId,
    required this.chapterId,
  });
}

class GetChapterCommentsUseCase
    implements
        UseCase<Either<String, List<CommentEntity>>, GetChapterCommentsParams> {
  @override
  Future<Either<String, List<CommentEntity>>> call({
    GetChapterCommentsParams? params,
  }) async {
    if (params == null) return const Left('Params required');
    if (params.comicId.trim().isEmpty) return const Left('Comic id required');
    if (params.chapterId.trim().isEmpty) {
      return const Left('Chapter id required');
    }
    return sl<CommentRepository>().getChapterComments(
      params.comicId.trim(),
      params.chapterId.trim(),
    );
  }
}

