import 'dart:async';

import 'package:dynamic_bridge/logic/user_data_manager.dart';
import 'package:dynamic_bridge/logic/views/dashboard_logic.dart';
import 'package:dynamic_bridge/views/devices.dart';
import 'package:dynamic_bridge/views/login.dart';
import 'package:dynamic_bridge/views/profile.dart';
import 'package:flutter/material.dart';
import './settings.dart';

class DashboardPage extends StatefulWidget {
  final MeData selfData;
  final DeviceData selfDevice;

  const DashboardPage(
      {super.key, required this.selfData, required this.selfDevice});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardLogic? selfLogic;
  List<Widget>? children;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    initializeChildren();
    initializeTimer();
  }

  Future<void> initializeChildren() async {
    selfLogic ??= DashboardLogic(widget.selfDevice);
    children = await selfLogic!.dashboardCenterChildren();
    selfLogic!.collectPhotos();
    setState(() {});
  }

  void initializeTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if(selfLogic!.shouldReload()){
        await initializeChildren();
        selfLogic!.collectAndSendTelemetries();
      }
    });
  }

  void delete() {
    selfLogic!.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (children == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
            builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                )),
        backgroundColor: Colors.blueAccent, // Set your desired color
        elevation: 4,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Options',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage(selfData: widget.selfData)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.router),
              title: const Text('Devices'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Devices(selfData: widget.selfData)),
                );
                delete();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                selfLogic!.logout();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
                delete();
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children!,
        ),
      ),
    );
  }
}
