import 'package:admin/controllers/query_manager.dart';

import '../../screens/dashboard/components/info_card.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import 'components/header.dart';

class DashboardScreen extends StatelessWidget {

  DashboardScreen(this.data, {Key? key}) : super(key: key);

  final MeData data;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(data: data, title: "Dashboard"),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoCard(
                  title: "Test",
                  value: "42"
                )
              ],
            ),
            SizedBox(height: defaultPadding),
            // TODO: map
          ],
        ),
      ),
    );
  }
}
