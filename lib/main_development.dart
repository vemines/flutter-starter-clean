import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/flavor.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(apiKey: '', appId: '', messagingSenderId: '', projectId: ''),
  );

  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 3000);
  await FirebaseAuth.instance.useAuthEmulator('localhost', 3001);

  FlavorService.initialize(Flavor.dev);

  await init();

  runApp(const App());
}
