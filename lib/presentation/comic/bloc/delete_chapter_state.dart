sealed class DeleteChapterState {
  const DeleteChapterState();
}

final class DeleteChapterInitial extends DeleteChapterState {
  const DeleteChapterInitial();
}

final class DeleteChapterLoading extends DeleteChapterState {
  const DeleteChapterLoading();
}

final class DeleteChapterSuccess extends DeleteChapterState {
  const DeleteChapterSuccess();
}

final class DeleteChapterFailure extends DeleteChapterState {
  const DeleteChapterFailure(this.message);
  final String message;
}
