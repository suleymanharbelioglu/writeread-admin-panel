import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';

sealed class CurrentComicState {
  const CurrentComicState();
}

final class CurrentComicInitial extends CurrentComicState {
  const CurrentComicInitial();
}

final class CurrentComicSet extends CurrentComicState {
  const CurrentComicSet({required this.comic});
  final ComicEntity comic;
}
