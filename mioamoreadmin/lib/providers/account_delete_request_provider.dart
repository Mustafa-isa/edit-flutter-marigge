import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/helpers/firebase_constants.dart';
import 'package:mioamoreadmin/models/account_delete_request_model.dart';
import 'package:mioamoreadmin/providers/devices_provider.dart';
import 'package:mioamoreadmin/providers/feeds_provider.dart';
import 'package:mioamoreadmin/providers/interactions_provider.dart';
import 'package:mioamoreadmin/providers/matches_provider.dart';
import 'package:mioamoreadmin/providers/notification_provider.dart';
import 'package:mioamoreadmin/providers/user_profiles_provider.dart';
import 'package:mioamoreadmin/providers/user_reports_provider.dart';
import 'package:mioamoreadmin/providers/user_verification_forms_provider.dart';

final accountDeleteRequestsProvider =
    FutureProvider<List<AccountDeleteRequestModel>>((ref) async {
  final collection = FirebaseFirestore.instance
      .collection(FirebaseConstants.accountDeleteRequestCollection);

  return collection.get().then((value) {
    return value.docs
        .map((e) => AccountDeleteRequestModel.fromMap(e.data()))
        .toList();
  });
});

class AccountDeleteRequestProvider {
  static Future<bool> deleteRequest(String userId) async {
    final collection = FirebaseFirestore.instance
        .collection(FirebaseConstants.accountDeleteRequestCollection);

    try {
      await collection.doc(userId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteUser(String userId) async {
    try {
      EasyLoading.show(status: "Deleting user devices...");
      await DevicesProvider.deleteDevices(userId);
      EasyLoading.show(status: "Deleting user feeds...");
      await FeedsProvider.deleteFeeds(userId);
      EasyLoading.show(status: "Deleting user notifications...");
      await NotificaitonProvider.deleteNotifications(userId);
      EasyLoading.show(status: "Deleting user reports...");
      await UserReportsProvider.deleteReports(userId);
      EasyLoading.show(status: "Deleting user interactions...");
      await InteractionsProvider.deleteInteractions(userId);
      EasyLoading.show(status: "Deleting user details...");
      await UserProfileProvider.deleteUser(userId);
      EasyLoading.show(status: "Deleting user verification form...");
      await VerificationProvider.deleteForm(userId);
      EasyLoading.show(status: "Deleting user matches and chats...");
      await MatchesProvider.deleteUserMatchesAndChats(userId);

      EasyLoading.dismiss();

      return true;
    } on Exception catch (e) {
      EasyLoading.dismiss();
      debugPrint(e.toString());
      return false;
    }
  }
}
