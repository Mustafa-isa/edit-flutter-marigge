import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/helpers/firebase_constants.dart';
import 'package:mioamoreadmin/models/verification_form_model.dart';

final pendingVerificationFormsStreamProvider =
    StreamProvider<List<VerificationFormModel>>((ref) {
  final collection = FirebaseFirestore.instance
      .collection(FirebaseConstants.verificationFormsCollection);

  return collection
      .where("isPending", isEqualTo: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => VerificationFormModel.fromMap(doc.data()))
        .toList();
  });
});

class VerificationProvider {
  static Future<bool> updateForm(VerificationFormModel form) async {
    try {
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.verificationFormsCollection)
          .doc(form.id)
          .update(form.toMap());
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<bool> deleteForm(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.verificationFormsCollection)
          .doc(id)
          .delete();

      final imageStorage = FirebaseStorage.instance.ref().child(id);
      await imageStorage.listAll().then((value) {
        for (var element in value.items) {
          element.delete();
        }
      });

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
