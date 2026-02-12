sealed class DeleteComicState {
  const DeleteComicState();
}

final class DeleteComicInitial extends DeleteComicState {
  const DeleteComicInitial();
}

final class DeleteComicLoading extends DeleteComicState {
  const DeleteComicLoading();
}

final class DeleteComicSuccess extends DeleteComicState {
  const DeleteComicSuccess();
}

final class DeleteComicFailure extends DeleteComicState {
  const DeleteComicFailure(this.message);
  final String message;
}
