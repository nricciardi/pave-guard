import 'package:flutter/material.dart';
import 'logic/main_logic.dart';

void main() {
  runApp(const MyApp());
}

/// The App class
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static MainAppLogic selfLogic = MainAppLogic();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: selfLogic.loadNextPage(),
    );
  }
}