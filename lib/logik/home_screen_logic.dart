import 'package:flutter/material.dart';

class HomeScreenLogic {
  int selectedIndex = 0;

  // Methode zum Wechseln der Navigations-Tabs
  void onItemTapped(int index, StateSetter setStateCallback) {
    setStateCallback(() {
      selectedIndex = index;
    });
  }
}
