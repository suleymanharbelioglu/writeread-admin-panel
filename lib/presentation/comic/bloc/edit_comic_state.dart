import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';

sealed class EditComicState {
  const EditComicState();
}

final class EditComicInitial extends EditComicState {
  const EditComicInitial();
}

final class EditComicLoading extends EditComicState {
  const EditComicLoading();
}

final class EditComicSuccess extends EditComicState {
  const EditComicSuccess({required this.comic});
  final ComicEntity comic;
}

final class EditComicFailure extends EditComicState {
  const EditComicFailure(this.message);
  final String message;
}
