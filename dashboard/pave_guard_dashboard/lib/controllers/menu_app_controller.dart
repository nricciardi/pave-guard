import 'package:flutter/material.dart';

enum MenuState { dashboard, statistics, planning, profile, settings }

class MenuAppController extends ChangeNotifier {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  MenuState _menuState = MenuState.dashboard;

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  void controlMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  void setScreen(MenuState state){
    _menuState = state;
    notifyListeners();
  }

  MenuState getScreen(){
    return _menuState;
  }

}
