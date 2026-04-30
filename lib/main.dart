import 'package:flutter/material.dart';
import 'package:recruteur/screens/acceuil.dart';
import 'package:recruteur/theme/app_theme.dart';

void main() {
  // DioClient.init(); // Assuming DioClient has an init if needed, but current code uses a static final.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiploChain Recruteur',
      theme: AppTheme.lightTheme,
      home: const Acceuil(),
      debugShowCheckedModeBanner: false,
    );
  }
}
