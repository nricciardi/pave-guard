import 'package:admin/controllers/query_manager.dart';
import 'package:admin/screens/dashboard/components/header.dart';

import 'package:flutter/material.dart';

import '../../constants.dart';

class ProfileScreen extends StatelessWidget {

  ProfileScreen(this.data, {Key? key}) : super(key: key);

  final MeData data;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(data: data, title: "Profile"),
            SizedBox(height: defaultPadding * 10),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Expanded(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                    radius: 75,
                    foregroundColor: Colors.white70,
                    ),
                    SizedBox(height: defaultPadding),
                    Text(
                    data.firstName + " " + data.lastName,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                    SizedBox(height: defaultPadding),
                    Text(
                    "E-mail: ${data.email}",
                    style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: defaultPadding),
                    Text(
                    "Since: ${data.createdAt}",
                    style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                  ),
                ),
                ],
              ),
            ),
        ]),
      ),
    );
  }
}
