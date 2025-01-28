import 'package:admin/controllers/query_manager.dart';
import 'package:admin/screens/dashboard/components/header.dart';

import 'package:flutter/material.dart';

import '../../constants.dart';

class SettingsScreen extends StatelessWidget {

  SettingsScreen(this.data, {Key? key}) : super(key: key);

  final MeData data;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(data: data, title: "Settings"),
            SizedBox(height: defaultPadding),
            ListTile(
              leading: Icon(Icons.person, size: 30),
              title: Text('Account', style: TextStyle(fontSize: 18)),
              onTap: () {
              // Handle account settings tap
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications, size: 30),
              title: Text('Notifications', style: TextStyle(fontSize: 18)),
              onTap: () {
              // Handle notifications settings tap
              },
            ),
            ListTile(
              leading: Icon(Icons.lock, size: 30),
              title: Text('Privacy', style: TextStyle(fontSize: 18)),
              onTap: () {
              // Handle privacy settings tap
              },
            ),
            ListTile(
              leading: Icon(Icons.help, size: 30),
              title: Text('Help & Support', style: TextStyle(fontSize: 18)),
              onTap: () {
              // Handle help & support settings tap
              },
            ),
            SizedBox(height: defaultPadding),
        ]),
      ),
    );
  }
}
