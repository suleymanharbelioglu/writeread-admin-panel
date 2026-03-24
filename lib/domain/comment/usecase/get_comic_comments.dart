import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/comment/entity/comment.dart';
import 'package:writeread_admin_panel/domain/comment/repository/comment.dart';
import 'package:writeread_admin_panel/service_locator.dart';

class GetComicCommentsUseCase
    implements UseCase<Either<String, List<CommentEntity>>, String> {
  @override
  Future<Either<String, List<CommentEntity>>> call({String? params}) async {
    if (params == null || params.trim().isEmpty) {
      return const Left('Comic id required');
    }
    return sl<CommentRepository>().getComicComments(params.trim());
  }
}

