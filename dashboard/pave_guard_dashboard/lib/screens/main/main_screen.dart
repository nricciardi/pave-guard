import '../../controllers/menu_app_controller.dart';
import '../../responsive.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/side_menu.dart';

class MainScreen extends StatelessWidget {
  // The token to pass for queries
  final String token;

  MainScreen({required this.token});
  @override
  Widget build(BuildContext context) {
    // Ensure that the MenuAppController is ready before accessing the scaffoldKey
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final menuAppController = context.read<MenuAppController>();
      // Any additional setup for MenuAppController, if necessary, can be done here
    });
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey, // Access scaffoldKey safely after initialization
      drawer: SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: DashboardScreen(),
            ),
          ],
        ),
      ),
    );
  }
}