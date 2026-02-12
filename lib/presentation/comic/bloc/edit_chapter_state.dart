sealed class EditChapterState {
  const EditChapterState();
}

final class EditChapterInitial extends EditChapterState {
  const EditChapterInitial();
}

final class EditChapterLoading extends EditChapterState {
  const EditChapterLoading({this.chapterId});
  final String? chapterId;
}

final class EditChapterSuccess extends EditChapterState {
  const EditChapterSuccess({
    required this.chapterId,
    this.isVip,
    this.addedImageCount,
  });
  final String chapterId;
  final bool? isVip;

  /// Number of images added (so UI can compute new pageCount = current + this).
  final int? addedImageCount;
}

final class EditChapterFailure extends EditChapterState {
  const EditChapterFailure(this.message);
  final String message;
}

final class EditChapterImagesDeleted extends EditChapterState {
  const EditChapterImagesDeleted({required this.chapterId});
  final String chapterId;
}
