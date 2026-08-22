import 'package:writeread_admin_panel/domain/comic/entity/comic_content_type.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';

enum AddComicStatus { idle, loading, success, failure }

class AddComicState {
  const AddComicState({
    this.contentType = ComicContentType.comic,
    this.isFree = true,
    this.isSensitive = false,
    this.imageBytes,
    this.status = AddComicStatus.idle,
    this.errorMessage,
    this.comic,
  });

  final String contentType;
  final bool isFree;
  final bool isSensitive;
  final List<int>? imageBytes;
  final AddComicStatus status;
  final String? errorMessage;
  final ComicEntity? comic;

  bool get isLoading => status == AddComicStatus.loading;

  AddComicState copyWith({
    String? contentType,
    bool? isFree,
    bool? isSensitive,
    List<int>? imageBytes,
    bool clearImage = false,
    AddComicStatus? status,
    String? errorMessage,
    bool clearError = false,
    ComicEntity? comic,
    bool clearComic = false,
  }) {
    return AddComicState(
      contentType: contentType ?? this.contentType,
      isFree: isFree ?? this.isFree,
      isSensitive: isSensitive ?? this.isSensitive,
      imageBytes: clearImage ? null : (imageBytes ?? this.imageBytes),
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      comic: clearComic ? null : (comic ?? this.comic),
    );
  }
}
