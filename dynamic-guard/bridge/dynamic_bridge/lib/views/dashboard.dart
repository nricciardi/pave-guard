import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.title});

  final String title;

  @override
  State<DashboardPage> createState() => _DashboardPageState();

}

class _DashboardPageState extends State<DashboardPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Builder(builder: (context) => 
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          )),
        ]
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
              leading: const Icon(Icons.home),
              title: const Text('Option 1'),
              onTap: () {
                Navigator.pop(context);
                // Implement option action
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Option 2'),
              onTap: () {
                Navigator.pop(context);
                // Implement option action
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Option 3'),
              onTap: () {
                Navigator.pop(context);
                // Implement option action
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}