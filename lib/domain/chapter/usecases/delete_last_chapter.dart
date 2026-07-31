import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/chapter/repository/chapter_repository.dart';

class DeleteLastChapterUseCase
    implements UseCase<Either<String, void>, String> {
  DeleteLastChapterUseCase(this._chapterRepository);

  final ChapterRepository _chapterRepository;

  @override
  Future<Either<String, void>> call({String? params}) async {
    if (params == null || params.isEmpty) {
      return const Left('Comic id is required');
    }
    return _chapterRepository.deleteLastChapter(params);
  }
}
