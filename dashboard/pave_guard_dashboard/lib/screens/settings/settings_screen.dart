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
            Center(),
            SizedBox(height: defaultPadding),
        ]),
      ),
    );
  }
}
