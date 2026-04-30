import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:recruteur/screens/acceuil.dart';
import 'package:recruteur/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiploChain Recruteur',
      theme: AppTheme.theme,
      home: const Acceuil(),
      debugShowCheckedModeBanner: false,
    );
  }
}
