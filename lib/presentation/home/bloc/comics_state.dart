import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';

sealed class ComicsState {
  const ComicsState();
}

final class ComicsInitial extends ComicsState {
  const ComicsInitial();
}

final class ComicsLoading extends ComicsState {
  const ComicsLoading();
}

final class ComicsSuccess extends ComicsState {
  const ComicsSuccess({required this.comics});
  final List<ComicEntity> comics;
}

final class ComicsError extends ComicsState {
  const ComicsError({required this.message});
  final String message;
}
