sealed class EditComicState {
  const EditComicState();
}

final class EditComicInitial extends EditComicState {
  const EditComicInitial();
}

final class EditComicLoading extends EditComicState {
  const EditComicLoading();
}

final class EditComicSuccess extends EditComicState {
  const EditComicSuccess();
}

final class EditComicFailure extends EditComicState {
  const EditComicFailure(this.message);
  final String message;
}
