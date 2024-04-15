import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mioamoreadmin/helpers/firebase_constants.dart';
import 'package:mioamoreadmin/models/user_profile_model.dart';
import 'package:mioamoreadmin/providers/user_profiles_provider.dart';

class ResetDatabaseProvider {
  static Future<bool> start() async {
    try {
      final randomUsersJsonData =
          await rootBundle.loadString('assets/json/random_users.json');

      final randomUsersJson = jsonDecode(randomUsersJsonData) as List;

      final List<UserProfileModel> userProfiles = [];

      for (var element in randomUsersJson) {
        userProfiles.add(UserProfileModel.fromMap(element));
      }

      // Delete all user profiles
      final userProfileCollection = FirebaseFirestore.instance
          .collection(FirebaseConstants.userProfileCollection);

      await userProfileCollection.get().then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });

      // Delete all device tokens
      final deviceTokenCollection = FirebaseFirestore.instance
          .collection(FirebaseConstants.deviceTokensCollection);

      await deviceTokenCollection.get().then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });

      // Delete all interactions
      final interactionsCollection = FirebaseFirestore.instance
          .collection(FirebaseConstants.userInteractionCollection);

      await interactionsCollection.get().then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });

      // Delete all matches
      final matchesCollection = FirebaseFirestore.instance
          .collection(FirebaseConstants.matchCollection);

      await matchesCollection.get().then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });

      // Delete all feeds

      final feedsCollection = FirebaseFirestore.instance
          .collection(FirebaseConstants.feedsCollection);

      await feedsCollection.get().then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });

      // Delete all reports

      final reportsCollection = FirebaseFirestore.instance
          .collection(FirebaseConstants.reportsCollection);

      await reportsCollection.get().then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });

      // Delete all blocked users

      final blockedUsersCollection = FirebaseFirestore.instance
          .collection(FirebaseConstants.blockedUsersCollection);

      await blockedUsersCollection.get().then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });

      // Delete all account delete requests

      final accountDeleteRequestsCollection = FirebaseFirestore.instance
          .collection(FirebaseConstants.accountDeleteRequestCollection);

      await accountDeleteRequestsCollection.get().then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });

      // Delete all notifications

      final notificationsCollection = FirebaseFirestore.instance
          .collection(FirebaseConstants.notificationsCollection);

      await notificationsCollection.get().then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });

      // delete all verification forms

      final verificationFormsCollection = FirebaseFirestore.instance
          .collection(FirebaseConstants.verificationFormsCollection);

      await verificationFormsCollection.get().then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });

      for (var userProfile in userProfiles) {
        await UserProfileProvider.addUser(userProfile);
      }
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
