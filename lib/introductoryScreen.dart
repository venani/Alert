
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:mindfulAlert/levelhistory.dart';
import 'startapp.dart';

class IntroductoryScreen extends StatefulWidget {

  @override
  _IntroductoryScreenState createState() => _IntroductoryScreenState();
}

class _IntroductoryScreenState extends State<IntroductoryScreen> {

  List<PageViewModel> getPages() {
    String body = 'A key aspect of being mindful is paying attention to your mind and senses. '
        'This app simulates that experience by giving a task to keep the mind busy and while the task is going on, '
        'you will tasked with paying attention to your vision, hearing and touch senses. \n\nThe task is to put a puzzle back together, '
        'while paying attention to the events associated with the senses, light for the vision sense, music for the '
        'hearing sense and vibration for the touch sense. To required feedback to acknolwledge that one has paid attention, '
        'to an event is by clicking on the respective button: ';
    String body1 = '\nlight button - , ';
    String body2 = '\nsound button -  ';
    String body3 = '\nand vibration button - ';
    String body4 =   '\n\nThere is time limit within which the puzzle should be put back together.'
        'The goal is to complete the puzzle within the alloted time and to not miss the events i.e. clicking '
        'the buttons in a timely manner, within two seconds of the event occuring. The Test will complete either when '
        'the puzzle has been completed or when the alloted time has run out. The user can also cancel at any time.';
    String body5 =     '\nPuzzles to be solved vary in complexity from 2x2 to 6x5 and the number of events to pay attention '
        'to also change starting from 4 to 50. Each combination of a puzzle and a set of events is called a Test. More '
        'often than not the higher the Test number the more the difficult the Test is but that might not always be true as '
        'sometimes a lower numbered Test might be more challenging.';
    String body8 = 'Below is an example of the Test Selection Screen, in which each box represents a test. Each box contains:';
    String body9 = '\n-Test Number\n-Size of the puzzle\n-Number of events\n-Status\n ';
    String body10 = '\n\nThe Status is the status of the last attempt when running the test, it is '
                    'colored ';
        String body101 = 'Blue when it has not been run, Green when it has been successfuly completed and Yellow when the'
                    ' test has not been succesfully completed. \n\nTo start a test, click on a box of the desired test.'
                    ' The screen changes to the ';
    String body11 = 'Test Exerciser Screen';
    String body110 = '\nBlue';
    String body111 = '-Test (New) has not been started.';
    String body112 = '\nYellow';
    String body113 = '-Test (Incomplete), not completed.';
    String body114 = '\nGreen';
    String body115 = '-Test (Done), completed.';
    String body116 = '\n\nPlease make sure that Vibration has been enabled in Settings.';

    String body12 = 'Below is an example of the above sreen. ';
    String body13 = '\n\nTo start the test, click on the button at the bottom.'
    'As the puzzle pieces are moved back into position , the Comp% field is updated to reflect the percent completed.'
    ' The "Secs" field flashes the time remaining.\n\n';
    String body14 = ' While the puzzle pieces are being attended to, the following events can be observed: lights being lit up, the vibration activated and '
    'music being played.\nAs these events occur, the associated buttons given below should be clicked within two seconds of the event occuring, for it to be recognized.\n';
    String body15 = '\nAs the buttons are clicked the associated field in the top row gets updated. The information displayed is of the form: \n';
    String body16 = '5/12';
    String body17 = 'The numerator stands for the number of user clicks made in a timely manner i.e. within two seconds of the event occuring and the denominator'
        ' stands for the total of events that have occured. Using the above example 7 (12 - 5) clicks have been missed.'
        'Only one puzzle piece can be worked on at a time.';
    String body18 = '\nScores History';
    String body19 = ': Lists the last 50 results of the tests.';
    String body20 = '\n\Clear History';
    String body21 = ': Removes the history maintained of the Tests that were run .';

        return [
      PageViewModel(title: 'Theory',
          bodyWidget: RichText(text: TextSpan( style: TextStyle(color: Colors.black),
          children: [
            TextSpan(text: body),
            TextSpan(text: body1, style: TextStyle(fontWeight: FontWeight.bold)),
            WidgetSpan (child: Icon(Icons.lightbulb, color: Colors.black)),
            TextSpan(text: body2, style: TextStyle(fontWeight: FontWeight.bold)),
            WidgetSpan (child: Icon(Icons.music_note, color: Colors.black)),
            TextSpan(text: body3, style: TextStyle(fontWeight: FontWeight.bold)),
            WidgetSpan (child: Icon(Icons.vibration, color: Colors.black)),
            TextSpan(text: body4)
          ]),
          textAlign: TextAlign.left )),
      PageViewModel(title: 'Theory (continued)',
          bodyWidget:  RichText(text: TextSpan( style: TextStyle(color: Colors.black),
          children: [
          TextSpan(text: body5),
        ]),
      )),
      PageViewModel(title: 'Test Selection Screen',
          bodyWidget:  RichText(text: TextSpan( style: TextStyle(color: Colors.black),
          children: [
          TextSpan(text: body8),
          TextSpan(text: body9, style: TextStyle(fontWeight: FontWeight.bold)),
          WidgetSpan (child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,children: [
                Image(image:AssetImage('assets/images/files/TestSelectionScreen.png'), width: 200)],
            )),
            ),
            TextSpan(text: body10),
            TextSpan(text: body11, style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: body110, style: TextStyle(backgroundColor: Colors.transparent, color: Colors.blue, fontWeight: FontWeight.bold)),
            TextSpan(text: body111),
            TextSpan(text: body112, style: TextStyle(backgroundColor: Colors.transparent, color: Colors.yellow, fontWeight: FontWeight.bold)),
            TextSpan(text: body113),
            TextSpan(text: body114, style: TextStyle(backgroundColor: Colors.transparent, color: Colors.green, fontWeight: FontWeight.bold)),
            TextSpan(text: body115),
            TextSpan(text: body116, style: TextStyle(backgroundColor: Colors.yellow, color: Colors.black, fontWeight: FontWeight.bold)),
    ]),
    )),

    PageViewModel(title: 'Test Exerciser',
            bodyWidget:  RichText(text: TextSpan( style: TextStyle(color: Colors.black),
            children: [
            TextSpan(text: body12),
              WidgetSpan (child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,children: [
                    Image(image:AssetImage('assets/images/files/TestExerciserScreen.png'), width: 200)],
                  ))),              TextSpan(text: body13),
            ]))),
      PageViewModel(title: 'Test Exerciser (continued)',
          bodyWidget:  RichText(text: TextSpan( style: TextStyle(color: Colors.black),
              children: [
                TextSpan(text: body14),
                WidgetSpan (child: FlatButton(
                  padding: const EdgeInsets.all(0.0), child: new Icon( Icons.lightbulb, color: Colors.black,),
                  shape: new CircleBorder(side: BorderSide(width: 3.0, color: Colors.black)),
                )),
                WidgetSpan (child: FlatButton(
                  padding: const EdgeInsets.all(0.0), child: new Icon( Icons.vibration, color: Colors.black,),
                  shape: new CircleBorder(side: BorderSide(width: 3.0, color: Colors.black)),
                )),
                WidgetSpan (child: FlatButton(
                  padding: const EdgeInsets.all(0.0), child: new Icon( Icons.music_note, color: Colors.black,),
                  shape: new CircleBorder(side: BorderSide(width: 3.0, color: Colors.black)),
                )),
                TextSpan(text: body15),
                WidgetSpan(
                  child: Center(child: Text(body16, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)))),
                TextSpan(text: body17),
                ]),
          )),
          PageViewModel(title: 'Remaining Functions',
              bodyWidget:  RichText(text: TextSpan( style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(text: body18, style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: body19),
                    TextSpan(text: body20, style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: body21),
                  ]),
              )),
    ];
  }

  @override
  void initState() {
//    Timer(Duration(milliseconds: 2000), () => Navigator.pop(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowMaterialGrid: false,
        home: Scaffold
          (
            body: SafeArea(
              child: IntroductionScreen(
                  done: Text(
                      'Done', style: TextStyle(fontWeight: FontWeight.w600)),
                  onDone: () {
                    Navigator.pop(context);
                  },
                  pages: getPages(),
                  skip: const Text('Skip'),
                  next: const Icon(Icons.arrow_forward),
                  showSkipButton: true,
                  showNextButton: true,
                  dotsFlex: 0,
                  // dotsDecorator: const DotsDecorator(
                  //   size: Size(10.0, 10.0),
                  //   color: Color(0xFFBDBDBD),
                  //   activeSize: Size(22.0, 10.0),
                  //   activeShape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  //   ),
                  // )
              ),
            )
        )
    );
  }
}
