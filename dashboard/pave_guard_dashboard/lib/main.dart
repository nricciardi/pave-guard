import 'package:admin/screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'constants.dart';
import 'controllers/menu_app_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() async {
  await dotenv.load();
  runApp(ChangeNotifierProvider(
      create: (context) => MenuAppController(),
      child: MyApp(),  // This should be the root widget
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pave Guard Dashboard',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => MenuAppController(),
          ),
        ],
        child: LoginScreen(),
      ),
    );
  }
}
