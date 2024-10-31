import 'package:dynamic_bridge/logic/views/settings_logic.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SettingsLogic selfLogic = SettingsLogic();

  @override
  Widget build(BuildContext context) {
    Future<Map<String, bool>> savedOptions = selfLogic.getSavedOptions();

    return FutureBuilder<Map<String, bool>>(
        future: savedOptions,
        builder:
            (BuildContext context, AsyncSnapshot<Map<String, bool>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Loading widget
          } else {
            int? _selectedOption = snapshot.data!["built-in"]! ? 1 : 2;
            bool _options2 = snapshot.data!["crock"]!;
            return Scaffold(
              appBar: AppBar(
                title: const Text('Settings'),
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // List of toggle options
                  Expanded(
                    child: ListView(
                      children: [
                        // First group of options
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Camera',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          title: const Text('Built-in'),
                          leading: Radio<int>(
                            value: 1,
                            groupValue: _selectedOption,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedOption = value;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text('Dynamic Guard'),
                          leading: Radio<int>(
                            value: 2,
                            groupValue: _selectedOption,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedOption = value;
                              });
                            },
                          ),
                        ),
                        const Divider(), // Divider between groups
                        // Second group of options
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Other',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          title: const Text('Crock'),
                          trailing: Checkbox(
                            value: _options2,
                            onChanged: (bool? value) {
                              setState(() {
                                _options2 = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Home button at the bottom
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Go back to the DashboardPage
                      },
                      child: const Text('Home'),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}