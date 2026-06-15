import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final corPrimaria = Color(int.parse(AppConfig.corPrimaria.replaceAll('#', '0xFF')));
    final corFundo = Color(int.parse(AppConfig.corFundo.replaceAll('#', '0xFF')));
    return MaterialApp(
      title: AppConfig.nomeFarmacia,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: corPrimaria),
        scaffoldBackgroundColor: corFundo,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
    );
  }
}
