import 'package:flutter/material.dart';
import 'auth/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'INSANI',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF457B42),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF457B42)),
      ),
      home: const LoginPage(),
    );
  }
}
