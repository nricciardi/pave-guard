import 'package:flutter/material.dart';

enum MenuState { dashboard, statistics, planning, profile, settings, logout }

class MenuAppController extends ChangeNotifier {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  MenuState _menuState = MenuState.dashboard;
  String _searchText = "";

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  void controlMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  void search(String text){
    _searchText = text;
    notifyListeners();
  }

  void refresh(){
    notifyListeners();
  }

  String getSearch(){
    String text = _searchText;
    _searchText = "";
    return text;
  }

  void setScreen(MenuState state){
    _searchText = "";
    _menuState = state;
    notifyListeners();
  }

  void logout(){
    _menuState = MenuState.logout;
    notifyListeners();
  }

  void delete(){
    _menuState = MenuState.dashboard;
  }

  MenuState getScreen(){
    return _menuState;
  }

}
