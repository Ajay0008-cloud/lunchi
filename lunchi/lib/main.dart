import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'intro_page.dart'; // ✅ Import your intro page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lunchify App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const IntroPage(), // ✅ Show splash screen first
    );
  }
}


