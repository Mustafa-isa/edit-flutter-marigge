import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/helpers/firebase_constants.dart';
import 'package:mioamoreadmin/models/user_interaction_model.dart';

final totalInteractionsProvider =
    StreamProvider<List<UserInteractionModel>>((ref) {
  final collection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userInteractionCollection);

  return collection.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return UserInteractionModel.fromMap(doc.data());
    }).toList();
  });
});

class InteractionsProvider {
  static Future<bool> deleteInteractions(String userId) async {
    final collection = FirebaseFirestore.instance
        .collection(FirebaseConstants.userInteractionCollection);

    try {
      await collection.where('userId', isEqualTo: userId).get().then((value) {
        for (var element in value.docs) {
          collection.doc(element.id).delete();
        }
      });

      await collection
          .where('intractToUserId', isEqualTo: userId)
          .get()
          .then((value) {
        for (var element in value.docs) {
          collection.doc(element.id).delete();
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}
