import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gge/firebase_options.dart';
import 'package:gge/screen/agentControl.dart';
import 'package:gge/screen/agentHome.dart';
import 'package:gge/screen/auth/signin.dart';
import 'package:gge/screen/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GGE',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor:Color.fromARGB(255, 2, 123, 139)),
        useMaterial3: true,
      ),
      home: SignInScreen(),
    );
  }
}
