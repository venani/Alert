
class Level
{
  static String getPuzzleComplexity (int levelNumber) {
    String puzzleComplexity;
    switch (levelNumber) {
      case 01 : puzzleComplexity = '2x2'; break;
      case 02 : puzzleComplexity = '2x2'; break;
      case 03 : puzzleComplexity = '2x2'; break;
      case 04 : puzzleComplexity = '2x2'; break;
      case 05 : puzzleComplexity = '2x2'; break;
      case 06 : puzzleComplexity = '2x3'; break;
      case 07 : puzzleComplexity = '2x3'; break;
      case 08 : puzzleComplexity = '2x3'; break;
      case 09 : puzzleComplexity = '3x3'; break;
      case 10 : puzzleComplexity = '3x3'; break;
      case 11 : puzzleComplexity = '3x3'; break;
      case 12 : puzzleComplexity = '3x4'; break;
      case 13 : puzzleComplexity = '3x4'; break;
      case 14 : puzzleComplexity = '3x4'; break;
      case 15 : puzzleComplexity = '4x4'; break;
      case 16 : puzzleComplexity = '4x4'; break;
      case 17 : puzzleComplexity = '4x4'; break;
      case 18 : puzzleComplexity = '5x4'; break;
      case 19 : puzzleComplexity = '5x4'; break;
      case 20 : puzzleComplexity = '5x5'; break;
      case 21 : puzzleComplexity = '5x5'; break;
      default : puzzleComplexity = '2x2';
    }
    return puzzleComplexity;
  }

  static int getEventComplexity (int levelNumber) {
    int eventComplexity;
    switch (levelNumber) {
      case 01 : eventComplexity = 1; break;
      case 02 : eventComplexity = 2; break;
      case 03 : eventComplexity = 4; break;
      case 04 : eventComplexity = 8; break;
      case 05 : eventComplexity = 10; break;
      case 06 : eventComplexity = 6; break;
      case 07 : eventComplexity = 8; break;
      case 08 : eventComplexity = 10; break;
      case 09 : eventComplexity = 6; break;
      case 10 : eventComplexity = 8; break;
      case 11 : eventComplexity = 10; break;
      case 12 : eventComplexity = 6; break;
      case 13 : eventComplexity = 8; break;
      case 14 : eventComplexity = 10; break;
      case 15 : eventComplexity = 4; break;
      case 16 : eventComplexity = 5; break;
      case 17 : eventComplexity = 4; break;
      case 18 : eventComplexity = 5; break;
      case 19 : eventComplexity = 6; break;
      case 20 : eventComplexity = 4; break;
      case 21 : eventComplexity = 5; break;
      default : eventComplexity = 4;
    }
    return eventComplexity;
  }
}


