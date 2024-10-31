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
  static Widget? home;

  Future<Widget> getHome() async{
    return await selfLogic.loadNextPage();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<Widget>(
      future: getHome(),
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Loading widget
        } else {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: snapshot.data,
          );
        }
      }
    );
    
  }
}