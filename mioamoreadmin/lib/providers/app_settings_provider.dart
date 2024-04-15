import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/helpers/firebase_constants.dart';
import 'package:mioamoreadmin/models/app_settings_model.dart';

final appSettingsProvider = FutureProvider<AppSettingsModel?>((ref) async {
  final collection = FirebaseFirestore.instance
      .collection(FirebaseConstants.appSettingsCollection);
  final snapshot = await collection.get();
  if (snapshot.docs.isEmpty) {
    return null;
  }
  final doc = snapshot.docs.first;
  return AppSettingsModel.fromMap(doc.data());
});

class AppSettingsProvider {
  static Future<void> addAppSettings(AppSettingsModel appSettingsModel) async {
    final collection = FirebaseFirestore.instance
        .collection(FirebaseConstants.appSettingsCollection);
    await collection.doc("settings").set(appSettingsModel.toMap());
  }
}
