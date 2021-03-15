import 'dart:ui';

import 'package:flutter/material.dart';

import 'storage.dart';
import 'level.dart';

class LevelHistory {
  static const int maxLevel = Level.maxLevels;
  static const String incomplete = 'Incomplete';
  static const String complete = 'Done';
  static const String notStarted = 'New';
  static const String moreEffort = 'Incomplete';
  static const String levelHistoryKey = 'LevelHistory';
  static List<String> levelHistory;
  static void loadLevelHistory () async {
    print ('Reached loadLevelHistory');
    if (levelHistory == null) {
      await Storage.getStorage();
      levelHistory = Storage.storage.getStringList(levelHistoryKey);
      if (levelHistory == null) {
        levelHistory = [];
        for (int i = 0; i < maxLevel; i++) {
          levelHistory.add(notStarted);
        }
        await Storage.storage.setStringList(levelHistoryKey, levelHistory);
      }
    }
  }

  static Color testColor (String  testStatus) {
    return (testStatus == LevelHistory.complete) ? Colors.green :
    (testStatus == LevelHistory.notStarted) ? Colors.blue : Colors.yellowAccent;
  }

  static void clearLevelHistory()
  {
    levelHistory = [];
    for (int i = 0; i < maxLevel; i++) {
      levelHistory.add(notStarted);
    }
    Storage.storage.setStringList(levelHistoryKey, levelHistory);
  }

  static void updateLevelHistory(int levelNumber, String status) {
    print ('update request $levelNumber $status' );
    loadLevelHistory();
    levelHistory[levelNumber-1] = status;
    Storage.storage.setStringList(levelHistoryKey, levelHistory);
  }
}

// setState(() {
// LevelHistory.clearLevelHistory();
// Navigator.of(context, rootNavigator: true).pop();
// });

