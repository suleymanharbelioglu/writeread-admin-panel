import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/domain/chapter/entity/chapter_entity.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/current_comic_state.dart';

class CurrentComicCubit extends Cubit<CurrentComicState> {
  CurrentComicCubit({ComicEntity? initialComic})
      : super(
          initialComic != null
              ? CurrentComicSet(comic: initialComic)
              : const CurrentComicInitial(),
        );

  ComicEntity? get comicOrNull {
    final s = state;
    return s is CurrentComicSet ? s.comic : null;
  }

  void setComic(ComicEntity comic) {
    emit(CurrentComicSet(comic: comic));
  }

  void clear() {
    emit(const CurrentComicInitial());
  }

  void applyComicFields({
    String? title,
    String? description,
    String? image,
    bool? isSensitive,
    bool? isFree,
    String? productId,
  }) {
    final comic = comicOrNull;
    if (comic == null) return;
    emit(
      CurrentComicSet(
        comic: comic.copyWith(
          title: title,
          description: description,
          image: image,
          isSensitive: isSensitive,
          isFree: isFree,
          productId: productId,
        ),
      ),
    );
  }

  void upsertChapter(ChapterEntity chapter) {
    final comic = comicOrNull;
    if (comic == null) return;
    final chapters = List<ChapterEntity>.from(comic.chapters);
    final index = chapters.indexWhere((c) => c.chapterId == chapter.chapterId);
    if (index >= 0) {
      chapters[index] = chapter;
    } else {
      chapters.add(chapter);
    }
    emit(
      CurrentComicSet(
        comic: comic.copyWith(
          chapters: chapters,
          chapterCount: chapters.length,
        ),
      ),
    );
  }

  void applyChapterEdit({
    required String chapterId,
    bool? isFreePreview,
    int? addedImageCount,
    String? musicUrl,
  }) {
    final comic = comicOrNull;
    if (comic == null) return;
    final index = comic.chapters.indexWhere((c) => c.chapterId == chapterId);
    if (index < 0) return;
    final chapter = comic.chapters[index];
    upsertChapter(
      chapter.copyWith(
        pageCount: addedImageCount != null
            ? chapter.pageCount + addedImageCount
            : null,
        isFreePreview: isFreePreview,
        musicUrl: musicUrl,
      ),
    );
  }

  void clearChapterImages(String chapterId) {
    final comic = comicOrNull;
    if (comic == null) return;
    final index = comic.chapters.indexWhere((c) => c.chapterId == chapterId);
    if (index < 0) return;
    upsertChapter(comic.chapters[index].copyWith(pageCount: 0));
  }

  void appendChapter(ChapterEntity chapter) {
    upsertChapter(chapter);
  }

  void removeLastChapter() {
    final comic = comicOrNull;
    if (comic == null || comic.chapters.isEmpty) return;
    final chapters = comic.chapters.sublist(0, comic.chapters.length - 1);
    emit(
      CurrentComicSet(
        comic: comic.copyWith(
          chapters: chapters,
          chapterCount: chapters.length,
        ),
      ),
    );
  }
}
