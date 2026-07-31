class EditComicFormState {
  const EditComicFormState({
    this.isEditing = false,
    this.isFree = true,
    this.isSensitive = false,
    this.newImageBytes,
    this.validationError,
  });

  final bool isEditing;
  final bool isFree;
  final bool isSensitive;
  final List<int>? newImageBytes;
  final String? validationError;

  EditComicFormState copyWith({
    bool? isEditing,
    bool? isFree,
    bool? isSensitive,
    List<int>? newImageBytes,
    bool clearImage = false,
    String? validationError,
    bool clearValidation = false,
  }) {
    return EditComicFormState(
      isEditing: isEditing ?? this.isEditing,
      isFree: isFree ?? this.isFree,
      isSensitive: isSensitive ?? this.isSensitive,
      newImageBytes: clearImage ? null : (newImageBytes ?? this.newImageBytes),
      validationError:
          clearValidation ? null : (validationError ?? this.validationError),
    );
  }
}
