sealed class AddChapterState {
  const AddChapterState();
}

final class AddChapterInitial extends AddChapterState {
  const AddChapterInitial();
}

final class AddChapterLoading extends AddChapterState {
  const AddChapterLoading();
}

final class AddChapterSuccess extends AddChapterState {
  const AddChapterSuccess({
    required this.chapterName,
    required this.pageCount,
    this.isVip = true,
    this.musicUrl,
  });
  final String chapterName;
  final int pageCount;
  final bool isVip;
  /// Firebase Storage URL for chapter music when music was uploaded.
  final String? musicUrl;
}

final class AddChapterFailure extends AddChapterState {
  const AddChapterFailure(this.message);
  final String message;
}
