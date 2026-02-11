import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/images/image_display.dart';
import 'package:writeread_admin_panel/domain/chapter/entity/chapter_entity.dart';

class ChapterImageAdressCubit extends Cubit<List<String>> {
  ChapterImageAdressCubit() : super([]);

  void loadChapterImages(ChapterEntity chapter) {
    emit(ImageDisplayHelper.generateChapterImageURLs(chapter));
  }

  void clear() {
    emit([]);
  }
}
