import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/current_comic_state.dart';

class CurrentComicCubit extends Cubit<CurrentComicState> {
  CurrentComicCubit() : super(const CurrentComicInitial());

  void setComic(ComicEntity comic) {
    emit(CurrentComicSet(comic: comic));
  }

  void clear() {
    emit(const CurrentComicInitial());
  }
}
