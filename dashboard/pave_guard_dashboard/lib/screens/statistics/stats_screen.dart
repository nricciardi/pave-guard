import 'package:admin/constants.dart';
import 'package:admin/controllers/query_manager.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:admin/screens/dashboard/components/info_card.dart';
import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {

  StatsScreen(this.data, {Key? key}) : super(key: key);

  final MeData data;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(data: data, title: "Statistics"),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoCard(
                  title: "Marco",
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