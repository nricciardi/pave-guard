import 'dart:developer';
import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:dynamic_bridge/logic/gps_manager.dart';
import 'package:dynamic_bridge/logic/photo_collector.dart';
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
  int? _selectedOption2;
  bool? _isCameraOn;

  @override
  void initState() {
    super.initState();
    loadData(); // Start async initialization
  }

  Future<void> loadData() async {
    Map<String, bool> loadedOptions = await selfLogic.getSavedOptions();
    int? selectedOption = loadedOptions["built-inC"]! ? 1 : 2;
    int? selectedOption2 = loadedOptions["built-inG"]! ? 1 : 2;
    bool isCameraOn = false;
    bool isGpsOn = false;

    // Checking if camera is on!
    try {
      PhotoCollector photoCollector = PhotoCollector();
      photoCollector.initialize();
      photoCollector.close();
      isCameraOn = true;
    } catch (e) {
      if(EnvManager.isDebugAndroidMode()){
        log("Unable to open external camera!");
      }
    }

    isGpsOn = await GpsManager.isBuiltInGPSOn();
    if(!isGpsOn && EnvManager.isDebugAndroidMode()){
      log("The GPS is turned off!");
    }

    setState(() {
      _selectedOption = selectedOption;
      _selectedOption2 = selectedOption2;
      _isCameraOn = isCameraOn;
      // _isGpsOn = isGpsOn;
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        if (!_isCameraOn!) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Warning",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28)),
                                content: const Text(
                                    "Check the cable connection: no camera found!",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: const Text("OK",
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      });
                    },
                  ),
                ),
                const Divider(), // Divider between groups
                // Second group of options
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'GPS',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  title: const Text('Built-in'),
                  leading: Radio<int>(
                    value: 1,
                    groupValue: _selectedOption2,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedOption2 = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Dynamic Guard'),
                  leading: Radio<int>(
                    value: 2,
                    groupValue: _selectedOption2,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedOption2 = value;
                        /* if (false) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Warning",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28)),
                                content: const Text(
                                    "Check the cable connection: no camera found!",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: const Text("OK",
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          ); 
                        } */
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
                  "built-inC": _selectedOption == 1 ? true : false,
                  "externalC": _selectedOption == 2 ? true : false,
                  "built-inG": _selectedOption2 == 1 ? true : false,
                  "externalG": _selectedOption2 == 2 ? true : false,
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
