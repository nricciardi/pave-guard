import 'package:admin/controllers/query_manager.dart';
import 'package:admin/screens/dashboard/components/header.dart';

import '../../screens/dashboard/components/info_card.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';

class PlanningScreen extends StatelessWidget {

  PlanningScreen(this.data, {Key? key}) : super(key: key);

  final MeData data;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(data: data, title: "Planning"),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoCard(
                  title: "Ueeee",
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
