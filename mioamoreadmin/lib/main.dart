import 'package:firebase_core/firebase_core.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/config/config.dart';

import 'package:mioamoreadmin/helpers/config_loading.dart';
import 'package:mioamoreadmin/views/wrapper/landing_widget.dart';

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
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options:firebaseConfig,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    configLoading(
      isDarkMode: false,
      foregroundColor: Colors.white,
      backgroundColor: Colors.blue.dark,
    );

    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      home: const SuperAdminLandingWidget(),
      builder: EasyLoading.init(),
    );
  }
}
