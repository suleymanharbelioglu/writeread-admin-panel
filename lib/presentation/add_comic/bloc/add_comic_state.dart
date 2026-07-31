import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';

enum AddComicStatus { idle, loading, success, failure }

class AddComicState {
  const AddComicState({
    this.isFree = true,
    this.isSensitive = false,
    this.imageBytes,
    this.status = AddComicStatus.idle,
    this.errorMessage,
    this.comic,
  });

  final bool isFree;
  final bool isSensitive;
  final List<int>? imageBytes;
  final AddComicStatus status;
  final String? errorMessage;
  final ComicEntity? comic;

  bool get isLoading => status == AddComicStatus.loading;

  AddComicState copyWith({
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
      isFree: isFree ?? this.isFree,
      isSensitive: isSensitive ?? this.isSensitive,
      imageBytes: clearImage ? null : (imageBytes ?? this.imageBytes),
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      comic: clearComic ? null : (comic ?? this.comic),
    );
  }
}
