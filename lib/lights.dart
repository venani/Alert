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

  void clearAllLights() {
    if ((lightList != null) && (lightList.length != 0)) {
      lightList.forEach((element) {element.state.setColor(ColorStates.Inactive);});
    }
  }

  List<Light> getList() {
    lightList = List<Light>();
    Light curLight;
    Size lightSize = Size(lightCorridorSize.width, lightCorridorSize.height/numberOfLights );
    for (int index=0; index < (numberOfLights); index++) {
      curLight = Light(id: index+1, topPos: (lightCorridorSize.height * index / numberOfLights), updateState: updateState,
          lightCorridorSize: lightSize);
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
    print ('height is ${lightCorridorSize.height} and width is ${lightCorridorSize.width}');
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
        child: Container(
          width: widget.lightCorridorSize.width,
          height: widget.lightCorridorSize.height,
          child: RawMaterialButton(
            fillColor: curColor,
            padding: const EdgeInsets.only(bottom: 10.0),
            key: localKey,
            onPressed: () {
              widget.updateState( () {
                widget.lightCallback(widget.id);
              });
            },
            child: Icon(
              Icons.lightbulb,
              color: Colors.white,
              size: widget.lightCorridorSize.width,
            ),
            shape: RoundedRectangleBorder(side: BorderSide(width: 3.0, color: Colors.yellow), borderRadius: BorderRadius.all(Radius.circular(16.0))), //new CircleBorder(side: BorderSide(width: 3.0, color: Colors.yellow)),

          ),
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