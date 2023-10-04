import 'dart:developer';

import 'package:flutter/material.dart';

class DragController with ChangeNotifier {
  bool hasTwoFingers = false;
  String selectedAssetId = '';
  Offset position = Offset.zero;
  int fingerCount = 0;
  double scale = 0;

  void setTwoFingers(bool value) {
    if (hasTwoFingers == value) return;
    hasTwoFingers = value;
    notifyListeners();
  }

  bool onDrag(String currentId) {
    if (currentId == selectedAssetId) {
      return true;
    } else {
      return false;
    }
  }

  void setFingerCount(int value) {
    if (fingerCount == value) return;
    fingerCount = value;
    notifyListeners();
  }

  void setSelectedAssetId(String id) {
    selectedAssetId = id;
    log('setted to $id');
    notifyListeners();
  }

  void manageTapOutside() {
    if (fingerCount > 0) {
      setTwoFingers(true);
      log('two fingers');
    }
  }

  void setScale(double scale) {
    this.scale = scale;
    notifyListeners();
  }
}
