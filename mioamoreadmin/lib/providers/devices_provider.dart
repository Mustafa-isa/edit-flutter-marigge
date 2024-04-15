import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/helpers/firebase_constants.dart';

final totalDevicesProvider = StreamProvider<int>((ref) {
  final collection = FirebaseFirestore.instance
      .collection(FirebaseConstants.deviceTokensCollection);

  return collection.snapshots().map((snapshot) {
    return snapshot.docs.length;
  });
});

class DevicesProvider {
  static Future<bool> deleteDevices(String userId) async {
    final collection = FirebaseFirestore.instance
        .collection(FirebaseConstants.deviceTokensCollection);

    try {
      await collection.where('userId', isEqualTo: userId).get().then((value) {
        for (DocumentSnapshot ds in value.docs) {
          ds.reference.delete();
        }
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
