import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';

sealed class AddComicState {
  const AddComicState();
}

final class AddComicInitial extends AddComicState {
  const AddComicInitial();
}

final class AddComicLoading extends AddComicState {
  const AddComicLoading();
}

final class AddComicSuccess extends AddComicState {
  const AddComicSuccess({required this.comic});
  final ComicEntity comic;
}

final class AddComicFailure extends AddComicState {
  const AddComicFailure(this.message);
  final String message;
}
