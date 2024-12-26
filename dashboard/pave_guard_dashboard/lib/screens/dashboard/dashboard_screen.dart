import '../../screens/dashboard/components/info_card.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import 'components/header.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(),
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
