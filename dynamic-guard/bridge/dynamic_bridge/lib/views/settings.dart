import 'package:dynamic_bridge/logic/views/settings_logic.dart';
import 'package:flutter/material.dart';

SettingsLogic selfLogic = SettingsLogic();

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  int? _selectedOption;
  bool _options2 = false;

  @override
  void initState() {
    super.initState();
    loadData(); // Start async initialization
  }

  Future<void> loadData() async {

    Map<String, bool> loadedOptions = await selfLogic.getSavedOptions();
    int? selectedOption = loadedOptions["built-in"]! ? 1 : 2;
    bool options2 = loadedOptions["crock"]!;
    setState(() {
      _selectedOption = selectedOption;
      _options2 = options2;
    });

  }

  @override
  Widget build(BuildContext context) {

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
                        selfLogic.saveOptions({
                          "built-in": _selectedOption == 1 ? true : false,
                          "external": _selectedOption == 2 ? true : false,
                          "crock": _options2,
                        });
                        Navigator.pop(context); // Go back to the DashboardPage
                      },
                      child: const Text('Home'),
                    ),
                  ),
                ],
              ),
            );
         } 
        }
