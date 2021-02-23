import 'package:flutter/material.dart';
import 'dart:async';

class LightCorridor
{
  final Size lightCorridorSize;
  final int numberOfLights;
  final Function updateState;
  List<Light> lightList;
  Function lightCallback;

  void setCallback (Function callback) {
    lightCallback = callback;
  }

  LightCorridor(this.lightCorridorSize, this.numberOfLights, this.updateState) {
  }

  List<Light> getList() {
    lightList = List<Light>();
    Light curLight;
    for (int index=0; index < numberOfLights; index++) {
      curLight = Light(id: index, topPos: (lightCorridorSize.height * (index+1) / (numberOfLights+1)), updateState: updateState,
          lightCorridorSize: lightCorridorSize);
      curLight.lightCallback = lightCallback;
      lightList.add (curLight);
    }
  return lightList;
  }

  void turnLightOn (int lightKey) {
    lightList[lightKey - 1].state.setColor(ColorStates.Active);
  }

  void turnLightOff (int lightKey) {
    lightList[lightKey - 1].state.setColor(ColorStates.Inactive);
  }

}

class Light extends StatefulWidget {
  final Function updateState;
  final int id;
  Size lightCorridorSize;
  double leftPos = 0.0;
  double topPos;
  _LightState state;
  Function lightCallback;

  Light ({
    this.id,
    this.topPos,
    this.lightCorridorSize,
    this.updateState
})
  {
  }
  @override
  _LightState createState() {
    state = _LightState();
    return state;
  }

  void setCorridorSize(Size corridorSize)
  {
    lightCorridorSize = corridorSize;
  }
}

enum ColorStates
{
  Active,
  Inactive
}

class _LightState extends State<Light> {
  GlobalKey localKey = GlobalKey();
  ColorStates curColorState;

  Color curColor = Colors.blue;
  void setColor(ColorStates colorState)
  {
    setState(() {
      print("T1");
      if (colorState == ColorStates.Active) {
      curColor = Colors.yellow;
      print("T2");
    }
      else
    {
      curColor = Colors.blue;
      print("T3");
    }});
  }

  Widget build(BuildContext context) {
    print ("The top position is ${widget.topPos}");
    return Positioned(
        top: widget.topPos,
        left: widget.leftPos,
        width: widget.lightCorridorSize.width,
        height: widget.lightCorridorSize.width,
        child: FlatButton(
          padding: const EdgeInsets.all(0.0),
          key: localKey,
          onPressed: () {
            widget.updateState( () {
              widget.lightCallback(widget.id);
            });
          },
          child: new Icon(
            Icons.lightbulb,
            color: Colors.white,
            size: 20.0,
          ),
          shape: new CircleBorder(),
          color: curColor,
        )
        //child: Text('A'),
        // child: RawMaterialButton(
        //   elevation: 0.0,
        //   child: Icon(Icons.add),
        //   onPressed: (){
        //     print ("My id is ${widget.id} and my top is at ${widget.topPos}");
        //   },
        //   constraints: BoxConstraints.loose( Size(widget.lightCorridorSize.width, widget.lightCorridorSize.width)
        //   ),
        //   shape: CircleBorder(),
        //   fillColor: Colors.deepPurple,
        // ),
    );
  }
}