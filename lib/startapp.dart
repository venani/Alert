import 'dart:async';
import 'package:flutter/material.dart';
import 'levelhistory.dart';
import 'package:flutter_is_emulator/flutter_is_emulator.dart';
import 'vibColumn.dart';
import 'package:vibration/vibration.dart';
import 'main.dart';
import 'level.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:mindfulAlert/splashScreen.dart';
import 'introductoryScreen.dart';
import 'commondialogs.dart';

class StartApp extends StatefulWidget {
  StartApp () {

  }

  @override
  _StartAppState createState() => _StartAppState();
}
class _StartAppState extends State<StartApp> {
  static DateTime finalDate = DateTime.parse("2021-07-01 08:00:00");
  GlobalKey key = GlobalKey();
  int daysSinceInstall = finalDate.difference(DateTime.now()).inDays;

  @override
  void initState()  {
    super.initState();
    String title = "Welcome";
    String info =  "This fun Mindfulness App helps with exercising your alertness capability by allowing you to work on a task while being alert "
        "to the events sent to your vision, touch and hearing senses. \n\n"
        "For details on how to use the App, click on 'Test Details', after clicking anywhere on this dialog.";
    Timer(Duration(milliseconds: 200), () =>  Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) =>
            CommonDialogs.popupDialog(context, title, info))));
    }

  void displayOverlay (_StartAppState current) async {
    OverlayState overlayState = Overlay.of(current.key.currentContext);
    OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
            top: 24.0,
            right: 10.0,
            child: CircleAvatar(
              radius: 50.0, backgroundColor: Colors.red,
              child: Text("This is a large text message"),
            )
        ));
    overlayState.insert(overlayEntry);
    await Future.delayed(Duration(seconds: 2));
    overlayEntry.remove();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold (
        backgroundColor: Color(0xFF01579B) ,

        appBar: AppBar(centerTitle: true, title: Text("Alertness Exerciser"),),
        body: Column(
          key: key,
          children: [
            Expanded(
              flex: 1,
              child: Center(
                child: Text ('Please select a test', style: TextStyle( color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: Container(
                padding: EdgeInsets.all(10) ,
                decoration: BoxDecoration (
                    color: Colors.white,
                    border: Border.all(
                        color: Colors.black,
                        width: 5,
                        style: BorderStyle.solid
                    )
                ),
                child: Scrollbar(
                  isAlwaysShown: true,
                  thickness: 5,
                  child: GridView.builder(
                    itemCount: Level.maxLevels,
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    scrollDirection: Axis.vertical,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return FloatingActionButton.extended(
                        backgroundColor: (LevelHistory.levelHistory[index] == LevelHistory.complete) ? Colors.green :
                        (LevelHistory.levelHistory[index] == LevelHistory.notStarted) ? Colors.blue : Colors.yellowAccent,
                        elevation: 10,
                        onPressed: () async {
                          if (daysSinceInstall < 0) {
                            Widget okButton = TextButton(
                              child: Text(
                                  "Ok", style: TextStyle(color: Colors.white)),
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<
                                      Color>(Colors.black)),
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              },
                            );
                            await showDialog(context: context,
                                builder: (BuildContext context) {
                                  return
                                    AlertDialog(
                                      title: Center(
                                          child: Text("App has expired")),
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              18.0),
                                          side: BorderSide(
                                              color: Colors.black)),
                                      content: Text(
                                          ""),
                                      actions: [
                                        okButton,
                                      ],
                                    );
                                  ;
                                });
                          }
                          else {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) =>
                                    MyHomePage(
                                        title: "Exerciser",
                                        levelNumber: (index + 1)))).then((
                                value) => setState(() {}));
                          }
                        },
                        heroTag: 'thecontact$index',
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        label: Container(
                          alignment: Alignment.center,
                          color: Colors.transparent,
                          child: Center(
                            child: Column( crossAxisAlignment: CrossAxisAlignment.center , mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Test-${index + 1}',  style: TextStyle( color: Colors.black, decoration: TextDecoration.underline, fontWeight: FontWeight.bold),),
                                Text('Size-${Level.getPuzzleComplexity(index + 1)}', style: TextStyle( color: Colors.black, fontSize: 10)),
                                Text('Events-${Level.getNumberOfEvents(index + 1)}' , style: TextStyle( color: Colors.black, fontSize: 10)),
                                Text('${LevelHistory.levelHistory[index]}', style: TextStyle( color: Colors.black, fontSize: 10))
                              ],
                            ),
                          ),
                          //decoration: BoxDecoration(
                          //color: Colors.blue,
                          //borderRadius: BorderRadius.circular(15)),
                        ),
                      );
                      // Text("${(levelData[index].levelNumber)} this is a long text test");
                    },
                  ),
                ),
                // child: ListView.builder(
                //   itemCount: levelData.length,
                //   itemBuilder: (context, index){
                //     return Card(
                //       child: ListTile(
                //         onTap: () { print("${(levelData[index].levelNumber)}"); },
                //         title: Text("${(levelData[index].levelNumber)} this is a long text test")
                //       )
                //     );
                //   },
                // ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text('Days left - ${daysSinceInstall}', style: TextStyle(color: Colors.red,
                  fontWeight: FontWeight.bold, fontSize: 30)),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: Row (
                  children: [
                    Expanded(
                      flex: 2,
                      child: FloatingActionButton.extended(
                          label: Column(
                            children: [
                              Text("Scores"),
                              Text("History"),
                            ],
                          ),
                          backgroundColor: Colors.blue,
                          heroTag: 'contact12345',
                          onPressed: () {
                            Navigator.pushNamed(context, '/Scores');
                          }
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: FloatingActionButton.extended(
                          label: Column(
                            children: [
                              Text("Test"),
                              Text("Details"),
                            ],
                          ),
                          backgroundColor: Colors.blue,
                          heroTag: 'contact2',
                          onPressed: () {
                            Navigator.pushNamed(context, '/InstructionsScreen');
                          }
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: FloatingActionButton.extended(
                          label:  Column(
                            children: [
                              Text("Clear"),
                              Text("History"),
                            ],
                          ),
                          backgroundColor: Colors.blue,
                          heroTag: 'contact22',
                          onPressed: () {
                            setState(() {
                              CommonDialogs.yesNoDialog(context,
                                  "Do you really want to clear  the level history?",
                                      () {setState(() { LevelHistory.clearLevelHistory();
                                  Navigator.of(context, rootNavigator: true).pop();
                                  });
                                  });
                            });
                          }
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
    );
  }
}
