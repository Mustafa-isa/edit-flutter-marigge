import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/helpers/firebase_constants.dart';
import 'package:mioamoreadmin/models/report_model.dart';

final userReportsProvider =
    FutureProvider.family<List<ReportModel>, String>((ref, userId) async {
  final collection = FirebaseFirestore.instance
      .collection(FirebaseConstants.reportsCollection);

  return collection.where('reportingUserId', isEqualTo: userId).get().then(
      (value) => value.docs.map((e) => ReportModel.fromMap(e.data())).toList());
});

class UserReportsTogetherModel {
  final String userId;
  final int reportsCount;
  UserReportsTogetherModel({
    required this.userId,
    required this.reportsCount,
  });
}

final allReportsProvider =
    StreamProvider<List<UserReportsTogetherModel>>((ref) {
  final collection = FirebaseFirestore.instance
      .collection(FirebaseConstants.reportsCollection);

  return collection.snapshots().map((event) {
    final reports =
        event.docs.map((e) => ReportModel.fromMap(e.data())).toList();
    final users = reports.map((e) => e.reportingUserId).toSet().toList();
    final usersReports = users
        .map((e) => UserReportsTogetherModel(
              userId: e,
              reportsCount: reports
                  .where((element) => element.reportingUserId == e)
                  .length,
            ))
        .toList();
    return usersReports;
  });
});

class UserReportsProvider {
  static Future<bool> deleteReports(String userId) async {
    final collection = FirebaseFirestore.instance
        .collection(FirebaseConstants.reportsCollection);

    try {
      await collection
          .where('reportingUserId', isEqualTo: userId)
          .get()
          .then((value) {
        for (var element in value.docs) {
          element.reference.delete();
        }
      });

      final userReportsImages =
          FirebaseStorage.instance.ref().child("reports").child(userId);
      await userReportsImages.listAll().then((value) {
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
