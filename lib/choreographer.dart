import 'dart:async';
import 'dart:ui' as ui;
import 'dart:io';
import 'lights.dart';
import 'vibColumn.dart';
import 'level.dart';
import 'dart:math';
import 'main.dart';
import 'piece.dart';

enum ChoreographerStatus {
  Ready,
  InProgress,
}

class Choreographer
{
  final LightCorridor lightCorridor;
  final VibSoundCorridor vibSoundCorridor;
  final MyHomePage homePage;
  List<Piece> pieces;

  ChoreographerStatus curStatus = ChoreographerStatus.Ready;
  int numberOfMinutes = 2;
  int level = 1;
  int numLights = Level.getLightsComplexity(1);
  int numSounds = Level.getSoundComplexity(1);
  int numVibrations = Level.getVibrationComplexity(1);
  Timeline timeline;
  int index = 0;
  int gameTime;
  bool timer1InProgress = false;
  bool timer2InProgress = false;
  int lastLightKey = 0;
  int lastVibrationKey = 0;
  int lastSoundKey = 0;
  int totalLightKeys = 0;
  int totalVibrationKeys = 0;
  int totalSoundKeys = 0;
  int curLightKeys = 0;
  int curVibrationKeys = 0;
  int curSoundKeys = 0;

  Choreographer ({this.lightCorridor, this.vibSoundCorridor, this.homePage}) {
    lightCorridor.setCallback(LightCallback);
    vibSoundCorridor.setClickCallBack(VibSoundCallback);
    setStatusToReady();
  }

  bool areTheTimersStopped()
  {
    return timer1InProgress && timer2InProgress;
  }

  void dispose ()
  {
    print ("class Choreographer dispose");
  }

  void setPieces( List<Piece> curPieces) {
    pieces = curPieces;
  }
  void setLevel(int curLevel) {
    level = curLevel;
  }

  void setLength(int numMinutes) {
    numberOfMinutes = numMinutes;
  }

  void setStatusToReady() {
    homePage.state.setState(() {
      curStatus = ChoreographerStatus.Ready;
      homePage.state.gameStatus = "Start the test";
      if ((pieces != null) && (pieces.length != 0)) {
        pieces.forEach((element) {
          element.state.setItInactive();
        });
        movePuzzlePiecesBack();
      }
      lightCorridor.clearAllLights();
    });
  }

  void setStatusToProgress() {
    curStatus = ChoreographerStatus.InProgress;
    start();
    homePage.state.setState(() {
      homePage.state.gameStatus = "Cancel";
    });
  }

  bool isProgressing () {
    if (curStatus == ChoreographerStatus.InProgress)
      return true;
    else
      return false;
  }

  bool isReady () {
    if (curStatus == ChoreographerStatus.Ready)
      return true;
    else
      return false;
  }

  void VibSoundCallback (bool vib) {
    if (vib) {
      print ("Its vib");
    }
    else {
      print ("Its sound");
    }
  }

  void LightCallback (int key) {
    lastLightKey = key;
      print ("The key is $key");
  }

  void moveBackIdlePieces ()
  {
    Timer.periodic(Duration(milliseconds: 1000), (timer) {
      print ("moveBackIdlePieces timer");
      if (isReady()) {
        timer.cancel();
        timer1InProgress = true;
      }
      else {
        //find the piece tha is not at home or destination\
        bool atHome, atDestination, noIdlePiecesFound;
        noIdlePiecesFound = false;
        int totalPuzzlePieces = homePage.state.cols * homePage.state.rows;
        int numOfCompletedPieces = 0;
        List<int> listOfIdlers = List<int>();
        for (int i = 0; i < pieces.length; i++) {
          if (!pieces[i].filter) {
            if (pieces[i].state.isMovable) {
              atHome = pieces[i].state.atHome();
              atDestination = pieces[i].state.atDestination();
              if (!(atHome || atDestination)) {
                listOfIdlers.add(i);
              }
            } else {
              numOfCompletedPieces++;
            }
          }
        }

        homePage.state.setPuzzleCompletion(numOfCompletedPieces, totalPuzzlePieces);
        if (numOfCompletedPieces == totalPuzzlePieces) {
          setStatusToReady();
        }

        DateTime l1, l2;
        int itemToBeMovedBack;
        if (listOfIdlers.length > 1) {
           l1 = pieces[listOfIdlers[0]].state.lastTime;
           l2 = pieces[listOfIdlers[1]].state.lastTime;
           if (l1.compareTo(l2) < 0) {
             itemToBeMovedBack = listOfIdlers[0];
           }
           else {
             itemToBeMovedBack = listOfIdlers[1];
           }
           //Move it back
           // pieces[itemToBeMovedBack].setCurPosToOrgPos();
          pieces[itemToBeMovedBack].state.movePieceBackToOrgPosition();
        }
      }
    });
  }

  void movePuzzlePiecesBack ()
  {
    for (int i = 0; i < pieces.length; i++) {
      if (!pieces[i].filter) {
        if (!pieces[i].state.atHome()) {
          pieces[i].state.setCurPosToOrgPos();
        }
      }
    }
  }

  void start() {
    gameTime = numberOfMinutes * 60;
    totalLightKeys = totalSoundKeys = totalVibrationKeys = 0;
    curLightKeys = curSoundKeys = curVibrationKeys = 0;


    //Create timeline
    timeline = Timeline (2, 2, 2, lengthOfTimeLine: numberOfMinutes,numLights: numLights, numVibrations: numVibrations, numSounds: numSounds, numLightKeys: 6);
    timeline.create();
    index = 0;

    //Update light counts
    homePage.state.setLightCount(curLightKeys, totalLightKeys);
    homePage.state.setVibrationCount(curVibrationKeys, totalVibrationKeys);
    homePage.state.setSoundCount(curSoundKeys, totalSoundKeys);

    //Start timer
    Timer.periodic(Duration(milliseconds: 1000), (timer) {
      if (gameTime > 0) {
        gameTime -= 1;
        homePage.state.setTimeRemaining(gameTime);
      }
      if (gameTime == 0) {
        setStatusToReady();
      }
      if (isReady()) {
        timer.cancel();
        timer2InProgress = true;
      } else {
        //Get time unit
        Timeunit curTimeUnit = timeline.getTimeUnit(index);
        //Should we light on
        if (curTimeUnit.lightActive) {
          if (curTimeUnit.startLight) {
            lightCorridor.turnLightOn(curTimeUnit.lightKey);
            totalLightKeys+=1;
            homePage.state.setLightCount(curLightKeys, totalLightKeys);
            print ('Turning light on at $index and light number is ${curTimeUnit.lightKey}');
          }
        }
        //Should we turn the light off
        if (curTimeUnit.lightActive) {
          if (curTimeUnit.stopLight) {
            lightCorridor.turnLightOff(curTimeUnit.lightKey);
            if (lastLightKey != 0) {
              if (lastLightKey == curTimeUnit.lightKey) {
                curLightKeys+=1;
              homePage.state.setLightCount(curLightKeys, totalLightKeys);
              }
              lastLightKey = 0;
            }
          }
        }


      //Should we start the vibration
      if (curTimeUnit.vibrationActive) {
        if (curTimeUnit.startVibrations) {
          vibSoundCorridor.turnVibrationsOn();
          print ('Turning vibration on at $index}');
        }
      }

      //Should we stop the vibration
      if (curTimeUnit.vibrationActive) {
        if (curTimeUnit.stopVibrations) {
          vibSoundCorridor.turnVibrationsOff();
          print ('Turning vibration off at $index}');
        }
      }


      //Should we start the sound
      if (curTimeUnit.soundActive) {
        if (curTimeUnit.startSounds) {
          vibSoundCorridor.turnSoundsOn();
          print ('Turning sound on at $index}');
        }
      }

      //Should we stop the sound
      if (curTimeUnit.soundActive) {
        if (curTimeUnit.stopSounds) {
          vibSoundCorridor.turnSoundsOff();
          print ('Turning sound off at $index}');
        }
      }

      //Should we stop the timer

        //Point to the next time slot
        index++;
      }
    });
    moveBackIdlePieces();
    //Activate the pieces
    pieces.forEach((element) {element.state.setItActive();});
  }

  void stop()
  {

  }
}

enum TimeunitStatus {
  Dormant,
  Inactive,
  Active
}

class Timeline {
  final int lengthOfTimeLine;
  final int numLights;
  final int numVibrations;
  final int numSounds;
  final int numLightKeys;
  final int lightWidth;
  final int vibrationWidth;
  final int soundWidth;
  List<Timeunit> timeUnitList;

  Timeline (this.lightWidth, this.vibrationWidth, this.soundWidth, {this.lengthOfTimeLine, this.numLights, this.numVibrations, this.numSounds, this.numLightKeys});

  Timeunit getTimeUnit(int index) {
    return timeUnitList[index];
  }

  int getLengthOfTimeline()
  {
    return timeUnitList.length;
  }

  List<int> ShuffleColumn(int numEntries, int defaultEntry, int colLength) {
    //Create the list
    List<int> workingList = List<int> (colLength);
    //Initialize the array with numEntries
    for( int i = 0; i < numEntries; i++) {
      workingList[i] = i;
    }

    //Initialize the remaining entries with the default
    for( int i = numEntries; i < colLength; i++) {
      workingList[i] = defaultEntry;
    }

    workingList.shuffle(Random(DateTime.now().millisecond));
    return workingList;
  }

  void create() {
    int totalNumOfLights, totalNumOfVibrations, totalNumOfSounds, totalTimeUnits;
    //Number of lights
    totalNumOfLights = lengthOfTimeLine * numLights;

    //Number of vibrations
    totalNumOfVibrations = lengthOfTimeLine * numVibrations;

    //Number of sounds
    totalNumOfSounds = lengthOfTimeLine * numSounds;

    //Number of time units to create
    totalTimeUnits = lengthOfTimeLine * 60;

    //Create time units
    timeUnitList = List<Timeunit> (totalTimeUnits + 10);
    for(int i=0; i <  timeUnitList.length; i++) {
      timeUnitList[i] = Timeunit();
    }


    //Setup light timeline
    int defaultLightEntry = 1000;
    List<int> lightTriggers = ShuffleColumn(totalNumOfLights, defaultLightEntry, lengthOfTimeLine*60);
    //Add it to the timeline
    var randomKey = new Random();
    for (int i=0; i < totalTimeUnits; i++) {
      if (lightTriggers[i] != defaultLightEntry) {
        if (!timeUnitList[i].lightActive) {
          timeUnitList[i].lightActive = true;
          timeUnitList[i].startLight = true;
          timeUnitList[i].lightKey = randomKey.nextInt(numLightKeys) + 1;

          //Setup light stop key
          timeUnitList[i+lightWidth].lightActive = true;
          timeUnitList[i+lightWidth].stopLight = true;
          timeUnitList[i+lightWidth].lightKey = timeUnitList[i].lightKey;
        }
      }
    }

    //Setup vibrations timeline
    int defaultVibEntry = 1000;
    List<int> vibTriggers = ShuffleColumn(totalNumOfVibrations, defaultVibEntry, lengthOfTimeLine*60);
    for (int i=0; i < totalTimeUnits; i++) {
      if (vibTriggers[i] != defaultVibEntry) {
        if (!timeUnitList[i].vibrationActive) {
          timeUnitList[i].vibrationActive = true;
          timeUnitList[i].startVibrations = true;

          //Setup light stop key
          timeUnitList[i + vibrationWidth].vibrationActive = true;
          timeUnitList[i + vibrationWidth].stopVibrations = true;
        }
      }
    }

    //Setup sounds timeline
    int defaultSoundEntry = 1000;
    List<int> soundTriggers = ShuffleColumn(totalNumOfSounds, defaultSoundEntry, lengthOfTimeLine*60);
    for (int i=0; i < totalTimeUnits; i++) {
      if (soundTriggers[i] != defaultSoundEntry) {
        if (!timeUnitList[i].soundActive) {
          timeUnitList[i].soundActive = true;
          timeUnitList[i].startSounds = true;

          //Setup light stop key
          timeUnitList[i + soundWidth].soundActive = true;
          timeUnitList[i + soundWidth].stopSounds = true;
        }
      }
    }
  }
}

class Timeunit {
  bool lightActive = false;
  bool vibrationActive= false;
  bool soundActive = false;
  bool startLight =  false;
  bool stopLight = false;
  bool startVibrations = false;
  bool stopVibrations = false;
  bool startSounds = false;
  bool stopSounds = false;
  int lightKey=0;
  Timeunit();
}
