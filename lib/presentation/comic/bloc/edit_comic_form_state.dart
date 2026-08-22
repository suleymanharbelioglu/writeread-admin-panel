import 'package:writeread_admin_panel/domain/comic/entity/comic_content_type.dart';

class EditComicFormState {
  const EditComicFormState({
    this.isEditing = false,
    this.contentType = ComicContentType.comic,
    this.isFree = true,
    this.isSensitive = false,
    this.newImageBytes,
    this.validationError,
  });

  final bool isEditing;
  final String contentType;
  final bool isFree;
  final bool isSensitive;
  final List<int>? newImageBytes;
  final String? validationError;

  EditComicFormState copyWith({
    bool? isEditing,
    String? contentType,
    bool? isFree,
    bool? isSensitive,
    List<int>? newImageBytes,
    bool clearImage = false,
    String? validationError,
    bool clearValidation = false,
  }) {
    return EditComicFormState(
      isEditing: isEditing ?? this.isEditing,
      contentType: contentType ?? this.contentType,
      isFree: isFree ?? this.isFree,
      isSensitive: isSensitive ?? this.isSensitive,
      newImageBytes: clearImage ? null : (newImageBytes ?? this.newImageBytes),
      validationError:
          clearValidation ? null : (validationError ?? this.validationError),
    );
  }
}
