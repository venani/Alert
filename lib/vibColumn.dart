import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vibration/vibration.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

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
  static bool vibrationHardwareIsPresent = false;
  Function clickCallback;
  bool audioStatus = false;
  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer.withId("0");
  VibSoundCorridor(this.vibCorridorSize, this.numberOfVibSoundButtons, this.updateState)  {
  }


  void setClickCallBack (Function callback) {
    clickCallback = callback;
  }

  List<VibSoundButton> getList() {

    List<VibSoundButton> vibSoundButtonList = List<VibSoundButton>();
    Size vibSoundSize = Size(vibCorridorSize.width, vibCorridorSize.height/numberOfVibSoundButtons);
    for (int index=0; index < (numberOfVibSoundButtons) ; index++) {
      if ((index % 2 == 0) && vibrationHardwareIsPresent) {
          vibSoundButtonList.add(VibSoundButton(id: index, topPos: (vibSoundSize.height * index) , updateState: updateState,
          vibCorridorSize: vibSoundSize, vibSoundType: VibSoundType.Vibration, clickCallBack: clickCallback));
      }
      else {
        vibSoundButtonList.add(VibSoundButton(id: index, topPos: (vibSoundSize.height * index) , updateState: updateState,
          vibCorridorSize: vibSoundSize, vibSoundType: VibSoundType.Sound, clickCallBack: clickCallback));
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

  Future<void> turnSoundsOn() async {
    await assetsAudioPlayer.play();
    print ('turnSoundsOn');
  }

  Future<void> turnSoundsOff() async {
    await assetsAudioPlayer.pause();
  }

  Future<int> releaseSound() async {
  }

  Future<int> setupSound() async {
    await assetsAudioPlayer.open(Audio("assets/sound/mind.mp3"), autoStart: false, loopMode: LoopMode.single);
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
        child: Container(
          width: widget.vibCorridorSize.width,
          height: widget.vibCorridorSize.height,
          child: RawMaterialButton(
            fillColor: curColor,
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
            shape: RoundedRectangleBorder(side: BorderSide(width: 3.0, color: Colors.yellow), borderRadius: BorderRadius.all(Radius.circular(16.0)) ), //new CircleBorder(side: BorderSide(width: 3.0, color: Colors.yellow)),
          ),
        )
    );
  }
}