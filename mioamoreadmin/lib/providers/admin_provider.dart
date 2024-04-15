import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/helpers/firebase_constants.dart';
import 'package:mioamoreadmin/models/admin_model.dart';
import 'package:mioamoreadmin/providers/auth_provider.dart';

class AdminProvider {
  // Add new admin
  static Future<bool> addAdmin({required AdminModel admin}) async {
    final adminCollection = FirebaseFirestore.instance
        .collection(FirebaseConstants.adminCollection);
    try {
      await adminCollection.doc(admin.id).set(admin.toMap());
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // Update admin
  static Future<bool> updateAdmin({required AdminModel admin}) async {
    final adminCollection = FirebaseFirestore.instance
        .collection(FirebaseConstants.adminCollection);
    try {
      await adminCollection.doc(admin.id).update(admin.toMap());
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // Delete admin
  static Future<bool> deleteAdmin({required String adminId}) async {
    final adminCollection = FirebaseFirestore.instance
        .collection(FirebaseConstants.adminCollection);
    try {
      await adminCollection.doc(adminId).delete();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}

final allAdminsProviderProvider = FutureProvider<List<AdminModel>>((ref) async {
  final adminCollection =
      FirebaseFirestore.instance.collection(FirebaseConstants.adminCollection);

  final adminSnapshot = await adminCollection.get();

  if (adminSnapshot.docs.isEmpty) {
    return [];
  } else {
    List<AdminModel> admins =
        adminSnapshot.docs.map((e) => AdminModel.fromMap(e.data())).toList();
    admins.removeWhere((element) => element.isSuperAdmin);
    admins.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return admins;
  }
});

final superAdminProvider = FutureProvider<AdminModel?>((ref) async {
  final adminCollection =
      FirebaseFirestore.instance.collection(FirebaseConstants.adminCollection);

  final adminSnapshot =
      await adminCollection.where('isSuperAdmin', isEqualTo: true).get();

  if (adminSnapshot.docs.isEmpty) {
    return null;
  } else {
    AdminModel admin = AdminModel.fromMap(adminSnapshot.docs.first.data());
    return admin;
  }
});

final isUserAdminProvider =
    FutureProvider.family<bool, String>((ref, userId) async {
  final adminCollection =
      FirebaseFirestore.instance.collection(FirebaseConstants.adminCollection);
  final adminSnapshot = await adminCollection.get();

  if (adminSnapshot.docs.isEmpty) {
    return false;
  } else {
    List<AdminModel> admins =
        adminSnapshot.docs.map((e) => AdminModel.fromMap(e.data())).toList();

    if (admins.any((element) => element.id == userId)) {
      return true;
    } else {
      return false;
    }
  }
});

final currentAdminProvider = FutureProvider<AdminModel?>((ref) async {
  final currentUserRef = ref.watch(currentUserProvider);

  if (currentUserRef == null) {
    return null;
  } else {
    final adminCollection = FirebaseFirestore.instance
        .collection(FirebaseConstants.adminCollection);

    final adminSnapshot = await adminCollection.doc(currentUserRef.uid).get();

    if (adminSnapshot.exists) {
      AdminModel admin = AdminModel.fromMap(adminSnapshot.data()!);
      return admin;
    } else {
      return null;
    }
  }
});
