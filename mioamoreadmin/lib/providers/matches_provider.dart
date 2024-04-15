import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/helpers/firebase_constants.dart';
import 'package:mioamoreadmin/models/match_model.dart';

final totalMatchesProvider = StreamProvider<List<MatchModel>>((ref) {
  final collection =
      FirebaseFirestore.instance.collection(FirebaseConstants.matchCollection);

  return collection.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return MatchModel.fromMap(doc.data());
    }).toList();
  });
});

class MatchesProvider {
  static deleteUserMatchesAndChats(String userId) async {
    final collection = FirebaseFirestore.instance
        .collection(FirebaseConstants.matchCollection);

    final matches =
        await collection.where('userIds', arrayContains: userId).get();

    for (var match in matches.docs) {
      final chatCollection = FirebaseFirestore.instance
          .collection(FirebaseConstants.matchCollection)
          .doc(match.id)
          .collection(FirebaseConstants.chatCollection);

      final chats = await chatCollection.get();

      for (var chat in chats.docs) {
        await chat.reference.delete();
      }

      final chatStorage =
          FirebaseStorage.instance.ref().child("chat").child(match.id);
      await chatStorage.listAll().then((value) {
        for (var element in value.items) {
          element.delete();
        }
      });

      await match.reference.delete();
    }
  }
}
