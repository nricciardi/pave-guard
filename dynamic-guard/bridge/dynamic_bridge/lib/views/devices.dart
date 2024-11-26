import 'dart:developer';

import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:dynamic_bridge/logic/query_manager.dart';
import 'package:dynamic_bridge/logic/token_manager.dart';
import 'package:dynamic_bridge/logic/user_data_manager.dart';
import 'package:dynamic_bridge/views/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';

class DeviceLinkageData {
  String serialNumber;
  String userId;

  DeviceLinkageData(this.serialNumber, this.userId);

  String getSerialNumber() {
    return serialNumber;
  }

  String getUserId() {
    return userId;
  }
}

class DeviceData {
  String serialNumber;
  String id;
  String userId;
  String createdAt;

  DeviceData(this.serialNumber, this.id, this.userId, this.createdAt);

  String getSerialNumber() {
    return serialNumber;
  }

  String getId() {
    return id;
  }

  String getUserId() {
    return userId;
  }

  String getCreatedAt() {
    return createdAt;
  }
}

class Devices extends StatefulWidget {
  final MeData selfData;

  const Devices({super.key, required this.selfData});
  @override
  DevicesLinkedState createState() => DevicesLinkedState();
}

class DevicesLinkedState extends State<Devices> {
  List<DeviceData> devices = [];
  int? selectedDeviceIndex;
  MeData? selfData;

  @override
  void initState() {
    super.initState();
    loadDevices();
  }

  Future<void> loadDevices() async {
    selfData = selfData ?? await UserDataManager.getSelfData();
    String token = await TokenManager.getToken();
    DynamicGuardsGetQueryManager dynamicGuardsGetQueryManager =
        DynamicGuardsGetQueryManager();
    QueryResult queryResult =
        await dynamicGuardsGetQueryManager.sendQuery("", token: token);

    setState(() {
      devices = dynamicGuardsGetQueryManager.getDevicesList(queryResult);
    });
  }

  Future<void> addDevice(String serialNumber) async {
    DynamicGuardCreationQueryManager dynamicGuardCreationQueryManager =
        DynamicGuardCreationQueryManager();
    await dynamicGuardCreationQueryManager.sendQuery(
        DeviceLinkageData(serialNumber, selfData!.getId()),
        token: await TokenManager.getToken());
    await loadDevices();
  }

  // Show dialog to add a new device
  void _showAddDeviceDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Scan Device QR Code"),
            content: Scaffold(
                body: QRCodeDartScanView(
              scanInvertedQRCode: true,
              typeScan: TypeScan.live,
              onCapture: (value) async {
                if (EnvManager.isDebugAndroidMode()) {
                  log(value.text);
                }
                await addDevice(value.text);
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
                setState(() {});
              },
            )),
          );
        });
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
            title: Text(device.serialNumber),
            subtitle: Text(device.createdAt),
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
          if (selectedDeviceIndex != null)
            FloatingActionButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DashboardPage(
                      selfData: selfData!,
                      selfDevice: devices[selectedDeviceIndex!]),
                ));
              },
              child: const Icon(Icons.check),
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
