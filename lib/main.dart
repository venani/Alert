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
import 'vibColumn.dart';
import 'dart:math';
import 'level.dart';
import 'dart:core';
import 'choreographer.dart';
import 'package:flutter_is_emulator/flutter_is_emulator.dart';
import 'startapp.dart';
import 'storage.dart';
import 'levelhistory.dart';
import 'introductoryScreen.dart';
import 'puzzleFile.dart';
import 'Scores.dart';
import 'package:image_crop/image_crop.dart';
import 'package:in_app_purchase/in_app_purchase.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  InAppPurchaseConnection.enablePendingPurchase;
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Storage.getStorage();
  await LevelHistory.loadLevelHistory();
  await PuzzleFiles.getLastSelection();
  PuzzleFiles.puzzleFiles.shuffle(Random(DateTime.now().second)) ;
  runApp(MindfullnessAlertExcerciserApp());
}

class MyHomePage extends StatefulWidget {
  final String title;
  final int levelNumber;
  _MyHomePageState state;
  bool displayResultsNow = false;


  MyHomePage ({ this.title, this.levelNumber}){
    print ('Level number is $levelNumber');
    print("Initializtion has taken place");
  }

  _MyHomePageState createState() {
    state = _MyHomePageState();
    return state;
  }

  void dispose () {
  }
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  Image backgroundImage;
  Image puzzleImage;
  GlobalKey puzzleKey = GlobalKey();
  GlobalKey vibSoundCorridorKey = GlobalKey();
  GlobalKey lightCorridorKey = GlobalKey();
  GlobalKey vibSoundLightKey = GlobalKey();
  GlobalKey stackKey = GlobalKey();
  Completer layoutCompleted = Completer();
  Completer puzzleSizeCompleted = Completer();
  Completer timerBarCompleted = Completer();
  Completer<ui.Size> lightCorridorSizeCompleted = Completer<ui.Size>();
  Completer<ui.Size> vibSoundCorridorSizeCompleted = Completer<ui.Size>();
  Color timeRemainingColor = Colors.transparent;
  bool timeRemainingStatus = false;
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
  String  puzzleCompletion = '0';
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

  void setBackgroundOpacity(double opacity) {
    pieces[0].state.setOpacity(opacity);
  }

  void setPuzzleCompletion(int completedPieces, int totalPieces) {
    double highOpacity = 1.00;
    double lowOpacity = 0.30;
    double curOpacity;
    double ratio = completedPieces * 100 / totalPieces;
    curOpacity = highOpacity - (highOpacity - lowOpacity)*(completedPieces/totalPieces);
    print ('Current opacity is $curOpacity');
    setBackgroundOpacity(curOpacity);
    setState(() {
      puzzleCompletion = ratio.toInt().toString();
    });
  }

  void clearTimeRemainingStatus() {
    timeRemainingStatus = false;
  }

    void setTimeRemaining (int numSeconds) {
      setState(() {
        if (timeRemainingStatus) {
          timeRemainingColor = Colors.red;
          timeRemainingStatus = false;
        } else {
          timeRemainingColor = Colors.transparent;
          timeRemainingStatus = true;
        }
        timeRemaining = numSeconds.toString().padLeft(6);
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
    ByteData byteData = await rootBundle.load('packages/mindfulAlert' + fileName);
    List<int> bytes = Uint8List.view(byteData.buffer);
    ui.Image image = await decodeImageFromList(bytes);
    imageSize = Size(image.width.toDouble(), image.height.toDouble());
    double xFactor = imageSize.width / destSize.width;
    double yFactor = imageSize.height / destSize.height;
    double factor = (xFactor > yFactor) ? yFactor : xFactor;
    print ('Factors are $xFactor $yFactor $factor ${image.width / factor} ${image.height / factor}');

    //ImageCropper.cropImage(sourcePath: fileName, )

    // img.Image curImage = img.Image.fromBytes(image.width, image.height, bytes, format: img.Format.rgb);
    // img.Image image3 = img.copyCrop(curImage, 0, 0, 100, 100);
    // Uint8List byteList = image3.getBytes();
    // ui.Image image4 = await decodeImageFromList(byteList);
    


    Image image2 = Image(
        image: ResizeImage(MemoryImage(bytes),
        width: (image.width/factor ).toInt(),
        height: (image.height/factor).toInt(),
        ));

    // Size size = await getSize(image2);
    // double width = size.width;
    // double height = size.height;
    // print ('Size of the scaled image is $width $height');
    return image2;
  }

  Future<Size>   getSize (Image image) {
    Completer<Size> completer = Completer();
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
            (ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          completer.complete(size);
        },
      ),
    );
  }


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
      print ('Puzzle size is ${puzzleSize.width} ${puzzleSize.height}');
      lightCorridorSize = lightCorridorKey.currentContext.size;
      vibSoundCorridorSize = vibSoundCorridorKey.currentContext.size;
      timerBarSize = timerKey.currentContext.size;
      print('Puzzle size is ${puzzleSize.width} and ${puzzleSize.height}');
      print('The corridor size is ${lightCorridorSize.width} ${lightCorridorSize.height}}');
      print('The soundVib height is ${vibSoundCorridorSize.width} ');
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

    String fileName = await PuzzleFiles.getRandomPuzzleFile();
    String backgroundFile = "/assets/images/files/" +  fileName +  ".jpg";
    backgroundImage = await createImageFromFile(backgroundFile, puzzleSize);
    double height = (puzzleSize.height.toInt()) / 2; //Transform widget = Transform.scale(scale: 2.0, child: Image.memory(byteList));
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
    //double width = MediaQuery.of(context).size.width;
    //double height = MediaQuery.of(context).size.height;
    //print ('Size of the screen is $width $height');
    List<String> puzzleComplexity = Level.getPuzzleComplexity(widget.levelNumber).split('x');
    rows = int.parse(puzzleComplexity[0]);
    cols = int.parse(puzzleComplexity[1]);
    lightRate = Level.getNumberOfEvents(widget.levelNumber);
    vibrationRate = Level.getNumberOfEvents(widget.levelNumber);
    soundRate = Level.getNumberOfEvents(widget.levelNumber);
    splitImage();
    super.initState();
    }

  void showMessageDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: Colors.black)),
          backgroundColor: Colors.white,
          content: Text ('Please wait'),
        );
      },
    );
  }

  void dispose () {
    vibSoundCorridor.releaseSound();
    super.dispose();
    print ("dispose is called");
  }

  void displayOverlay (BuildContext context) async {
      OverlayState overlayState = Overlay.of(context);
      OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: 24.0,
          right: 10.0,
          child: CircleAvatar(
            radius: 10.0, backgroundColor: Colors.red,
            child: Text("1"),
          )
        ));
      overlayState.insert(overlayEntry);
      await Future.delayed(Duration(seconds: 2));
      overlayEntry.remove();
  }

  void okDialog (String displayText) async {
    Widget okButton = TextButton(
        child: Text("Ok", style: TextStyle(color:Colors.white)),
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.black)),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        }
    );
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: Colors.black)),
      title: Text(displayText),
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

  AlertDialog  doYouWantToCancel () {
    return AlertDialog(
        title: Column(),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: Colors.black)),
        content: Text(
            "Do you really want to cancel?"),
        actions: <Widget>[
          TextButton(
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.black)),
            child: Text("Yes", style: TextStyle(color: Colors.white)),
            onPressed: () {
              choreography.updateScores();
              choreography.timelinePaused = false;
              choreography.setStatusToReady(
                  false);
              Navigator.of(context,
                  rootNavigator: true).pop();
              Navigator.of(context,
                  rootNavigator: true).pop();
            },
          ),
          TextButton(
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.black)),
            child: Text("No",style: TextStyle(color: Colors.white)),
            onPressed: () {
              choreography.timelinePaused = false;
              Navigator.of(context,
                  rootNavigator: true).pop();
            },
          )
        ]
    ) ;
  }
  @override
  Widget build(BuildContext context) {
    widget.state = this;
    if (pieces != null) {
      print("size of pieces is ${pieces.length}");
    }

    return WillPopScope (
      onWillPop: ()  async {
        if (choreography.isReady()) {
          setState(() {
          });
          return Future.value(true);
        }
        else {
          choreography.timelinePaused = true;
          await okDialog('Please press Cancel to abort Test');
          choreography.timelinePaused = false;
          Future.value(false);
        }
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,   //new line
          appBar: AppBar(
            //Here we take the value from the MyHomePage object that was created by
            //the App.build method, and use it to set our appbar title.
            title: Text(widget.title),
//            backgroundColor: Colors.black,
          ),
          body: Container(
            color: Colors.transparent,
            child: SafeArea(
              top: false,
              bottom: false,
//                minimum: EdgeInsets.only(bottom: 50.0),
                child: Container(
                decoration: new BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [Colors.indigo, Colors.indigo, Colors.black, Colors.black],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft)),
                child: Column(
                  children: [
                    Expanded(
                        flex: 4,
                        child: Container(
                          decoration: BoxDecoration (color: Colors.black,
                          border: Border.all(width: 3.0, color: Colors.white ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                  key: timerKey,
                                  children: [
                                    Expanded ( flex: 3, child: Column( children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 2.0),
                                            child: Text("Test", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
                                          ),
                                          Text("  ${widget.levelNumber}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),],),),
                                    Expanded(flex: 4, child: Column( children: [
                                      Text('Puzzle',style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
                                      Text('$puzzleCompletion%', style: TextStyle(color: Colors.white),)])),
                                    Expanded(flex: 3, child: Column( children: [
                                      Icon(Icons.lightbulb, color: Colors.yellow),
                                      Text('$lightCount', style: TextStyle(color: Colors.white),)])),
                                    Expanded(flex: 3, child: Column( children: [
                                      Icon(Icons.vibration, color: Colors.yellow),
                                      Text('$vibrationCount', style: TextStyle(color: Colors.white),)])),
                                    Expanded(flex: 3, child: Column( children: [
                                      Icon(Icons.music_note, color: Colors.yellow),
                                      Text('$soundCount', style: TextStyle(color: Colors.white))])),
                                    Expanded( flex:3, child: Column( children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 2.0),
                                            child: Text("Secs", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
                                          ),
                                          Text("$timeRemaining", style: TextStyle(backgroundColor: timeRemainingColor, color: Colors.white, fontWeight: FontWeight.bold)),],),),
                                  ]
                              ),
                            ],
                          ),
                        )
                    ),
                    Expanded(
                      flex: 30,
                      child: Row(
                        children: [
                          Expanded(
                              flex: 2, key: lightCorridorKey, child: Stack(children: lightPieces),),
                          Expanded(
                              flex: 16, key: puzzleKey,  child: Stack(clipBehavior: Clip.none, children: pieces)),
                          Expanded(
                              flex: 2, key: vibSoundCorridorKey, child: Stack(children: vibSoundButtons)
                               ),
                      ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
//                          Spacer(flex: 1),
//                          Text('Last Result: ${(choreography != null) ? choreography.getResultString(): 'No test run'}', style: TextStyle(color: Colors.white, fontSize: 20)),
//                         Spacer(flex: 1),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: FloatingActionButton.extended(onPressed: () async {
                              bool simulator = await FlutterIsEmulator
                                  .isDeviceAnEmulatorOrASimulator;
                              print("The simulator is active $simulator");
                              if (await Vibration.hasVibrator() || simulator) {
                                if (choreography.isReady()) {
                                  choreography.setStatusToProgress();
                                } else if (choreography.isProgressing()) {
                                  choreography.timelinePaused = true;
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return doYouWantToCancel();
                                      }
                                  );
                                }
                              } else {
                                okDialog('Vibration capabilityRequired');
                              }
                            },
                              label: Text('$gameStatus'), //shape: RoundedRectangleBorder(),
                            ),
                          ),
//                        Spacer(flex: 1)
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

class MindfullnessAlertExcerciserApp extends StatefulWidget {

  MindfullnessAlertExcerciserApp();

  @override
  _MindfullnessAlertExcerciserAppState createState() => _MindfullnessAlertExcerciserAppState();
}

class _MindfullnessAlertExcerciserAppState extends State<MindfullnessAlertExcerciserApp> {
  StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    final Stream purchaseUpdates =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdates.listen((purchases) {
      // _handlePurchaseUpdates(purchases);
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  // final bool available = await InAppPurchaseConnection.instance.isAvailable();
  // if (!available) {
  // // The store cannot be reached or accessed. Update the UI accordingly.
  // }

    @override
  Widget build(BuildContext context) {
    return MaterialApp (
      debugShowCheckedModeBanner: false,
      home: StartApp(),
      routes: <String, WidgetBuilder> {
        '/InstructionsScreen' : (context) => IntroductoryScreen(),
        '/AlertGameScreen' : (context) => MyHomePage(title: "Alertness Exerciser"),
        '/Scores': (context) => Scores()
    }
    );
  }
}
