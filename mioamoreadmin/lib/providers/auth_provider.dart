import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
const firebaseConfig = FirebaseOptions(
    apiKey: "AIzaSyBg6ogm3JBLQFWJtoDOgZxmjl-x6r9MTGg",
    authDomain: "alkhattaba-7fc83.firebaseapp.com",
    databaseURL: "https://alkhattaba-7fc83-default-rtdb.firebaseio.com",
    projectId: "alkhattaba-7fc83",
    storageBucket: "alkhattaba-7fc83.appspot.com",
    messagingSenderId: "40112008725",
    appId: "1:40112008725:web:0332416b6e15237e85681c",
    measurementId: "G-NXKPJ1EB6S"
);

final authstateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((event) {
    ref.read(currentUserProvider.notifier).state = event;

    return event;
  });
});

final currentUserProvider = StateProvider<User?>((ref) {
  return null;
});

final isEmailVerifiedProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return false;
  }
  await user.reload();
  return user.emailVerified;
});

class AuthProvider {
  static Future<User?> loginWithEmailAndPass(
      {required String email, required String password}) async {
    try {
      EasyLoading.show(status: 'Logging in...');
      final user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      EasyLoading.dismiss();
      return user.user;
    } catch (e) {
      debugPrint(e.toString());

      String error = e.toString().split(']')[1].trim();
      EasyLoading.showError(error);
      return null;
    }
  }

  static Future<User?> registerWithEmailAndPass(
      {required String email, required String password}) async {
    try {
      EasyLoading.show(status: 'Registering...');
      final user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      EasyLoading.dismiss();
      return user.user;
    } catch (e) {
      debugPrint(e.toString());

      String error = e.toString().split(']')[1].trim();

      EasyLoading.showError(error);
      return null;
    }
  }

  static Future<User?> registerNewAdmin(
      {required String email, required String password}) async {
    try {
      EasyLoading.show(status: 'Registering...');

      final FirebaseApp newApp = await Firebase.initializeApp(
          name: 'Secondary', options: firebaseConfig);

      final firebaseAuthForSecondary = FirebaseAuth.instanceFor(app: newApp);

      final user = await firebaseAuthForSecondary
          .createUserWithEmailAndPassword(email: email, password: password);

      await newApp.delete();

      EasyLoading.dismiss();

      return user.user;
    } catch (e) {
      debugPrint(e.toString());

      String error = e.toString().split(']')[1].trim();

      EasyLoading.showError(error);
      return null;
    }
  }

  // Send email verification
  static Future<bool> sendEmailVerification(User user) async {
    try {
      EasyLoading.show(status: 'Sending email verification...');
      await user.sendEmailVerification();

      EasyLoading.dismiss();
      return true;
    } catch (e) {
      debugPrint(e.toString());

      String error = e.toString().split(']')[1].trim();

      EasyLoading.showError(error);
      return false;
    }
  }

  static Future<bool> forgotPassword({required String email}) async {
    try {
      EasyLoading.show(status: 'Sending reset password email...');
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      EasyLoading.showSuccess('Reset password link sent to $email');
      return true;
    } catch (e) {
      debugPrint(e.toString());

      String error = e.toString().split(']')[1].trim();

      EasyLoading.showError(error);
      return false;
    }
  }

  static Future<bool> verifyPassword({required String password}) async {
    try {
      EasyLoading.show(status: 'Verifying password...');
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || currentUser.email == null) {
        EasyLoading.showError('No user found');
        return false;
      } else {
        final credential = EmailAuthProvider.credential(
            email: currentUser.email!, password: password);

        return await currentUser
            .reauthenticateWithCredential(credential)
            .then((value) {
          EasyLoading.dismiss();
          return true;
        });
      }
    } catch (e) {
      debugPrint(e.toString());

      String error = e.toString().split(']')[1].trim();

      EasyLoading.showError(error);
      return false;
    }
  }

// Change email
  static Future<bool> changeEmail({required String email}) async {
    try {
      EasyLoading.show(status: 'Changing email...');
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        EasyLoading.showError('No user found');
        return false;
      } else {
        await currentUser.updateEmail(email);
        EasyLoading.showSuccess('Email changed to $email');
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());

      String error = e.toString().split(']')[1].trim();

      EasyLoading.showError(error);
      return false;
    }
  }

  // Change password

  static Future<bool> changePassword({required String password}) async {
    try {
      EasyLoading.show(status: 'Changing password...');
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        EasyLoading.showError('No user found');
        return false;
      } else {
        await currentUser.updatePassword(password);
        EasyLoading.showSuccess('Password changed');
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());

      String error = e.toString().split(']')[1].trim();

      EasyLoading.showError(error);
      return false;
    }
  }

  static Future<bool> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
