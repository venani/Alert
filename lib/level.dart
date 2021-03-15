
import 'dart:math';

class Level
{
  static const double secsPerEvent = 5.0;
  static const int maxLevels = 42;

  static String getPuzzleComplexity (int levelNumber) {
    String complexity;
    switch (levelNumber) {
      case 01 : complexity = '2x2'; break;
      case 02 : complexity = '2x2'; break;
      case 03 : complexity = '2x2'; break;
      case 04 : complexity = '2x3'; break;
      case 05 : complexity = '2x3'; break;
      case 06 : complexity = '2x3'; break;
      case 07 : complexity = '2x4'; break;
      case 08 : complexity = '2x4'; break;
      case 09 : complexity = '2x4'; break;
      case 10 : complexity = '3x3'; break;
      case 11 : complexity = '3x3'; break;
      case 12 : complexity = '3x3'; break;
      case 13 : complexity = '2x5'; break;
      case 14 : complexity = '2x5'; break;
      case 15 : complexity = '2x5'; break;
      case 16 : complexity = '3x3'; break;
      case 17 : complexity = '3x3'; break;
      case 18 : complexity = '3x3'; break;
      case 19 : complexity = '3x4'; break;
      case 20 : complexity = '3x4'; break;
      case 21 : complexity = '3x4'; break;
      case 22 : complexity = '3x4'; break;
      case 23 : complexity = '3x4'; break;
      case 24 : complexity = '3x4'; break;
      case 25 : complexity = '4x4'; break;
      case 26 : complexity = '4x4'; break;
      case 27 : complexity = '4x4'; break;
      case 28 : complexity = '4x4'; break;
      case 29 : complexity = '4x4'; break;
      case 30 : complexity = '4x4'; break;
      case 31 : complexity = '5x4'; break;
      case 32 : complexity = '5x4'; break;
      case 33 : complexity = '5x4'; break;
      case 34 : complexity = '5x4'; break;
      case 35 : complexity = '5x4'; break;
      case 36 : complexity = '5x4'; break;
      case 37 : complexity = '5x5'; break;
      case 38 : complexity = '5x5'; break;
      case 39 : complexity = '5x5'; break;
      case 40 : complexity = '5x5'; break;
      case 41 : complexity = '5x5'; break;
      case 42 : complexity = '5x5'; break;
      default : complexity = '2x2';
    }
    return complexity;
  }


  static int getEventComplexity (int levelNumber) {
    int complexity;
    // List<String> temp = Level.getPuzzleComplexity(levelNumber).split('x');
    // double levelComplexity = getLevelComplexity(levelNumber);
    // String puzzleComplexity = getPuzzleComplexity(levelNumber);
    // int puzzleTime = getTestTime(levelNumber);
    // int eventComplexity = (levelComplexity*(puzzleTime/secsPerEvent)).toInt();
    switch (levelNumber) {
      case 01 : complexity = 8; break;
      case 02 : complexity = 9; break;
      case 03 : complexity = 10; break;
      case 04 : complexity = 12; break;
      case 05 : complexity = 13; break;
      case 06 : complexity = 14; break;
      case 07 : complexity = 15; break;
      case 08 : complexity = 16; break;
      case 09 : complexity = 17; break;
      case 10 : complexity = 18; break;
      case 11 : complexity = 19; break;
      case 12 : complexity = 20; break;
      case 13 : complexity = 21; break;
      case 14 : complexity = 22; break;
      case 15 : complexity = 23; break;
      case 16 : complexity = 24; break;
      case 17 : complexity = 25; break;
      case 18 : complexity = 26; break;
      case 19 : complexity = 27; break;
      case 20 : complexity = 28; break;
      case 21 : complexity = 29; break;
      case 22 : complexity = 30; break;
      case 23 : complexity = 31; break;
      case 24 : complexity = 32; break;
      case 25 : complexity = 33; break;
      case 26 : complexity = 34; break;
      case 27 : complexity = 35; break;
      case 28 : complexity = 36; break;
      case 29 : complexity = 37; break;
      case 30 : complexity = 38; break;
      case 31 : complexity = 39; break;
      case 32 : complexity = 40; break;
      case 33 : complexity = 41; break;
      case 34 : complexity = 42; break;
      case 35 : complexity = 43; break;
      case 36 : complexity = 44; break;
      case 37 : complexity = 45; break;
      case 38 : complexity = 46; break;
      case 39 : complexity = 47; break;
      case 40 : complexity = 48; break;
      case 41 : complexity = 49; break;
      case 42 : complexity = 50; break;
      default : complexity = 1;
    }
    return complexity;
  }

  static double getLevelComplexity (int levelNumber) {
    double complexity;
    switch (levelNumber) {
      case 01 : complexity = 1.00; break;
      case 02 : complexity = 1.05; break;
      case 03 : complexity = 1.10; break;
      case 04 : complexity = 1.15; break;
      case 05 : complexity = 1.20; break;
      case 06 : complexity = 1.25; break;
      case 07 : complexity = 1.00; break;
      case 08 : complexity = 1.05; break;
      case 09 : complexity = 1.10; break;
      case 10 : complexity = 1.15; break;
      case 11 : complexity = 1.20; break;
      case 12 : complexity = 1.25; break;
      case 13 : complexity = 1.00; break;
      case 14 : complexity = 1.05; break;
      case 15 : complexity = 1.10; break;
      case 16 : complexity = 1.15; break;
      case 17 : complexity = 1.20; break;
      case 18 : complexity = 1.25; break;
      case 19 : complexity = 1.00; break;
      case 20 : complexity = 1.05; break;
      case 21 : complexity = 1.10; break;
      case 22 : complexity = 1.15; break;
      case 23 : complexity = 1.20; break;
      case 24 : complexity = 1.25; break;
      case 25 : complexity = 1.00; break;
      case 26 : complexity = 1.05; break;
      case 27 : complexity = 1.10; break;
      case 28 : complexity = 1.15; break;
      case 29 : complexity = 1.20; break;
      case 30 : complexity = 1.25; break;
      case 31 : complexity = 1.00; break;
      case 32 : complexity = 1.05; break;
      case 33 : complexity = 1.10; break;
      case 34 : complexity = 1.15; break;
      case 35 : complexity = 1.20; break;
      case 36 : complexity = 1.25; break;
      case 37 : complexity = 1.00; break;
      case 38 : complexity = 1.05; break;
      case 39 : complexity = 1.10; break;
      case 40 : complexity = 1.15; break;
      case 41 : complexity = 1.20; break;
      case 42 : complexity = 1.25; break;
      default : complexity = 1;
    }
    return complexity;
  }

  static int getPuzzleComplexityTime (String puzzleComplexity) {
    int complexity;
    switch (puzzleComplexity) {
      case '2x2' : complexity = 30; break;
      case '2x3' : complexity = 40; break;
      case '2x4' : complexity = 50; break;
      case '2x5' : complexity = 60; break;
      case '3x3' : complexity = 75; break;
      case '3x4' : complexity = 90; break;
      case '3x5' : complexity = 100; break;
      case '3x5' : complexity = 120; break;
      case '4x4' : complexity = 130; break;
      case '4x5' : complexity = 140; break;
      case '5x4' : complexity = 140; break;
      case '5x5' : complexity = 150; break;
      default : complexity = 30;
    }
    return complexity;
  }

  static int getTestTime (int levelNumber) {
    int eventComplexity;
    List<String> complexity = Level.getPuzzleComplexity(levelNumber).split('x');
    int rows = int.parse(complexity[0]);
    int cols = int.parse(complexity[1]);
    int testTime = (getPuzzleComplexityTime(Level.getPuzzleComplexity(levelNumber)) + rows*cols + 10*getLevelComplexity(levelNumber)).toInt();
    return testTime;
  }

  static void printTestTime () {
    for (int i = 0; i < maxLevels; i++ ) {
      int testTime = getTestTime(i+1);
      List<String> complexity = Level.getPuzzleComplexity(i+1).split('x');
      int rows = int.parse(complexity[0]);
      int cols = int.parse(complexity[1]);
      print ('Level ${i+1} testTime $testTime $rows $cols ${getLevelComplexity(i+1)} ${getPuzzleComplexityTime(Level.getPuzzleComplexity(i+1))}');
    }
  }
}


