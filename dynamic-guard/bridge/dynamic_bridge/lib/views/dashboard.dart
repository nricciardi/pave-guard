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

  const DashboardPage({super.key, required this.selfData, required this.selfDevice});

  @override
  State<DashboardPage> createState() => _DashboardPageState();

}

class _DashboardPageState extends State<DashboardPage> {

  static DashboardLogic selfLogic = DashboardLogic();
  List<Widget>? children;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    initializeChildren();
    initializeTimer();
  }

  Future<void> initializeChildren() async{

    children = await selfLogic.dashboardCenterChildren();
    selfLogic.collectPhotos();
    setState(() {});

  }

  void initializeTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) async {await initializeChildren();});
  }

  void delete(){
    selfLogic.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {

    if(children == null){
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: Builder(builder: (context) => 
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ))
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
                  MaterialPageRoute(builder: (context) => ProfilePage(selfData: widget.selfData)),
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
                  MaterialPageRoute(builder: (context) => Devices(selfData: widget.selfData)),
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
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                selfLogic.logout();
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