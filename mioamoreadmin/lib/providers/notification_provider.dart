import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mioamoreadmin/helpers/firebase_constants.dart';

class NotificaitonProvider {
  // Delete notification where userId = userId

  static Future<bool> deleteNotifications(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .get()
          .then((value) {
        for (var element in value.docs) {
          element.reference.delete();
        }
      });
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
