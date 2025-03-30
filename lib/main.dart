import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:macro_global_test_app/src/app.dart';
import 'package:macro_global_test_app/src/service/storage_service.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final isLoggedIn = await StorageService.isLoggedIn();
  runApp(MyApp(initialRoute: isLoggedIn ? '/login' : '/login')); // default route
}
