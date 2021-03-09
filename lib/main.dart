import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'piece.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'lights.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vibColumn.dart';
import 'dart:math';
import 'level.dart';
import 'dart:core';
import 'choreographer.dart';
import 'package:flutter_is_emulator/flutter_is_emulator.dart';
import 'package:auto_size_text/auto_size_text.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.getStorage();
  runApp(MindfullnessAlertExcerciserApp());
}

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override void initState() async {
//     theStorage = await SharedPreferences.getInstance();
//     Scores.items = await theStorage.getStringList(Scores.storageKey);
//     if (theStorage == null) {
//       print("It is null");
//     } else {
//       print("It is not null");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//         // This makes the visual density adapt to the platform that you run
//         // the app on. For desktop platforms, the controls will be smaller and
//         // closer together (more dense) than on mobile platforms.
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: MyHomePage(title: 'Mindfull Application', levelNumber: 1,),
//     );
//   }
// }

class MyHomePage extends StatefulWidget {
  final String title;
  final int levelNumber;
  _MyHomePageState state;
  bool displayResultsNow = false;


  MyHomePage ({ this.title, this.levelNumber}){
    print ('Level number is $levelNumber');
    print("Initializtion has taken place");
  }

  void dispose () {
  }

  @override
  _MyHomePageState createState() {
    state = _MyHomePageState();
    return state;
  }
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  Image backgroundImage;
  GlobalKey puzzleKey = GlobalKey();
  GlobalKey vibSoundCorridorKey = GlobalKey();
  GlobalKey lightCorridorKey = GlobalKey();
  GlobalKey stackKey = GlobalKey();
  Completer layoutCompleted = Completer();
  Completer puzzleSizeCompleted = Completer();
  Completer timerBarCompleted = Completer();
  Completer<ui.Size> lightCorridorSizeCompleted = Completer<ui.Size>();
  Completer<ui.Size> vibSoundCorridorSizeCompleted = Completer<ui.Size>();
  ui.Size imageSize;
  Uint8List byteList;
  AudioCache audioCache = AudioCache();
  AudioPlayer audioPlayer;
  bool isPlaying = false;
  bool isPaused = false;
  double timerBarValue = 0.0;
  double timerBarTotalValue = 1000.0;
  GlobalKey timerKey = new GlobalKey();
  ui.Size timerBarSize;
  String  lastResult = 'No completed run';
  String  timeRemaining = '120';
  String  puzzleCompletion = '100%';
  String  lightCount = '0/0';
  String  vibrationCount = '0/0';
  String  soundCount = '0/0';
  String  gameStatus = 'Start the test';
  int rows = 0;
  int cols = 0;
  int lightRate = 0;
  int vibrationRate = 0;
  int soundRate = 0;
  LightCorridor lightCorridor;
  VibSoundCorridor vibSoundCorridor;
  List<Piece> pieces = [];
  List<Light> lightPieces = [];
  List<VibSoundButton> vibSoundButtons = [];
  Size lightCorridorSize;
  Size vibSoundCorridorSize;
  Choreographer choreography;
  List<Piece> lowerPieces;
  bool needToReshuffle = true;


    void setPuzzleCompletion(int completedPieces, int totalPieces) {
      setState(() {
        double ratio = completedPieces * 100 / totalPieces;
        puzzleCompletion = ratio.toInt().toString();
      });
    }

    void setTimeRemaining (int numSeconds) {
      setState(() {
        timeRemaining = numSeconds.toString();
      });
    }

    void setLightCount (int correctClicks, int totalClicks) {
      setState(() {
        lightCount = '$correctClicks / $totalClicks';
      });
    }

    void setVibrationCount (int correctClicks, int totalClicks) {
      setState(() {
        vibrationCount = '$correctClicks / $totalClicks';
      });
    }

    void setSoundCount (int correctClicks, int totalClicks) {
      setState(() {
        soundCount = '$correctClicks / $totalClicks';
      });
    }

    // setState(() {
    //   if (isPaused) {
    //     isPlaying = false;
    //     isPaused = false;
    //   } else {
    //     isPlaying = !isPlaying;
    //   }
    // });

  Future<void> layoutIsInProgress() {
    return layoutCompleted.future;
  }

  void layoutCompletedNow() {
    print("Layout completed");
    layoutCompleted.complete();
  }

  _afterLayout(_) {
    layoutCompletedNow();
  }

  _MyHomePageState() {
      WidgetsBinding.instance.addPostFrameCallback(_afterLayout);

    print("Layout callback installed");
  }

  void bringToTop(Piece curWidget) {
    setState(() {
      pieces.remove(curWidget);
      pieces.add(curWidget);
    });
  }

  void sendToBack(Piece curWidget) {
    setState(() {
      pieces.remove(curWidget);
      pieces.insert(0, curWidget);
    });
  }

  void updateState(VoidCallback safeFunction) {
    setState(() {
      safeFunction();
      pieces = pieces;
    });
  }

  Future getImageSize(Image image) {
    print("Started getImageSize");
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          layoutCompleted.complete(size);
        },
      ),
    );
    return layoutCompleted.future;
  }

  Future<Image> createImageFromFile(String fileName, Size destSize) async {
    ByteData byteData =
        await rootBundle.load('packages/mindfulAlert' + fileName);
    List<int> bytes = Uint8List.view(byteData.buffer);
    ui.Image image = await decodeImageFromList(bytes);

    imageSize = Size(image.width.toDouble(), image.height.toDouble());
    double xFactor = imageSize.width / destSize.width;
    double yFactor = imageSize.height / destSize.height;
    double factor = (xFactor > yFactor) ? yFactor : xFactor;

    Image image2 = Image(
        image: ResizeImage(MemoryImage(bytes),
            width: (image.width / factor).toInt(),
            height: (image.height / factor).toInt()));
    //Image image2 = Image ( image: ResizeImage( MemoryImage(bytes), width: (image.width).toInt(), height: (image.height).toInt()));
//    Image image1 = Image(image: image2,)

    // Rect src, dst;
    // src = Rect.fromLTWH(0.0, 0.0, image.width/factor, image.height/factor);
    // dst = Rect.fromLTWH(0.0, 0.0, destSize.width, destSize.height);
    //
    // var pictureRecorder = new ui.PictureRecorder();
    // ui.Canvas canvas = new ui.Canvas(pictureRecorder);
    // canvas.drawImageRect(image, src, dst, Paint());
    // ui.Image image3 = await pictureRecorder.endRecording().toImage(dst.width.floor(), dst.height.floor());

    // //ImagePicker
    //
    // ByteData newByteData = await image3.toByteData();
    // List<int> newBytes = byteList = Uint8List.view(newByteData.buffer);
    // return Image.memory(newBytes,
    //       scale: 1.0,
    //       width: destSize.width,
    //       height: destSize.height,
    //       repeat: ImageRepeat.noRepeat);
    return image2;
  }

  //
  //
  // // print ("The length of bytes are ${ bytes.length}");
  // // ui.Codec codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List());
  // // ui.FrameInfo fi = await codec.getNextFrame();
  // // int width = fi.image.width;
  // // int height = fi.image.height;
  // // img.Image image = img.Image.fromBytes(width, height, bytes, format: img.Format.rgba);
  //
  // //img.Image image = img.decodeImage(());
  // //List<int> decodeBytes = image.getBytes();
  // // imageSize = Size(fi.image.width.toDouble(), fi.image.height.toDouble());
  //
  //  // Scale image
  // imageSize = Size(image.width.toDouble(), image.height.toDouble());
  // double xFactor = imageSize.width / destSize.width ;
  // double yFactor = imageSize.height / destSize.height;
  // double factor = (xFactor > yFactor) ? yFactor : xFactor;
  // // img.Image image1 = img.copyResize(image, width: (imageSize.width/factor).toInt(), height: ((imageSize.height)/factor).toInt(), interpolation: img.Interpolation.average);
  // // imageSize = Size(image1.width.toDouble(), image1.height.toDouble());
  // // img.Image image3 = img.copyCrop(image1, 0, 0,  (destSize.width/2.0).toInt(), (destSize.height/2.0).toInt());
  // // imageSize = Size(image3.width.toDouble(), image3.height.toDouble());
  //  byteList = bytes = image.getBytes(format: img.Format.rgb);
  // return Image.memory(bytes,
  //     scale: 1.0,
  //     width: destSize.width,
  //     height: destSize.height,
  //     repeat: ImageRepeat.noRepeat);

  Uint8List createImage(int width, int height) {
    img.Image image = img.Image(width, height);
    img.fill(image, img.getColor(0, 0, 255));
    img.drawString(image, img.arial_24, 0, 0, 'Hello World');
    img.drawLine(image, 0, 0, (width * 2 / 3).toInt(), (height * 2 / 3).toInt(),
        img.getColor(255, 0, 0),
        thickness: 3);
    img.drawRect(image, (width / 10).toInt(), (height / 10).toInt(),
        (width / 3).toInt(), (height / 2).toInt(), img.getColor(64, 124, 88));
    img.gaussianBlur(image, 10);
    List<int> png = img.PngEncoder().encodeImage(image);
    Uint8List byteList = Uint8List.fromList(png);

    return byteList;
  }

  void drawScenery1(img.Image image) {
    int width = image.width;
    int height = image.height;
  }

  Future<void> getPuzzleSize() {
    if (puzzleKey.currentContext != null) {
      puzzleSizeCompleted.complete();
    }
    return puzzleSizeCompleted.future;
  }

  Future<void> getLightCorridorSize() {
    if (lightCorridorKey.currentContext != null) {
      lightCorridorSizeCompleted.complete();
    }
    return lightCorridorSizeCompleted.future;
  }

  Future<void> getVibSoundCorridorSize() {
    if (vibSoundCorridorKey.currentContext != null) {
      vibSoundCorridorSizeCompleted.complete();
    }
    return vibSoundCorridorSizeCompleted.future;
  }

  Future<void> getTimerBarSize() {
    if (timerKey.currentContext != null) {
      timerBarCompleted.complete();
    }
    return timerBarCompleted.future;
  }

  // here we will split the image into small pieces using the rows and columns defined above; each piece will be added to a stack
  void splitImage() async {
    await layoutIsInProgress();
    await getPuzzleSize();
    await getLightCorridorSize();
    await getVibSoundCorridorSize();
    await getTimerBarSize();

    Size puzzleSize;
    setState(() {
      puzzleSize = puzzleKey.currentContext.size;
      lightCorridorSize = lightCorridorKey.currentContext.size;
      vibSoundCorridorSize = vibSoundCorridorKey.currentContext.size;
      timerBarSize = timerKey.currentContext.size;
      print(
          'The corridor height is ${lightCorridorSize.height}, puzzle height is ${puzzleSize.height}');
      print('The soundVib height is ${vibSoundCorridorSize.height} ');
      lightCorridor = LightCorridor(
        lightCorridorSize,
        6,
        updateState,
      );

      vibSoundCorridor = VibSoundCorridor(
        vibSoundCorridorSize,
        6,
        updateState,
      );
    });

    choreography = Choreographer(lightCorridor: lightCorridor, vibSoundCorridor: vibSoundCorridor, homePage: widget);

    backgroundImage =
        await createImageFromFile("/assets/images/files/cat.png", puzzleSize);
    double height = (puzzleSize.height.toInt()) /
        2; //Transform widget = Transform.scale(scale: 2.0, child: Image.memory(byteList));

    //Add Light pieces.
    lightPieces.addAll(lightCorridor.getList());
    vibSoundButtons.addAll(vibSoundCorridor.getList());

    double xScale = imageSize.width / puzzleSize.width;
    double yScale = imageSize.height / (puzzleSize.height/2);
    double xCenterOffset = (xScale > yScale) ? 0.0 : (puzzleSize.width - imageSize.width/yScale)/2;
    Size pieceSize = Size(puzzleSize.height*imageSize.width/ (imageSize.height*cols), puzzleSize.height / rows);
    Piece piece1, piece2;
    List<Piece> tempList2 = [];
    int index;

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        index = x  + y*cols;
/*        piece1 = Piece(
            key: GlobalKey(),
            image: backgroundImage,
            imageSize: imageSize,
            puzzleSize: Size(puzzleSize.width, puzzleSize.height / 2.0),
            yOffset: 0.0,
            row: y,
            col: x,
            maxRow: rows,
            maxCol: cols,
            bringToTop: bringToTop,
            sendToBack: sendToBack,
            updateState: updateState,
            xCenterOffset: xCenterOffset,
            pieceSize: pieceSize,
            backgroundImage: false,
            filter: true);
*/
        piece2 = Piece(
            key: GlobalKey(),
            image: backgroundImage,
            imageSize: imageSize,
            puzzleSize: Size(puzzleSize.width, puzzleSize.height / 2.0),
            yOffset: puzzleSize.height / 2,
            row: y,
            col: x,
            maxRow: rows,
            maxCol: cols,
            bringToTop: bringToTop,
            sendToBack: sendToBack,
            updateState: updateState,
            xCenterOffset: xCenterOffset,
            pieceSize: pieceSize,
            backgroundImage: false,
            filter: false);
//        pieces.add(piece1);
        tempList2.add(piece2);
      }
    }

    pieces.add(Piece(
        key: GlobalKey(),
        image: backgroundImage,
        imageSize: imageSize,
        puzzleSize: Size(puzzleSize.width, puzzleSize.height / 2.0),
        yOffset: 0.0,
        row: 0,
        col: 0,
        maxRow: rows,
        maxCol: cols,
        bringToTop: bringToTop,
        sendToBack: sendToBack,
        updateState: updateState,
        xCenterOffset: xCenterOffset,
        pieceSize: pieceSize,
        backgroundImage: true,
        filter: true));


    tempList2.shuffle(Random(DateTime.now().second));
//    double extraSpace =
//        2.0 * pieces[0].xCenterOffset / (cols - 1);
    for (int y = 0; y < rows; y++) {
        for (int x = 0; x < cols; x++) {
          int index = x  + y*cols;
          tempList2[index].left += ((x - tempList2[index].col) * tempList2[index].pieceSize.width/2);
          tempList2[index].top += ((y - tempList2[index].row) * tempList2[index].pieceSize.height/2);
      }
    }

//    print ("Extra space is $extraSpace");

    pieces.addAll(tempList2);

    pieces.forEach((eachPiece) {eachPiece.setOrgPosition(); });
    pieces.forEach((element) {element.setItInactive();});

    choreography.setPieces (pieces);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    print("Screen width is $screenWidth, $screenHeight");


    setState(() {
      pieces = pieces;
    });

    print("image size is ${imageSize.width} and height is ${imageSize.height}");
    print("Size of pieces at this point is ${pieces.length}");
  }

  @override
  void initState() {
    List<String> puzzleComplexity = Level.getPuzzleComplexity(widget.levelNumber).split('x');
    rows = int.parse(puzzleComplexity[0]);
    cols = int.parse(puzzleComplexity[1]);
    lightRate = Level.getEventComplexity(widget.levelNumber);
    vibrationRate = Level.getEventComplexity(widget.levelNumber);
    soundRate = Level.getEventComplexity(widget.levelNumber);

    //Size puzzleSize = puzzleKey.currentContext.size;
    splitImage();
    // _assetsAudioPlayer = AssetsAudioPlayer();
    // _assetsAudioPlayer.open(
    //     Audio(
    //         "assets/sound/win.mp3")
    // );

    super.initState();
  }

  void showMessageDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          backgroundColor: Colors.black87,
          content: Text ('Please wait'),
        );
      },
    );
  }

  void dispose () {
    super.dispose();
    print ("dispose is called");
  }

  // void shuffleLowerPieces ()
  // {
  //   setState(() {
  //     List<Piece> lowerPieces = List<Piece>();
  //     List<Piece> upperPieces = List<Piece>();
  //     int length = pieces.length;
  //
  //     double extraSpace = 2.0 * pieces[0].xCenterOffset / (cols - 1);
  //
  //     //remove the bottom half
  //     int limit = ((length/2)-1).toInt()+1;
  //     upperPieces = pieces.sublist(0, limit);
  //     lowerPieces = pieces.sublist(limit);
  //     lowerPieces.shuffle();
  //     for (int x = 0; x < cols; x++) {
  //       for (int y = 0; y < rows; y++) {
  //         int index = x * rows + y;
  //         lowerPieces[index].initLeft = lowerPieces[index].xCenterOffset + ((x - lowerPieces[index].col) * lowerPieces[index].pieceSize.width - lowerPieces[index].xCenterOffset) + x * extraSpace;
  //         lowerPieces[index].initTop  = (y - lowerPieces[index].row) * lowerPieces[index].pieceSize.height + lowerPieces[index].puzzleSize.height / 2;
  //       }
  //     }
  //     upperPieces.addAll(lowerPieces);
  //     pieces = upperPieces;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    widget.state = this;
    if (pieces != null) {
      print("size of pieces is ${pieces.length}");
    }

    return WillPopScope (
      onWillPop: ()  {
        if (choreography.isReady()) {
          setState(() {
          });
          return Future.value(true);
        }
        else
          return Future.value(false);
      },
      child: Scaffold(
          appBar: AppBar(
            //Here we take the value from the MyHomePage object that was created by
            //the App.build method, and use it to set our appbar title.
            title: Text(widget.title),
          ),
          body: Container(
            color: Colors.black,
            child: SafeArea(
              child: Container(
                decoration: new BoxDecoration(
                    gradient: new LinearGradient(
//                    colors: [const Color(0xFF000046), const Color(0xFF1CB5E0)],
                        colors: [Colors.indigo, Colors.black, Colors.black],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft)),
                child: Column(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Row(
                            key: timerKey,
                            children: [
                              Expanded(flex: 3, child: Column( children: [
                                Text('Comp %',style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
                                Text('$puzzleCompletion', style: TextStyle(color: Colors.white),)])),
                              Expanded(flex: 3, child: Column( children: [
                                Icon(Icons.lightbulb, color: Colors.yellow),
                                Text('$lightCount', style: TextStyle(color: Colors.white),)])),
                              Expanded(flex: 3, child: Column( children: [
                                Icon(Icons.vibration, color: Colors.yellow),
                                Text('$vibrationCount', style: TextStyle(color: Colors.white),)])),
                              Expanded(flex: 3, child: Column( children: [
                                Icon(Icons.music_note, color: Colors.yellow),
                                Text('$soundCount', style: TextStyle(color: Colors.white))])),
                            ]
                        )
                    ),
                    Expanded(
                      flex: 18,
                      child: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              key: lightCorridorKey,
                              child: Stack(
                               children: [
                              Positioned(
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                   children: [
                                     Text("  Level", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 15)),
                                     Text("  ${widget.levelNumber}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                   ],
                                 ),
                              ),
                                 Positioned(child: Stack(children: lightPieces)),
                               ],
                              ),
                              ),
                          Expanded(
                              key: puzzleKey,
                              flex: 8,
                              child: Stack(children: pieces)),
                          Expanded(
                              key: vibSoundCorridorKey,
                              flex: 2,
                              child: Stack(
                                children: [
                                  Positioned(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text("Secs", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 15)),
                                        Text("$timeRemaining", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    child: Stack(children: vibSoundButtons)),]
                              )),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Spacer(flex: 1),
                          Text('Last Result: ${(choreography != null) ? choreography.getResultString(): 'No test run'}', style: TextStyle(color: Colors.white)),
                          Spacer(flex: 1),
                          FloatingActionButton.extended(onPressed: () async {
                            bool simulator = await FlutterIsEmulator.isDeviceAnEmulatorOrASimulator;
                            print ("The simulator is active $simulator");
                            if (await Vibration.hasVibrator() || simulator) {
                              if (choreography.isReady()) {
                                choreography.setStatusToProgress();
                              } else if (choreography.isProgressing()) {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                          title: Column(),
                                          content: Text(
                                              "Do you really want to cancel?"),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text("Yes"),
                                              onPressed: () {
                                                choreography.setStatusToReady(
                                                    false);
                                                Navigator.of(context,
                                                    rootNavigator: true).pop();
                                                Navigator.of(context,
                                                    rootNavigator: true).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: Text("No"),
                                              onPressed: () {
                                                Navigator.of(context,
                                                    rootNavigator: true).pop();
                                              },
                                            )
                                          ]
                                      );
                                    }
                                );
                              }
                            } else {
                              Widget okButton = TextButton(
                                child: Text("Ok", style: TextStyle(color:Colors.white)),
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.black)),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true).pop();
                                }
                              );
                              AlertDialog alert = AlertDialog(
                                backgroundColor: Colors.lightBlueAccent,
                                shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(color: Colors.black)
                              ),
                              title: Text('Needs vibration capability'),
                              //content: Container(color: Colors.blue, child: Text("")),
                              actions: [
                                okButton,
                              ],
                              );
                              await showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                              return alert;
                              });
                            }
                          },
                            label: Text('$gameStatus'), //shape: RoundedRectangleBorder(),
                          ),
                          Spacer(flex: 1)
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }
}

showAlertDialog (BuildContext context) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text("Yes"),
    onPressed:  () {},
  );
  Widget continueButton = TextButton(
    child: Text("No"),
    onPressed:  () {},
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("AlertDialog"),
    content: Text("Do you really want to cancel?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  // show the dialog
}

class MindfullnessAlertExcerciserApp extends StatefulWidget {

  MindfullnessAlertExcerciserApp();

  @override
  _MindfullnessAlertExcerciserAppState createState() => _MindfullnessAlertExcerciserAppState();
}

class _MindfullnessAlertExcerciserAppState extends State<MindfullnessAlertExcerciserApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp (
      home: StartApp(),
      routes: <String, WidgetBuilder> {
        '/InstructionsScreen' : (context) => Instructions(),
        '/AlertGameScreen' : (context) => MyHomePage(title: "Alertness Exerciser"),
        '/Scores': (context) => Scores()
    }
    );
  }
}

class LevelData {
  final int levelNumber;
  final String puzzleComplexity;
  final int eventComplexity;
  LevelData ({this.levelNumber, this.puzzleComplexity, this.eventComplexity});
}

class LevelHistory {
  static const int maxLevel = 21;
  static const String incomplete = 'Time';
  static const String complete = 'Done';
  static const String notStarted = '';
  static const String levelHistoryKey = 'LevelHistory';
  static List<String> levelHistory;
  static void loadLevelHistory () async {
    if (levelHistory == null) {
      await Storage.getStorage();
      levelHistory = Storage.storage.getStringList(levelHistoryKey);
      if (levelHistory == null) {
        levelHistory = [];
        for (int i = 0; i < maxLevel; i++) {
          levelHistory.add(notStarted);
        }
        Storage.storage.setStringList(levelHistoryKey, levelHistory);
      }
    }
  }

  static void clearLevelHistory()
  {
    levelHistory = [];
    for (int i = 0; i < maxLevel; i++) {
      levelHistory.add(notStarted);
    }
    Storage.storage.setStringList(levelHistoryKey, levelHistory);
  }

  static void updateLevelHistory(int levelNumber, String status) {
    print ('update request $levelNumber $status' );
    loadLevelHistory();
    levelHistory[levelNumber-1] = status;
    Storage.storage.setStringList(levelHistoryKey, levelHistory);
    int indexer = 1;
    levelHistory.forEach((element) {
      print ('Level history $indexer is $element');
      indexer++;
    });
  }
}

// setState(() {
// LevelHistory.clearLevelHistory();
// Navigator.of(context, rootNavigator: true).pop();
// });

class CommonDialogs {
  static void yesNoDialog (BuildContext context, String question, Function action) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Column(),
              content: Text(
                  question),
              actions: <Widget>[
                TextButton(
                  child: Text("Yes"),
                  onPressed: () {
                    action();
                  },
                ),
                TextButton(
                  child: Text("No"),
                  onPressed: () {
                    Navigator.of(context,
                        rootNavigator: true).pop();
                  },
                )
              ]
          );
        }
    );
  }


}
class StartApp extends StatefulWidget {
  StartApp () {

  }

  @override
  _StartAppState createState() => _StartAppState();
}
class _StartAppState extends State<StartApp> {

  @override
  void initState() {
    LevelHistory.loadLevelHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold ( backgroundColor: Color(0xFF01579B) ,
      appBar: AppBar(title: Text("Alertness Exerciser"),),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Text ('Please select a level', style: TextStyle( color: Colors.white, fontSize: 20),
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
                  itemCount: 21,
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
                        bool simulator = await FlutterIsEmulator.isDeviceAnEmulatorOrASimulator;
                        if (await Vibration.hasVibrator() || simulator) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) =>
                                  MyHomePage(
                                      title: "Exerciser",
                                      levelNumber: (index + 1)))).then((value) => setState(() {}));
                        }
                        else {
                          Widget okButton = TextButton(
                            child: Text("Ok", style: TextStyle(color:Colors.white)),
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.black)),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                          );
                          AlertDialog alert = AlertDialog(
                            backgroundColor: Colors.lightBlueAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(color: Colors.black)
                            ),
                            title: Text('Needs vibration capability'),
                            //content: Container(color: Colors.blue, child: Text("")),
                            actions: [
                              okButton,
                            ],
                          );
                          await showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return alert;
                              });
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
                              FittedBox(fit: BoxFit.cover, child: Text('Level-${index + 1}',  style: TextStyle( color: Colors.black, decoration: TextDecoration.underline, fontWeight: FontWeight.bold),)),
                              FittedBox(fit: BoxFit.cover, child: Text('Size-${Level.getPuzzleComplexity(index + 1)}', style: TextStyle( color: Colors.black))),
                              FittedBox(fit: BoxFit.cover, child: Text('Events-${Level.getEventComplexity(index + 1)}' , style: TextStyle( color: Colors.black))),
                              FittedBox(fit: BoxFit.cover, child: AutoSizeText('${LevelHistory.levelHistory[index]}', style: TextStyle( color: Colors.black, fontSize: 10)))
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
                            Text("Play"),
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
                            Text("Reset"),
                            Text("Levels"),
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

class Instructions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Instructions will come here"),)
    );
  }
}

class Storage {
  static SharedPreferences storage = null;
  static List<String> items = [];

  static Future<SharedPreferences> getStorage() async {
    if (storage == null) {
      storage = await SharedPreferences.getInstance();
    }
    return storage;
  }

  static List<String> getList(String key) {
    items = storage.getStringList(key);
    return items;
  }
}

class Scores extends StatefulWidget {
  static const int size = 20;
  static const String storageKey = 'Scores';
  static String getItem(int index)  {
    List<String> items = getList();
    return items[index];
  }

  static List<String> getList() {
    List<String> items =  Storage.getList(storageKey);
    if (items == null) {
      return [];
    }
    return items;
  }

  static void clearScores() {
    Storage.storage.setStringList(storageKey, []);
  }

  static void addString (String item) async {
    print ('addString request for $item');
      List<String> items = await getList();
      items.add(item);
      if (size == items.length) {
        items.removeLast();
      }
      Storage.storage.setStringList(storageKey, items);
  }

  @override
  _ScoresState createState() => _ScoresState();
}

class _ScoresState extends State<Scores> {

  @override
  Widget build(BuildContext context)  {
    return Scaffold(
        appBar: AppBar(title: Text("Scores", style: TextStyle(color:Colors.indigo)),),
        body: Column (
    children: [
     Expanded(
       flex: 20,
       child: SafeArea(
         child: Container(
           decoration: BoxDecoration (
               color: Colors.white,
               border: Border.all(
                 color: Colors.black,
                 width: 4,
               )
           ),         child: ListView.builder(
           itemCount: (Scores.getList().length),
           itemBuilder: (context, index) {
             return Card(color: Colors.lightBlue,
                 borderOnForeground: true,
                 child: ListTile(isThreeLine: true,
                     subtitle: Text("${Scores.getList()[index].split('?')[0]}"),
                     title: Text("${Scores.getList()[index].split('?')[1]}",
                         style: TextStyle(color:Colors.white))));
           }),
         ),
       ),
     ),
      Expanded(flex: 1, child: Visibility(
        visible: ((Scores.getList().length > 0) ?  true: false),
        child: FloatingActionButton.extended(
            heroTag: 'thecontact33',
            onPressed: () {
                setState(() {
                  CommonDialogs.yesNoDialog(context,
                      "Do you really want to clear  the scores?",
                          () {setState(() { Scores.clearScores();
                      Navigator.of(context, rootNavigator: true).pop();
                      });
                    });
              });
            }, label: Text('Clear Scores')),

      )),
      Spacer(flex: 1)
    ]
     ));
  }
}

class GameArguments {
  final levelNumber;
  GameArguments(this.levelNumber);
}

// Stack(
//   children: [
//     Positioned(
//       child: Container(
//         width: (timerBarSize == null)? 10 : timerBarSize.width * 0.80,
//         height: (timerBarSize == null)? 10: timerBarSize.height,
//         decoration: BoxDecoration( image: DecorationImage(image: AssetImage('assets/images/files/progressBar.png'), fit: BoxFit.fill)))
//       ),
//     Positioned(
//       child: Container(
//       width: (timerBarSize == null)? 10 : timerBarSize.width*timerBarValue*0.80/(timerBarTotalValue),
//       height: (timerBarSize == null)? 10: timerBarSize.height,
//           decoration: BoxDecoration( image: DecorationImage(image: AssetImage('assets/images/files/progressBarInc.png'), fit: BoxFit.fill)))
//     ),
//   ],
// )
// debugPrint('FAB clicked');
// Navigator.push(context, MaterialPageRoute(builder: (context) {
//   return Container(
//     child: FloatingActionButton(onPressed: () {
//       debugPrint('FAB clicked - Poped');
//       Navigator.pop(context);
//     }),
//   );
// }));

/*
/*                        child: Container(
                          child: Column(children: [
                            Expanded(
                                child: RaisedButton(
                              onPressed: () async {
                                playHandler();
                                if (await Vibration.hasVibrator()) {
                                  print(
                                      'audio player has vibration capability');
                                  Vibration.vibrate();
                                } else {
                                  print('audio player');
                                }
                              },
                              child: Text("Sound"),
                              color: Colors.blue,
                              textColor: Colors.white,
                            )),
                            Expanded(
                                child: RaisedButton(
                              onPressed: () {
                                Vibration.vibrate(duration: 5000);
                                print('vibrate');
                              },
                              child: Text("Vibrate"),
                              color: Colors.deepPurple,
                              textColor: Colors.white,
                            ))
                          ]),
                        )),*/

 */