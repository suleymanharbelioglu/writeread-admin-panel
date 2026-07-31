import 'package:writeread_admin_panel/domain/chapter/entity/chapter_entity.dart';

enum AddChapterStatus { idle, loading, success, failure }

class AddChapterState {
  const AddChapterState({
    this.comicId = '',
    this.comicIsFree = true,
    this.isFreePreview = false,
    this.imageBytesList = const [],
    this.musicBytes,
    this.musicFileName,
    this.status = AddChapterStatus.idle,
    this.errorMessage,
    this.successChapter,
  });

  final String comicId;
  final bool comicIsFree;
  final bool isFreePreview;
  final List<List<int>> imageBytesList;
  final List<int>? musicBytes;
  final String? musicFileName;
  final AddChapterStatus status;
  final String? errorMessage;
  final ChapterEntity? successChapter;

  bool get isLoading => status == AddChapterStatus.loading;
  bool get showFreePreviewToggle => !comicIsFree;
  int get imageCount => imageBytesList.length;

  AddChapterState copyWith({
    String? comicId,
    bool? comicIsFree,
    bool? isFreePreview,
    List<List<int>>? imageBytesList,
    List<int>? musicBytes,
    bool clearMusic = false,
    String? musicFileName,
    AddChapterStatus? status,
    String? errorMessage,
    bool clearError = false,
    ChapterEntity? successChapter,
    bool clearSuccess = false,
  }) {
    return AddChapterState(
      comicId: comicId ?? this.comicId,
      comicIsFree: comicIsFree ?? this.comicIsFree,
      isFreePreview: isFreePreview ?? this.isFreePreview,
      imageBytesList: imageBytesList ?? this.imageBytesList,
      musicBytes: clearMusic ? null : (musicBytes ?? this.musicBytes),
      musicFileName:
          clearMusic ? null : (musicFileName ?? this.musicFileName),
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successChapter:
          clearSuccess ? null : (successChapter ?? this.successChapter),
    );
  }
}
