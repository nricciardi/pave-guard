import 'package:dynamic_bridge/logic/query_manager.dart';
import 'package:dynamic_bridge/logic/token_manager.dart';
import 'package:dynamic_bridge/views/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class DeviceLinkageData {

  String serialNumber;
  String id;

  DeviceLinkageData(this.serialNumber, this.id);

  String getSerialNumber(){ return serialNumber; }
  String getId(){ return id; }

}

class Devices extends StatefulWidget {
  const Devices({super.key});
  @override
  DevicesLinkedState createState() => DevicesLinkedState();
}

class DevicesLinkedState extends State<Devices> {
  List<dynamic> devices = [];
  int? selectedDeviceIndex;

  @override
  void initState() {
    super.initState();
    loadDevices();
  }

  // Load and parse the JSON file
  Future<void> loadDevices() async {

    String token = await TokenManager.getToken();
    DynamicGuardsGetQueryManager dynamicGuardsGetQueryManager = DynamicGuardsGetQueryManager();
    QueryResult queryResult = await dynamicGuardsGetQueryManager.sendQuery("", token: token);

    setState(() {
      devices = queryResult.data!['devices'];
    });
  }

  // Show dialog to add a new device
  void _showAddDeviceDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController infoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Device'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Device Name'),
              ),
              TextField(
                controller: infoController,
                decoration: const InputDecoration(labelText: 'Device Info'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  devices.add({
                    'name': nameController.text,
                    'info': infoController.text,
                  });
                });
                Navigator.of(context).pop(); // Close the dialog
                setState(() {});
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices Linked'),
      ),
      body: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                final isSelected = index == selectedDeviceIndex;

                return ListTile(
                  title: Text(device['name']),
                  subtitle: Text(device['info']),
                  selected: isSelected,
                  onTap: () {
                    setState(() {
                      selectedDeviceIndex = isSelected ? null : index;
                    });
                  },
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (devices.isNotEmpty)
            FloatingActionButton.extended(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const DashboardPage(title: "Dashboard"),
        ));
              },
              label: const Text('Home'),
            ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _showAddDeviceDialog,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}