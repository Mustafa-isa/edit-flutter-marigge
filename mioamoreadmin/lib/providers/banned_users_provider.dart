import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/helpers/firebase_constants.dart';
import 'package:mioamoreadmin/models/banned_user_model.dart';

final bannedUsersProvider = FutureProvider<List<BannedUserModel>>((ref) async {
  final bannedUsersCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.bannedUsersCollection);

  try {
    final bannedUsersDocs = await bannedUsersCollection.get();

    final bannedUsers = bannedUsersDocs.docs
        .map((doc) => BannedUserModel.fromMap(doc.data()))
        .toList();

    return bannedUsers;
  } catch (e) {
    debugPrint(e.toString());
    return [];
  }
});

class BanUserProvider {
  static Future<bool> banUser(BannedUserModel bannedUser) async {
    final bannedUsersCollection = FirebaseFirestore.instance
        .collection(FirebaseConstants.bannedUsersCollection);

    try {
      await bannedUsersCollection
          .doc(bannedUser.userId)
          .set(bannedUser.toMap());
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // Update
  static Future<bool> updateBanUser(BannedUserModel bannedUser) async {
    final bannedUsersCollection = FirebaseFirestore.instance
        .collection(FirebaseConstants.bannedUsersCollection);

    try {
      await bannedUsersCollection
          .doc(bannedUser.userId)
          .update(bannedUser.toMap());
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<bool> unbanUser(String userId) async {
    final bannedUsersCollection = FirebaseFirestore.instance
        .collection(FirebaseConstants.bannedUsersCollection);

    try {
      await bannedUsersCollection.doc(userId).delete();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
