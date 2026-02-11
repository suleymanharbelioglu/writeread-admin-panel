import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/data/comic/model/comic_model.dart';
import 'package:writeread_admin_panel/data/comic/source/comic_firebase_service.dart';

class ComicFirebaseServiceImpl extends ComicFirebaseService {
  static const String _comicsCollection = 'Comics';

  @override
  Future<Either<String, List<ComicModel>>> getAllComics() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_comicsCollection)
          .get();
      final list = snapshot.docs.map((doc) => _docToModel(doc)).toList();
      return Right(list);
    } catch (e) {
      return Left('Failed to load comics');
    }
  }

  ComicModel _docToModel(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data());
    data['comicId'] = doc.id;
    return ComicModel.fromMap(data);
  }
}
