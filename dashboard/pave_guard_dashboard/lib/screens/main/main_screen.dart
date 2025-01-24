import 'package:admin/controllers/query_manager.dart';
import 'package:admin/screens/login/login_screen.dart';
import 'package:admin/screens/planning/planning_screen.dart';
import 'package:admin/screens/profile/profile_screen.dart';
import 'package:admin/screens/settings/settings_screen.dart';
import 'package:admin/screens/statistics/stats_screen.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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

  Future<MeData> getMeData() async {
    final MeQueryManager meQueryManager = MeQueryManager();
    QueryResult result = await meQueryManager.sendQuery("", token: token);
    return meQueryManager.getMeData(result);
  }

  @override
  Widget build(BuildContext context) {
    // Ensure that the MenuAppController is ready before accessing the scaffoldKey
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ignore: unused_local_variable
      final MenuAppController menuAppController =
          context.read<MenuAppController>();
      // Any additional setup for MenuAppController, if necessary, can be done here
    });
    return FutureBuilder<MeData>(
      future: getMeData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return Scaffold(
            key: context
                .read<MenuAppController>()
                .scaffoldKey, // Access scaffoldKey safely after initialization
            drawer: SideMenu(),
            body: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // We want this side menu only for large screen
                  if (Responsive.isDesktop(context))
                    Expanded(
                      // it takes 1/6 part of the screen
                      child: SideMenu(),
                    ),
                  Expanded(
                    // It takes 5/6 part of the screen
                    flex: 5,
                    child: Consumer<MenuAppController>(
                        builder: (context, menuAppController, child) {
                      if (menuAppController.getScreen() ==
                          MenuState.dashboard) {
                        return DashboardScreen(snapshot.requireData);
                      } else if (menuAppController.getScreen() ==
                          MenuState.statistics) {
                        return StatsScreen(snapshot.requireData);
                      } else if (menuAppController.getScreen() ==
                          MenuState.planning) {
                        return PlanningScreen(snapshot.requireData);
                      } else if (menuAppController.getScreen() ==
                          MenuState.profile) {
                        return ProfileScreen(snapshot.requireData);
                      } else if (menuAppController.getScreen() ==
                          MenuState.settings) {
                        return SettingsScreen(snapshot.requireData);
                      } else if (menuAppController.getScreen() ==
                          MenuState.logout) {
                            context.read<MenuAppController>().delete();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                            (Route<dynamic> route) => false,
                          );
                        });
                        return Center(child: Text('Logging out...'));
                      } else {
                        return Center(child: Text('No data available'));
                      }
                    }),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(child: Text('No data available'));
        }
      },
    );
  }
}
