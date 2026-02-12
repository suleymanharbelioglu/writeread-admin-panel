import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/chapter/repository/chapter.dart';
import 'package:writeread_admin_panel/service_locator.dart';

class DeleteLastChapterUseCase implements UseCase<Either<String, void>, String> {
  @override
  Future<Either<String, void>> call({String? params}) async {
    if (params == null || params.isEmpty) {
      return const Left('Comic id is required');
    }
    return sl<ChapterRepository>().deleteLastChapter(params);
  }
}
