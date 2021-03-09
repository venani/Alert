import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:vibration/vibration.dart';


enum VibSoundType
{
  Vibration,
  Sound
}

class VibSoundCorridor
{
  final Size vibCorridorSize;
  final int numberOfVibSoundButtons;
  final Function updateState;
  Function clickCallback;
  AudioPlayer audioPlayer = null;
  AudioCache audioCache = AudioCache();
  VibSoundCorridor(this.vibCorridorSize, this.numberOfVibSoundButtons, this.updateState) {
  }

  void setClickCallBack (Function callback) {
    clickCallback = callback;
  }

  List<VibSoundButton> getList() {
    List<VibSoundButton> vibSoundButtonList = List<VibSoundButton>();
    for (int index=0; index < numberOfVibSoundButtons ; index++) {
      if (index % 2 == 0) {
          vibSoundButtonList.add(VibSoundButton(id: index, topPos: (vibCorridorSize.height * (index+1) / (numberOfVibSoundButtons+1)), updateState: updateState,
          vibCorridorSize: vibCorridorSize, vibSoundType: VibSoundType.Vibration, clickCallBack: clickCallback));
      }
      else {
        vibSoundButtonList.add(VibSoundButton(id: index, topPos: (vibCorridorSize.height * (index+1) / (numberOfVibSoundButtons+1)), updateState: updateState,
          vibCorridorSize: vibCorridorSize, vibSoundType: VibSoundType.Sound, clickCallBack: clickCallback));
      }
    }
    return vibSoundButtonList;
  }

  void turnVibrationsOn() async {
    print ('turnVibrationsOn');
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 10000);
    }
  }


  void turnVibrationsOff() {
    print ('turnVibrationsOff');
    Vibration.cancel();
  }

  void turnSoundsOn() async {
    print ('turnSoundsOn');
    print('turnSoundsOn status is ${(audioPlayer == null)}');
    if (audioPlayer == null) {
      audioPlayer = await audioCache.play('sound/win1.mp3');
      print ('play');
    }
    else {
      audioPlayer.resume();
      print ('resume');
    }
  }

  void turnSoundsOff() async {
    print('turnSoundsOff status is ${(audioPlayer == null)}');
    if (audioPlayer != null) {
      audioPlayer.pause();
      print ('pause');
    }
  }
}

class VibSoundButton extends StatefulWidget {
  final Function updateState;
  final int id;
  final VibSoundType vibSoundType;
  final Function clickCallBack;
  Size vibCorridorSize;
  double leftPos = 0.0;
  double topPos;

  VibSoundButton ({
    this.id,
    this.topPos,
    this.vibCorridorSize,
    this.updateState,
    this.vibSoundType,
    this.clickCallBack
  })
  {
  }
  @override
  _VibSoundButtonState createState() {
    return new _VibSoundButtonState();
  }

  void setCorridorSize(Size corridorSize)
  {
    vibCorridorSize = corridorSize;
  }
}

enum ColorStates
{
  Active,
  Inactive
}

class _VibSoundButtonState extends State<VibSoundButton> {
  GlobalKey localKey = GlobalKey();
  ColorStates curColorState;
  Color curColor = Colors.blue;
  Widget build(BuildContext context) {
    print ("The top position is ${widget.topPos}");
    return Positioned(
        top: widget.topPos,
        left: widget.leftPos,
        width: widget.vibCorridorSize.width,
        height: widget.vibCorridorSize.width,
        child: FlatButton(
          padding: const EdgeInsets.all(0.0),
          key: localKey,
          onPressed: () {
            widget.updateState( () {
              widget.clickCallBack(widget.vibSoundType == VibSoundType.Vibration);
            });
          },
          child: new Icon(
            (widget.vibSoundType == VibSoundType.Vibration) ? Icons.vibration : Icons.music_note,
            color: Colors.white,
            size: widget.vibCorridorSize.width-2.0,
          ),
          shape: new CircleBorder(side: BorderSide(width: 3.0, color: Colors.yellow)),
          color: curColor,
        )
    );
  }
}