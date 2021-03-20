
import 'dart:math';

class Level
{
  static const double secsPerEvent = 6.0;
  static const int maxLevels = 84;
  static const double timePerPiece = 22/4;

  static String getPuzzleComplexity (int levelNumber) {
    String complexity;
    switch (levelNumber) {
      case 01 : complexity = '2x2'; break;
      case 02 : complexity = '2x2'; break;
      case 03 : complexity = '2x2'; break;
      case 04 : complexity = '2x2'; break;
      case 05 : complexity = '2x2'; break;
      case 06 : complexity = '2x2'; break;
      case 07 : complexity = '2x3'; break;
      case 08 : complexity = '2x3'; break;
      case 09 : complexity = '2x3'; break;
      case 10 : complexity = '2x3'; break;
      case 11 : complexity = '2x3'; break;
      case 12 : complexity = '2x3'; break;
      case 13 : complexity = '2x4'; break;
      case 14 : complexity = '2x4'; break;
      case 15 : complexity = '2x4'; break;
      case 16 : complexity = '2x4'; break;
      case 17 : complexity = '2x4'; break;
      case 18 : complexity = '2x4'; break;
      case 19 : complexity = '3x3'; break;
      case 20 : complexity = '3x3'; break;
      case 21 : complexity = '3x3'; break;
      case 22 : complexity = '3x3'; break;
      case 23 : complexity = '3x3'; break;
      case 24 : complexity = '3x3'; break;
      case 25 : complexity = '2x5'; break;
      case 26 : complexity = '2x5'; break;
      case 27 : complexity = '2x5'; break;
      case 28 : complexity = '2x5'; break;
      case 29 : complexity = '2x5'; break;
      case 30 : complexity = '2x5'; break;
      case 31 : complexity = '2x6'; break;
      case 32 : complexity = '2x6'; break;
      case 33 : complexity = '2x6'; break;
      case 34 : complexity = '2x6'; break;
      case 35 : complexity = '2x6'; break;
      case 36 : complexity = '2x6'; break;
      case 37 : complexity = '3x4'; break;
      case 38 : complexity = '3x4'; break;
      case 39 : complexity = '3x4'; break;
      case 40 : complexity = '3x4'; break;
      case 41 : complexity = '3x4'; break;
      case 42 : complexity = '3x4'; break;
      case 43 : complexity = '3x5'; break;
      case 44 : complexity = '3x5'; break;
      case 45 : complexity = '3x5'; break;
      case 46 : complexity = '3x5'; break;
      case 47 : complexity = '3x5'; break;
      case 48 : complexity = '3x5'; break;
      case 49 : complexity = '4x4'; break;
      case 50 : complexity = '4x4'; break;
      case 51 : complexity = '4x4'; break;
      case 52 : complexity = '4x4'; break;
      case 53 : complexity = '4x4'; break;
      case 54 : complexity = '4x4'; break;
      case 55 : complexity = '3x6'; break;
      case 56 : complexity = '3x6'; break;
      case 57 : complexity = '3x6'; break;
      case 58 : complexity = '3x6'; break;
      case 59 : complexity = '3x6'; break;
      case 60 : complexity = '3x6'; break;
      case 61 : complexity = '5x4'; break;
      case 62 : complexity = '5x4'; break;
      case 63 : complexity = '5x4'; break;
      case 64 : complexity = '5x4'; break;
      case 65 : complexity = '5x4'; break;
      case 66 : complexity = '5x4'; break;
      case 67 : complexity = '6x4'; break;
      case 68 : complexity = '6x4'; break;
      case 69 : complexity = '6x4'; break;
      case 70 : complexity = '6x4'; break;
      case 71 : complexity = '6x4'; break;
      case 72 : complexity = '6x4'; break;
      case 73 : complexity = '5x5'; break;
      case 74 : complexity = '5x5'; break;
      case 75 : complexity = '5x5'; break;
      case 76 : complexity = '5x5'; break;
      case 77 : complexity = '5x5'; break;
      case 78 : complexity = '5x5'; break;
      case 79 : complexity = '6x5'; break;
      case 80 : complexity = '6x5'; break;
      case 81 : complexity = '6x5'; break;
      case 82 : complexity = '6x5'; break;
      case 83 : complexity = '6x5'; break;
      case 84 : complexity = '6x5'; break;
      default : complexity = '0x0';
    }
    return complexity;
  }


  static int getNumberOfEvents (int levelNumber) {
    int complexity;
    // int position = (levelNumber-1) % 6;
    // int basicTestTime = ((getBasicTestTime(levelNumber)/secsPerEvent)*(1.5 + position*.5/5)).toInt();
    // print ('level $levelNumber position $position basicTestTime $basicTestTime');
    // return basicTestTime;
    // List<String> temp = Level.getPuzzleComplexity(levelNumber).split('x');
    // double levelComplexity = getLevelComplexity(levelNumber);
    // String puzzleComplexity = getPuzzleComplexity(levelNumber);
    // int puzzleTime = getTestTime(levelNumber);
    // int eventComplexity = (levelComplexity*(puzzleTime/secsPerEvent)).toInt();
     switch (levelNumber) {
      case 01 : complexity = 05; break;
      case 02 : complexity = 06; break;
      case 03 : complexity = 07; break;
      case 04 : complexity = 08; break;
      case 05 : complexity = 09; break;
      case 06 : complexity = 10; break;
      case 07 : complexity = 08; break;
      case 08 : complexity = 09; break;
      case 09 : complexity = 10; break;
      case 10 : complexity = 11; break;
      case 11 : complexity = 12; break;
      case 12 : complexity = 13; break;
      case 13 : complexity = 11; break;
      case 14 : complexity = 12; break;
      case 15 : complexity = 13; break;
      case 16 : complexity = 14; break;
      case 17 : complexity = 15; break;
      case 18 : complexity = 16; break;
      case 19 : complexity = 14; break;
      case 20 : complexity = 15; break;
      case 21 : complexity = 16; break;
      case 22 : complexity = 17; break;
      case 23 : complexity = 18; break;
      case 24 : complexity = 19; break;
      case 25 : complexity = 17; break;
      case 26 : complexity = 18; break;
      case 27 : complexity = 19; break;
      case 28 : complexity = 20; break;
      case 29 : complexity = 21; break;
      case 30 : complexity = 22; break;
      case 31 : complexity = 20; break;
      case 32 : complexity = 21; break;
      case 33 : complexity = 22; break;
      case 34 : complexity = 23; break;
      case 35 : complexity = 24; break;
      case 36 : complexity = 25; break;
      case 37 : complexity = 24; break;
      case 38 : complexity = 25; break;
      case 39 : complexity = 26; break;
      case 40 : complexity = 27; break;
      case 41 : complexity = 28; break;
      case 42 : complexity = 29; break;
       case 43 : complexity = 27; break;
       case 44 : complexity = 28; break;
       case 45 : complexity = 29; break;
       case 46 : complexity = 30; break;
       case 47 : complexity = 31; break;
       case 48 : complexity = 32; break;
       case 49 : complexity = 30; break;
       case 50 : complexity = 31; break;
       case 51 : complexity = 32; break;
       case 52 : complexity = 33; break;
       case 53 : complexity = 34; break;
       case 54 : complexity = 35; break;
       case 55 : complexity = 36; break;
       case 56 : complexity = 37; break;
       case 57 : complexity = 38; break;
       case 58 : complexity = 36; break;
       case 59 : complexity = 37; break;
       case 60 : complexity = 38; break;
       case 61 : complexity = 39; break;
       case 62 : complexity = 40; break;
       case 63 : complexity = 41; break;
       case 64 : complexity = 39; break;
       case 65 : complexity = 40; break;
       case 66 : complexity = 41; break;
       case 67 : complexity = 42; break;
       case 68 : complexity = 43; break;
       case 69 : complexity = 44; break;
       case 70 : complexity = 42; break;
       case 71 : complexity = 43; break;
       case 72 : complexity = 44; break;
       case 73 : complexity = 45; break;
       case 74 : complexity = 46; break;
       case 75 : complexity = 47; break;
       case 76 : complexity = 45; break;
       case 77 : complexity = 46; break;
       case 78 : complexity = 47; break;
       case 79 : complexity = 48; break;
       case 80 : complexity = 49; break;
       case 81 : complexity = 50; break;
       case 82 : complexity = 49; break;
       case 83 : complexity = 50; break;
       case 84 : complexity = 51; break;
      default : complexity = 52;
    }
    return complexity;
  }

  static double getTestComplexity (int levelNumber) {
    double testComplexity = (((levelNumber-1) % 6))*0.05 + 1.00;
    print ('Levelnumber is $levelNumber Test complexity is $testComplexity');
    return testComplexity;
/*    double complexity;
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
 */
  }

  static int getPuzzleComplexityTime (String puzzleComplexity) {
    return (getNumberOfPieces(puzzleComplexity)*timePerPiece).toInt();
/*
    switch (puzzleComplexity) {
      case '2x2' : complexity = 30; break;
      case '2x3' : complexity = 40; break;
      case '2x4' : complexity = 50; break;
      case '3x3' : complexity = 60; break;
      case '2x5' : complexity = 70; break;
      case '2x6' : complexity = 80; break;
      case '3x4' : complexity = 80; break;
      case '3x5' : complexity = 100; break;
      case '3x6' : complexity = 120; break;
      case '4x4' : complexity = 130; break;
      case '4x5' : complexity = 140; break;
      case '4x6' : complexity = 150; break;
      case '5x5' : complexity = 160; break;
      case '5x6' : complexity = 170; break;
      default : complexity = 30;
    }
    return complexity;

 */
  }
  static int getBasicTestTime (int levelNumber) {
    String puzzleSize = getPuzzleComplexity(levelNumber);
    int pieces = getNumberOfPieces(puzzleSize);
    int testTime = (timePerPiece*pieces).toInt();
    print('LevelNumber $levelNumber Test time is $testTime');
    return testTime;
  }

  static int getTotalTestTime (int levelNumber) {
    double eventComplexity = getTestComplexity(levelNumber);
    return (getBasicTestTime(levelNumber) + getNumberOfEvents(levelNumber)).toInt();
  }

  static int getNumberOfPieces(String puzzleSize) {
    List<String> complexity = puzzleSize.split('x');
    int rows = int.parse(complexity[0]);
    int cols = int.parse(complexity[1]);
    return rows*cols;
  }

  static void printTestTime () {
    for (int i = 0; i < maxLevels; i++ ) {
      int testTime = getBasicTestTime(i+1);
      List<String> complexity = Level.getPuzzleComplexity(i+1).split('x');
      int rows = int.parse(complexity[0]);
      int cols = int.parse(complexity[1]);
      print ('Level ${i+1} testTime $testTime $rows $cols ${getNumberOfEvents(i+1)} ${getPuzzleComplexityTime(Level.getPuzzleComplexity(i+1))}');
    }
  }
}

