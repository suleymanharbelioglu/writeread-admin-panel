import 'package:file_picker/file_picker.dart';

/// Shared FilePicker helpers for presentation (bytes only; no business logic).
class AppFilePicker {
  AppFilePicker._();

  static Future<List<int>?> pickImageBytes() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final bytes = result.files.single.bytes;
    if (bytes == null || bytes.isEmpty) return null;
    return bytes.toList();
  }

  static Future<List<List<int>>> pickImageBytesList() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return const [];
    return result.files
        .where((f) => f.bytes != null && f.bytes!.isNotEmpty)
        .map((f) => f.bytes!.toList())
        .toList();
  }

  static Future<({List<int> bytes, String name})?> pickAudioBytes() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.single;
    if (file.bytes == null || file.bytes!.isEmpty) return null;
    return (bytes: file.bytes!.toList(), name: file.name);
  }
}
