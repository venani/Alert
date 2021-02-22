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
  AudioPlayer audioPlayer;
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

  void turnVibrationsOn() {
    print ('turnVibrationsOn');
    Vibration.vibrate();
  }

  void turnVibrationsOff() {
    print ('turnVibrationsOff');
    Vibration.cancel();
  }

  void turnSoundsOn() async {
    print ('turnSoundsOn');
    audioPlayer = await audioCache.play('sound/mind.mp3');
  }

  void turnSoundsOff() {
    print ('turnSoundsOff');
    audioPlayer.stop();
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
            size: widget.vibCorridorSize.width,
          ),
          shape: new CircleBorder(),
          color: curColor,
        )
    );
  }
}