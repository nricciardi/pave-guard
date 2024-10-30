import 'package:flutter/material.dart';
import 'logic/views/main_logic.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load();
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