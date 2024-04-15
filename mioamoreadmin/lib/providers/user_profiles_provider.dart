import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/helpers/firebase_constants.dart';
import 'package:mioamoreadmin/models/user_profile_model.dart';

final userProfileProvider =
    FutureProvider.family<UserProfileModel, String>((ref, userId) async {
  final userProfileCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);
  final userProfileDoc = await userProfileCollection.doc(userId).get();
  final userProfileData = userProfileDoc.data();
  if (userProfileData != null) {
    return UserProfileModel.fromMap(userProfileData);
  } else {
    throw Exception('User profile not found!');
  }
});

final usersShortStreamProvider =
    StreamProvider<List<UserProfileShortModel>>((ref) {
  final usersCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);

  return usersCollection.snapshots().map((snapshot) => snapshot.docs
      .map((doc) => UserProfileShortModel.fromMap(doc.data()))
      .toList());
});

class UserProfileProvider {
  static Future<bool> verifyUser(String userId) async {
    final userProfileCollection = FirebaseFirestore.instance
        .collection(FirebaseConstants.userProfileCollection);

    try {
      await userProfileCollection.doc(userId).update({'isVerified': true});
      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // Add user profile
  static Future<bool> addUser(UserProfileModel userProfile) async {
    final userProfileCollection = FirebaseFirestore.instance
        .collection(FirebaseConstants.userProfileCollection);

    try {
      await userProfileCollection
          .doc(userProfile.userId)
          .set(userProfile.toMap());
      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  //delete user profile
  static Future<bool> deleteUser(String userId) async {
    final userProfileCollection = FirebaseFirestore.instance
        .collection(FirebaseConstants.userProfileCollection);

    try {
      await userProfileCollection.doc(userId).delete();

      final userProfilePicture = FirebaseStorage.instance
          .ref()
          .child("user_profile_pictures")
          .child(userId);
      await userProfilePicture.listAll().then((value) async {
        for (var item in value.items) {
          await item.delete();
        }
      });

      final userMediaFiles = FirebaseStorage.instance
          .ref()
          .child("user_media_files")
          .child(userId);
      await userMediaFiles.listAll().then((value) async {
        for (var item in value.items) {
          await item.delete();
        }
      });

      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
