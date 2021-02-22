
class Level
{
  static int getPuzzleComplexity (int levelNumber) {
    int puzzleComplexity;
    switch (levelNumber) {
      case 1 : puzzleComplexity = 4; break;
      case 2 : puzzleComplexity = 5; break;
      case 3 : puzzleComplexity = 6; break;
      case 4 : puzzleComplexity = 7; break;
      case 4 : puzzleComplexity = 7; break;
      case 4 : puzzleComplexity = 7; break;
      default: puzzleComplexity = 4;
    }
    return puzzleComplexity;
  }

  static int getLightsComplexity (int levelNumber) {
    int lightsComplexity;
    switch (levelNumber) {
      case 1 : lightsComplexity = 40; break;
      case 2 : lightsComplexity = 5; break;
      case 3 : lightsComplexity = 6; break;
      case 4 : lightsComplexity = 7; break;
      case 4 : lightsComplexity = 7; break;
      case 4 : lightsComplexity = 7; break;
      default: lightsComplexity = 4;
    }
    return lightsComplexity;
  }

  static int getVibrationComplexity (int levelNumber) {
    int vibrationComplexity;
    switch (levelNumber) {
      case 1 : vibrationComplexity = 4; break;
      case 2 : vibrationComplexity = 5; break;
      case 3 : vibrationComplexity = 6; break;
      case 4 : vibrationComplexity = 7; break;
      case 4 : vibrationComplexity = 7; break;
      case 4 : vibrationComplexity = 7; break;
      default: vibrationComplexity = 4;
    }
    return vibrationComplexity;
  }

  static int getSoundComplexity (int levelNumber) {
    int soundComplexity;
    switch (levelNumber) {
      case 1 : soundComplexity = 30; break;
      case 2 : soundComplexity = 5; break;
      case 3 : soundComplexity = 6; break;
      case 4 : soundComplexity = 7; break;
      case 4 : soundComplexity = 7; break;
      case 4 : soundComplexity = 7; break;
      default: soundComplexity = 4;
    }
    return soundComplexity;
  }
}

