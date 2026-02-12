/// VIP and image add/delete are independent: isVip only changes the chapter
/// property; add/delete images work the same for VIP and non-VIP.
class UpdateChapterParams {
  const UpdateChapterParams({
    required this.comicId,
    required this.chapterId,
    this.isVip,
    this.additionalImageBytesList,
  });

  final String comicId;
  final String chapterId;
  final bool? isVip;
  final List<List<int>>? additionalImageBytesList;
}
