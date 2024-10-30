import 'package:dynamic_bridge/global/env_manager.dart';
import 'package:dynamic_bridge/logic/photo_collector.dart';
import 'package:flutter/material.dart';

class DashboardLogic {

  String takePicture(){

    PhotoCollector photoCollector = PhotoCollector();
    photoCollector.initialize();
    return photoCollector.getPhoto();

  }

  List<Widget> dashboardCenterChildren(){

    List<Widget> children = [];
    children.add(
      const Text(
              'Dashboard',
              style: TextStyle(fontSize: 24),
            )
    );
    if(EnvManager.isDebugAndroidMode()){
      children.add(
        IconButton(onPressed: () { takePicture();}, 
            icon: const Icon(Icons.camera))
      );
    }

    return children;

  }

}