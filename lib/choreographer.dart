import 'dart:async';
import 'dart:ui' as ui;
import 'dart:io';
import 'lights.dart';
import 'vibColumn.dart';
import 'level.dart';
import 'dart:math';
import 'main.dart';
import 'piece.dart';
import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

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
  int numLights = 0;
  int numSounds = 0;
  int numVibrations = 0;
  Timeline timeline = null;
  int index = 0;
  int gameTime = 0;
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
  Timer timer1;
  Timer timer2;
  int totalPuzzlePieces = 0;
  int numOfCompletedPieces = 0;
  int beginLightKey = 0;
  int beginVibKey = 0;
  int beginSoundKey = 0;
  String readyText = "Start the test";

  Choreographer ({this.lightCorridor, this.vibSoundCorridor, this.homePage}) {
    lightCorridor.setCallback(LightCallback);
    vibSoundCorridor.setClickCallBack(VibSoundCallback);
    numLights = numVibrations = numSounds = Level.getEventComplexity(homePage.levelNumber);
    if (homePage.state == null) {
      homePage.state.gameStatus = readyText;
    }
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

  void justWait () async {
    while( timer1InProgress || timer2InProgress ) {
     await Future.delayed(Duration(milliseconds: 10));
    }
  }

  void setStatusToReady(bool firstTime)  async {
    if (timer1 != null) {
      timer1.cancel();
      timer1 = null;
    }
    if (timer2 != null) {
      timer2.cancel();
      timer2 = null;
    }
    justWait();

    homePage.state.setState(()  {
      homePage.state.gameStatus = "Please wait";
      curStatus = ChoreographerStatus.Ready;

      //Wait for the timers to exit

      homePage.state.gameStatus = (firstTime) ? "Start the test" : 'Retest';
      if ((pieces != null) && (pieces.length != 0)) {
        pieces.forEach((element) {
          element.setItInactive();
        });
        movePuzzlePiecesBack();
      }
      vibSoundCorridor.turnSoundsOff();
      vibSoundCorridor.turnVibrationsOff();
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
      if (beginVibKey == 1) {
        curVibrationKeys++;
        homePage.state.setVibrationCount(curVibrationKeys, totalVibrationKeys);
      }
    }
    else {
      if (beginSoundKey == 1) {
        curSoundKeys++;
        homePage.state.setSoundCount(curSoundKeys, totalSoundKeys);
      }
    }
  }

  void LightCallback (int key) {
    if (key == beginLightKey) {
      curLightKeys++;
      homePage.state.setLightCount(curLightKeys, totalLightKeys);
    }
    print ("The key is $key");
  }

  void display () async {
    String lightString, vibrationString, soundString, puzzleString;
    puzzleString = (numOfCompletedPieces == totalPuzzlePieces) ? 'Completed' : 'Incomplete';
    lightString = (curLightKeys == totalLightKeys) ? 'No misses' : 'missed ${(totalLightKeys - curLightKeys)}';
    vibrationString = (curVibrationKeys == totalVibrationKeys) ? 'No misses' : 'missed ${(totalVibrationKeys - curVibrationKeys)}';
    soundString = (curSoundKeys == totalSoundKeys) ? 'No misses' : 'missed ${(totalSoundKeys - curSoundKeys)}';
    Widget okButton = TextButton(
      child: Text("Ok", style: TextStyle(color:Colors.white)),
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.black)),
      onPressed: () {
        Navigator.of(homePage.state.puzzleKey.currentContext, rootNavigator: true).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.lightBlueAccent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(color: Colors.black)
      ),
      title: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Text('Results', style: TextStyle(color: Colors.black, fontSize: 30))),
            Text(' '),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RawMaterialButton(child: Text('Puzzle:',style: TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold))),
                    Text('$puzzleString', style: TextStyle(color: Colors.black),),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RawMaterialButton(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.all(0.0),
                        shape: new CircleBorder(side: BorderSide(width: 1.0, color: Colors.yellow)),
                        fillColor: Colors.black,
                        child: Icon(Icons.lightbulb, color: Colors.yellow)),
                    Text(lightString, style: TextStyle(color: Colors.black),),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RawMaterialButton(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.all(0.0),
                        shape: new CircleBorder(side: BorderSide(width: 1.0, color: Colors.yellow)),
                        fillColor: Colors.black,
                        child: Icon(Icons.vibration, color: Colors.yellow)),
                    Text(vibrationString, style: TextStyle(color: Colors.black),),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RawMaterialButton(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.all(0.0),
                        shape: new CircleBorder(side: BorderSide(width: 1.0, color: Colors.yellow)),
                        fillColor: Colors.black,
                        child: Icon(Icons.music_note, color: Colors.yellow)),
                    Text(soundString, style: TextStyle(color: Colors.black)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RawMaterialButton(child: Text('Overall:',style: TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold))),
                    Text('${getResultString()}', style: TextStyle(color: Colors.black),),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      //content: Container(color: Colors.blue, child: Text("")),
    actions: [
        okButton,
      ],
    );
    await showDialog(
        context: homePage.state.puzzleKey.currentContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void moveBackIdlePieces  () async
  {
    timer2InProgress = false;
    timer2 = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      timer2InProgress = true;
      print("moveBackIdlePieces timer");
      if (isReady()) {
        timer.cancel();
      }
      else {
        //find the piece tha is not at home or destination\
        bool atHome, atDestination, noIdlePiecesFound;
        noIdlePiecesFound = false;
        totalPuzzlePieces = homePage.state.cols * homePage.state.rows;
        numOfCompletedPieces = 0;
        List<int> listOfIdlers = List<int>();
        for (int i = 0; i < pieces.length; i++) {
          if (!pieces[i].filter) {
            if (pieces[i].isMovable) {
              atHome = pieces[i].atHome();
              atDestination = pieces[i].atDestination();
              if (!(atHome || atDestination)) {
                listOfIdlers.add(i);
              }
            } else {
              numOfCompletedPieces++;
            }
          }
        }

        homePage.state.setPuzzleCompletion(
            numOfCompletedPieces, totalPuzzlePieces);
        if (numOfCompletedPieces == totalPuzzlePieces) {
          print('Trying to display the results');
          setStatusToReady(false);
          homePage.state.setState(() {
            homePage.state.lastResult = getResultString();
            Scores.addString(getResultString());
          });
          display();
        } else {
          DateTime l1, l2;
          int itemToBeMovedBack;
          if (listOfIdlers.length > 1) {
            l1 = pieces[listOfIdlers[0]].lastTime;
            l2 = pieces[listOfIdlers[1]].lastTime;
            if (l1.compareTo(l2) < 0) {
              itemToBeMovedBack = listOfIdlers[0];
            }
            else {
              itemToBeMovedBack = listOfIdlers[1];
            }
            pieces[itemToBeMovedBack].setCurPosToOrgPos();
          }
        }
        print("MTimer is still on");
      }
      timer2InProgress = false;
    });
  }

  //Move it back
  // pieces[itemToBeMovedBack].setCurPosToOrgPos();
  ///pieces[itemToBeMovedBack].movePieceBackToOrgPosition();

  void movePuzzlePiecesBack ()
  {
    for (int i = 0; i < pieces.length; i++) {
      if (!pieces[i].filter) {
        if (!pieces[i].atHome()) {
          pieces[i].setCurPosToOrgPos();
        }
      }
    }
  }


  String getResultString () {
    bool puzzleCompleted = false;
    int events = 0;
    String result = 'More effort';

    if (numOfCompletedPieces == totalPuzzlePieces) {
      puzzleCompleted = true;
    }
    if (curVibrationKeys == totalVibrationKeys) {
      ++events;
    }
    if (curSoundKeys == totalSoundKeys) {
      ++events;
    }
    if (curLightKeys == totalLightKeys) {
      ++events;
    }
    if (puzzleCompleted) {
      if (events == 3) {
        result = 'Fantastic';
      } else if (events == 2) {
        result = 'Good';
      } else if (events == 1) {
        result = 'More effort';
      }
    }
    return result;
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
    timer1InProgress = false;
    timer1 = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      timer1InProgress = true;
      if (gameTime > 0) {
        gameTime -= 1;
        homePage.state.setTimeRemaining(gameTime);
      }
      if (gameTime == 0) {
        setStatusToReady(false);
      }
      if (isReady()) {
        timer.cancel();
      } else {
        //Get time unit
        Timeunit curTimeUnit = timeline.getTimeUnit(index);
        //Should we light on
        if (curTimeUnit.active) {
          if (curTimeUnit.startLight) {
            lightCorridor.turnLightOn(curTimeUnit.lightKey);
            totalLightKeys+=1;
            homePage.state.setLightCount(curLightKeys, totalLightKeys);
            beginLightKey = curTimeUnit.lightKey;
            print ('Turning light on at $index and light number is ${curTimeUnit.lightKey}');
          }
        }

        //Should we turn the light off
        if (curTimeUnit.active) {
          if (curTimeUnit.stopLight) {
            beginLightKey = 0;
            lightCorridor.turnLightOff(curTimeUnit.lightKey);
            homePage.state.setLightCount(curLightKeys, totalLightKeys);
          }
          lastLightKey = 0;
        }


      //Should we start the vibration
       if (curTimeUnit.active) {
        if (curTimeUnit.startVibrations) {
          beginVibKey = 1;
          totalVibrationKeys++;
          vibSoundCorridor.turnVibrationsOn();
          homePage.state.setVibrationCount(curVibrationKeys, totalVibrationKeys);
          print ('Turning vibration on at $index}');
        }
      }

      //Should we stop the vibration
      if (curTimeUnit.active) {
        if (curTimeUnit.stopVibrations) {
           vibSoundCorridor.turnVibrationsOff();
           beginVibKey = 0;
        }
        print ('Turning vibration off at $index}');
      }

      //Should we start the sound
      if (curTimeUnit.active) {
        if (curTimeUnit.startSounds) {
          beginSoundKey = 1;
          totalSoundKeys++;
          vibSoundCorridor.turnSoundsOn();
          homePage.state.setSoundCount(curSoundKeys, totalSoundKeys);
        }
      }

      //Should we stop the sound
      if (curTimeUnit.active) {
        if (curTimeUnit.stopSounds) {
          beginSoundKey = 0;
          vibSoundCorridor.turnSoundsOff();
          print ('Turning sound off at $index}');
        }
      }

      //Should we stop the timer

        //Point to the next time slot
        index++;
      }
      print("OTimer is still on");
    });
    moveBackIdlePieces();
    //Activate the pieces
    pieces.forEach((element) {element.setItActive();
    timer1InProgress = false;
    });

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

enum TimeLineEntries {
 NoEntry,
 LightEntry,
 VibrationEntry,
 SoundEntry
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

  List<TimeLineEntries> ShuffleColumn(int numLightEntries, int numVibEntries, int numSoundEntries, int defaultEntry, int colLength) {
    //Create the list
    List<TimeLineEntries> workingList = List<TimeLineEntries> (colLength);
    //Initialize the remaining entries with the default
    for( int i = 0; i < colLength; i++) {
      workingList[i] = TimeLineEntries.NoEntry;
    }

    //Initialize the array with Light Entries
    for( int i = 0; i < numLightEntries; i++) {
      workingList[i] = TimeLineEntries.LightEntry;
    }

    //Initialize the remaining entries with Vibration Entries
    for( int i = 0; i < numVibEntries; i++) {
      workingList[i+numLightEntries] = TimeLineEntries.VibrationEntry;
    }

    //Initialize the remaining entries with Vibration Entries
    for( int i = 0; i < numSoundEntries; i++) {
      workingList[i+numLightEntries+numVibEntries] = TimeLineEntries.SoundEntry;
    }

    workingList.shuffle(Random(DateTime.now().millisecond));
    return workingList;
  }

  void SetASectionActive(int index, int width) {
    for ( int i = index; (i < (index+ width)) && (i < timeUnitList.length); i++ ) {
      timeUnitList[i].active = true;
    }
  }

  int FindNextSlotWithAnEvent(List<TimeLineEntries> entries, int index) {
    int emptySlot = -1;
    for (int i = index; i < entries.length; i++ ) {
      if (entries[i] != TimeLineEntries.NoEntry) {
        emptySlot = i;
        break;
      }
    }
    return emptySlot;
  }

  bool isThereEnoughSpace (List<Timeunit> entries, int index, int width) {
    int i = index;
    bool found = true;
    int j = 0;
    while (((i+j) < entries.length) && (j < width)) {
      if (entries[i+j].active) {
        found = false;
        break;
      }
      j++;
    }
    if ((i+j) == entries.length) {
      found = false;
    }
    return found;
  }

  int FindNextEmptyTimelineSlot( List<Timeunit> entries, int index) {
    int emptySlot = -1;
    for (int i = index; i < entries.length; i++ ) {
      if (!entries[i].active) {
        emptySlot = i;
        break;
      }
    }
    if (emptySlot == -1) {
      for (int i = 0; i < index; i++ ) {
        if (!entries[i].active) {
          emptySlot = i;
          break;
        }
      }
    }
    return emptySlot;
  }

  void create() {
    int totalNumOfLights, totalNumOfVibrations, totalNumOfSounds, totalTimeUnits;
    //Number of lights
    totalNumOfLights = lengthOfTimeLine * numLights;
    print ("totalNumOfLights $totalNumOfLights");

    //Number of vibrations
    totalNumOfVibrations = lengthOfTimeLine * numVibrations;
    print ('totalNumOfVibrations $totalNumOfVibrations');

    //Number of sounds
    totalNumOfSounds = lengthOfTimeLine * numSounds;
    print ('totalNumOfSounds $totalNumOfSounds');

    //Number of time units to create
    totalTimeUnits = lengthOfTimeLine * 60;

    //Create time units
    timeUnitList = List<Timeunit> (totalTimeUnits);
    for(int i=0; i <  timeUnitList.length; i++) {
      timeUnitList[i] = Timeunit();
    }

//    List<TimeLineEntries> ShuffleColumn(int numLightEntries, int numVibEntries, int numSoundEntries, int defaultEntry, int colLength) {

    //Setup light timeline
    int defaultEntry = 1000;
    List<TimeLineEntries> lightTriggers = ShuffleColumn(totalNumOfLights, totalNumOfVibrations, totalNumOfSounds, defaultEntry, lengthOfTimeLine*60);

    //Add it to the timeline
    var randomKey = new Random();
    int maxWidth = soundWidth;
    if ((lightWidth > soundWidth) && (lightWidth > vibrationWidth)){
      maxWidth = lightWidth;
    } else if ((vibrationWidth > soundWidth) && (vibrationWidth > lightWidth)) {
      maxWidth = vibrationWidth;
    }
    int i = 0;
    while (i < totalTimeUnits) {
      i = FindNextSlotWithAnEvent(lightTriggers, i);
      if (-1 == i) {
        break;
      }
      int nextEmptySlot = FindNextEmptyTimelineSlot(timeUnitList, i);
      if (nextEmptySlot != -1) {
         if (isThereEnoughSpace(timeUnitList, nextEmptySlot, maxWidth)) {
            if (lightTriggers[i] == TimeLineEntries.LightEntry) {
              timeUnitList[nextEmptySlot].active = true;
              timeUnitList[nextEmptySlot].startLight = true;
              timeUnitList[nextEmptySlot].lightKey = randomKey.nextInt(numLightKeys) + 1;

              //Setup light stop key
              timeUnitList[nextEmptySlot+lightWidth].active = true;
              timeUnitList[nextEmptySlot+lightWidth].stopLight = true;
              timeUnitList[nextEmptySlot+lightWidth].lightKey = timeUnitList[nextEmptySlot].lightKey;

              //Block
              SetASectionActive(nextEmptySlot+1, lightWidth);
            } else if (lightTriggers[i] == TimeLineEntries.VibrationEntry) {
              timeUnitList[nextEmptySlot].active = true;
              timeUnitList[nextEmptySlot].startVibrations = true;

              //Setup Vibration stop key
              timeUnitList[nextEmptySlot + vibrationWidth].active = true;
              timeUnitList[nextEmptySlot + vibrationWidth].stopVibrations = true;

              //Block
              SetASectionActive(nextEmptySlot+1, vibrationWidth);
            } else if (lightTriggers[i] == TimeLineEntries.SoundEntry) {
              timeUnitList[nextEmptySlot].active = true;
              timeUnitList[nextEmptySlot].startSounds = true;

              //Setup Sound stop key
              timeUnitList[nextEmptySlot + soundWidth].active = true;
              timeUnitList[nextEmptySlot + soundWidth].stopSounds = true;

              //Block
              SetASectionActive(nextEmptySlot+1, soundWidth);
            }
         }
      } else {
        break;
      }
      i++;
  }
  int x = 1;
  timeUnitList.forEach((element) {
    print (" $x Active ${element.active} ${element.startLight} ${element.stopLight} ${element.startVibrations} ${element.stopVibrations} ${element.startSounds} ${element.stopSounds} ${element.lightKey}");
    x++;
    });
  }
}

class Timeunit {
  bool active = false;
  bool startLight =  false;
  bool stopLight = false;
  bool startVibrations = false;
  bool stopVibrations = false;
  bool startSounds = false;
  bool stopSounds = false;
  int lightKey=0;
  Timeunit();
}
