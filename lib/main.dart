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
import 'choreographer.dart';
import 'package:slide_countdown_clock/slide_countdown_clock.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences storage = await SharedPreferences.getInstance();
  runApp(MyApp(storage));
}

class MyApp extends StatelessWidget {
  final SharedPreferences storage;

  MyApp(this.storage);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Mindfull Application'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final int rows = 4;
  final int cols = 4;
  LightCorridor lightCorridor;
  VibSoundCorridor vibSoundCorridor;
  List<Widget> widgetTree = List<Widget>();
  List<Piece> pieces = List<Piece>();
  List<Light> lightPieces = List<Light>();
  List<VibSoundButton> vibSoundButtons = List<VibSoundButton>();
  Completer layoutCompleted = Completer();
  Size lightCorridorSize;
  Size vibSoundCorridorSize;
  Choreographer choreography;
  _MyHomePageState state;

  MyHomePage({Key key, this.title}) : super(key: key) {
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
  Completer<Size> lightCorridorSizeCompleted = Completer<Size>();
  Completer<Size> vibSoundCorridorSizeCompleted = Completer<Size>();
  Size imageSize;
  Uint8List byteList;
  AudioCache audioCache = AudioCache();
  AudioPlayer audioPlayer;
  bool isPlaying = false;
  bool isPaused = false;
  double timerBarValue = 0.0;
  double timerBarTotalValue = 1000.0;
  GlobalKey timerKey = new GlobalKey();
  Size timerBarSize;
  String  timeRemaining = '120';
  String  puzzleCompletion = '100%';
  String  lightCount = '23/56';
  String  vibrationCount = '23/56';
  String  soundCount = '23/56';

  void playHandler() async {
    if (isPlaying) {
      audioPlayer.stop();
    } else {
      audioPlayer = await audioCache.play('sound/win.mp3');
    }
  }

    void setPuzzleCompletion(int completedPieces, int totalPieces) {
      setState(() {
        double ratio = completedPieces * 100 / totalPieces;
        puzzleCompletion = ratio.toStringAsPrecision(2);
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

  void pauseHandler() {
    if (isPaused && isPlaying) {
      audioPlayer.resume();
    } else {
      audioPlayer.pause();
    }

    setState(() {
      isPaused = !isPaused;
    });
  }

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

  void bringToTop(Widget curWidget) {
    setState(() {
      widget.pieces.remove(curWidget);
      widget.pieces.add(curWidget);
    });
  }

  void sendToBack(Widget curWidget) {
    setState(() {
      widget.pieces.remove(curWidget);
      widget.pieces.insert(0, curWidget);
    });
  }

  void updateState(VoidCallback safeFunction) {
    setState(() {
      safeFunction();
      widget.pieces = widget.pieces;
      if (widget.pieces.isNotEmpty) {
        print(
            "Key of the top of the stack ${widget.pieces.last.key.toString()}");
      }
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
      widget.lightCorridorSize = lightCorridorKey.currentContext.size;
      widget.vibSoundCorridorSize = vibSoundCorridorKey.currentContext.size;
      timerBarSize = timerKey.currentContext.size;
      print(
          'The corridor height is ${widget.lightCorridorSize.height}, puzzle height is ${puzzleSize.height}');
      print('The soundVib height is ${widget.vibSoundCorridorSize.height} ');
      widget.lightCorridor = LightCorridor(
        widget.lightCorridorSize,
        6,
        updateState,
      );

      widget.vibSoundCorridor = VibSoundCorridor(
        widget.vibSoundCorridorSize,
        6,
        updateState,
      );
    });

    widget.choreography = Choreographer(lightCorridor: widget.lightCorridor, vibSoundCorridor: widget.vibSoundCorridor, homePage: widget);

    backgroundImage =
        await createImageFromFile("/assets/images/files/cat.png", puzzleSize);
    double height = (puzzleSize.height.toInt()) /
        2; //Transform widget = Transform.scale(scale: 2.0, child: Image.memory(byteList));

    //Add Light pieces.
    widget.lightPieces.addAll(widget.lightCorridor.getList());
    widget.vibSoundButtons.addAll(widget.vibSoundCorridor.getList());
    Piece piece1, piece2;
    List<Piece> tempList2 = List<Piece>();
    for (int x = 0; x < widget.rows; x++) {
      for (int y = 0; y < widget.cols; y++) {
        piece1 = Piece(
            key: GlobalKey(),
            image: backgroundImage,
            imageSize: imageSize,
            puzzleSize: Size(puzzleSize.width, puzzleSize.height / 2.0),
            yOffset: 0.0,
            row: x,
            col: y,
            maxRow: widget.rows,
            maxCol: widget.cols,
            bringToTop: bringToTop,
            sendToBack: sendToBack,
            updateState: updateState,
            filter: false);

        piece2 = Piece(
            key: GlobalKey(),
            image: backgroundImage,
            imageSize: imageSize,
            puzzleSize: Size(puzzleSize.width, puzzleSize.height / 2.0),
            yOffset: puzzleSize.height / 2,
            row: x,
            col: y,
            maxRow: widget.rows,
            maxCol: widget.cols,
            bringToTop: bringToTop,
            sendToBack: sendToBack,
            updateState: updateState,
            filter: false);
        widget.pieces.add(piece1);
        tempList2.add(piece2);
      }
    }

    tempList2.shuffle();
    double extraSpace =
        2.0 * widget.pieces[0].xCenterOffset / (widget.cols - 1);
    for (int x = 0; x < widget.cols; x++) {
      for (int y = 0; y < widget.rows; y++) {
        int index = x * widget.rows + y;
        tempList2[index].left +=
            ((x - tempList2[index].col) * tempList2[index].pieceSize.width -
                    tempList2[index].xCenterOffset) +
                x * extraSpace;
        tempList2[index].top =
            (y - tempList2[index].row) * tempList2[index].pieceSize.height +
                puzzleSize.height / 2;
      }
    }

    widget.pieces.add(Piece(
        key: GlobalKey(),
        image: backgroundImage,
        imageSize: imageSize,
        puzzleSize: Size(puzzleSize.width, puzzleSize.height / 2.0),
        yOffset: 0.0,
        row: 0,
        col: 0,
        maxRow: widget.rows,
        maxCol: widget.cols,
        bringToTop: bringToTop,
        sendToBack: sendToBack,
        updateState: updateState,
        filter: true));

    widget.pieces.addAll(tempList2);
    widget.pieces.forEach((eachPiece) {eachPiece.setOrgPosition(); });

    widget.choreography.setPieces (widget.pieces);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    print("Screen width is $screenWidth, $screenHeight");
    print("setState is about to be set");

    setState(() {
      widget.pieces = widget.pieces;
    });

    print("image size is ${imageSize.width} and height is ${imageSize.height}");
    print("Size of pieces at this point is ${widget.pieces.length}");
  }

  @override
  void initState() {
    //Size puzzleSize = puzzleKey.currentContext.size;
    splitImage();
    // _assetsAudioPlayer = AssetsAudioPlayer();
    // _assetsAudioPlayer.open(
    //     Audio(
    //         "assets/sound/win.mp3")
    // );
    super.initState();
    print('initState');
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        if (timerBarValue < timerBarTotalValue) {
          timerBarValue += 10;
        }
        else {
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    print("size of pieces is ${widget.pieces.length}");

    return Scaffold(
        appBar: AppBar(
          //Here we take the value from the MyHomePage object that was created by
          //the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {},
          ),
        ),
        body: Container(
          decoration: new BoxDecoration(
              gradient: new LinearGradient(
                  colors: [const Color(0xFF000046), const Color(0xFF1CB5E0)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft)),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Row(
                    key: timerKey,
                  children: [
                    Expanded(flex: 3, child: Column( children: [
                      Text('Time-sec', style: TextStyle(color: Colors.white),),
                      Text('$timeRemaining', style: TextStyle(color: Colors.white),)])),
                    Expanded(flex: 3, child: Column( children: [
                      Text('Comp %',style: TextStyle(color: Colors.white)),
                      Text('$puzzleCompletion', style: TextStyle(color: Colors.white),)])),
                    Expanded(flex: 3, child: Column( children: [
                      Icon(Icons.lightbulb, color: Colors.white, size: 20.0),
                      Text('$lightCount', style: TextStyle(color: Colors.white),)])),
                    Expanded(flex: 3, child: Column( children: [
                      Icon(Icons.vibration, color: Colors.white, size: 20.0),
                      Text('$vibrationCount', style: TextStyle(color: Colors.white),)])),
                    Expanded(flex: 3, child: Column( children: [
                      Icon(Icons.music_note, color: Colors.white, size: 20.0),
                      Text('$soundCount', style: TextStyle(color: Colors.white))])),
                  ]
                )
              ),

              Expanded(
                flex: 18,
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        key: lightCorridorKey,
                        child: Container(
                            color: Colors.transparent,
                            child: Stack(children: widget.lightPieces))),
                    Expanded(
                        key: puzzleKey,
                        flex: 8,
                        child: Stack(children: widget.pieces)),
                    Expanded(
                        key: vibSoundCorridorKey,
                        flex: 1,
                        child: Container(
                            color: Colors.transparent,
                            child: Stack(children: widget.vibSoundButtons))),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                //child: Container(color: Colors.cyan))
                child: FloatingActionButton(onPressed: () {
                  if (!widget.choreography.inProgress()) {
                    widget.choreography.start();
                  }
                }),
              )
            ],
          ),
        ));
  }
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