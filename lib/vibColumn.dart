import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
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
  Function clickCallback;
  bool audioStatus = false;
  //AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
  //AudioCache audioCache = AudioCache();
  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer.newPlayer();

  VibSoundCorridor(this.vibCorridorSize, this.numberOfVibSoundButtons, this.updateState) {
  }

  void setClickCallBack (Function callback) {
    clickCallback = callback;
  }

  List<VibSoundButton> getList() {

    List<VibSoundButton> vibSoundButtonList = List<VibSoundButton>();
    Size vibSoundSize = Size(vibCorridorSize.width, vibCorridorSize.height/numberOfVibSoundButtons);
    for (int index=0; index < (numberOfVibSoundButtons) ; index++) {
      if (index % 2 == 0) {
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

    //int status = 0;

    print ('turnSoundsOn');
    // print('turnSoundsOn status is ${(audioPlayer == null)} ${DateTime.now().toString()}');
    // if (audioPlayer == null) {
    //   audioPlayer = await audioCache.play('sound/win1.mp3');
    //   print ('play');
    // }
    // else {
    //    status = await audioPlayer.resume();
    //   print ('resume $status  ${DateTime.now().toString()}');
    // }
    //status = await audioPlayer.resume();
    //return status;

  }

  Future<void> turnSoundsOff() async {
    //int status = 0;
    // print('turnSoundsOff status is ${(audioPlayer == null)}');
    // if (audioPlayer != null) {
    //   int status = await audioPlayer.pause();
    //   print ('pause $status ');
    // }
    // else
    // {
    //   print ('there is a problem');
    // }
    //status = await audioPlayer.pause();
    await assetsAudioPlayer.pause();
  }

  Future<int> releaseSound() async {
    int status = 0;
    //status = await audioPlayer.release ();
  }

  Future<int> setupSound() async {
    // //await audioPlayer.setUrl('sound/mind.mp3', isLocal: true);
    // print('About to start play');
    // audioPlayer = await audioCache.play('sound/mind.mp3', volume: 0.1);
    // print('About to turn sound off');
    // int status = await audioPlayer.pause();
    // audioPlayer.setVolume(1.0);
    // print('It should be off by now');
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