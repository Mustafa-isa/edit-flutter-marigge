import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mioamoreadmin/helpers/firebase_constants.dart';

class FeedsProvider {
  static Future<bool> deleteFeeds(String userId) async {
    final collection = FirebaseFirestore.instance
        .collection(FirebaseConstants.feedsCollection);

    try {
      await collection.where('userId', isEqualTo: userId).get().then((value) {
        for (var element in value.docs) {
          element.reference.delete();
        }
      });

      final feedsImages =
          FirebaseStorage.instance.ref().child("feeds").child(userId);

      await feedsImages.listAll().then((value) {
        for (var element in value.items) {
          element.delete();
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}
