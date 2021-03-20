import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';

class Piece extends StatefulWidget {
  final Image image;
  final Size imageSize;
  final Size puzzleSize;
  final double yOffset;
  final int row;
  final int col;
  final int maxRow;
  final int maxCol;
  final Function bringToTop;
  final Function sendToBack;
  final Function updateState;
  final bool filter;
  final double xCenterOffset;
  final Size pieceSize;
  final bool backgroundImage;
  double top = 0.0 ;
  double left = 0.0;
  double oldTop = 0.0;
  double oldLeft = 0.0;
  PieceState state;
  bool isMovable = true;
  DateTime lastTime = DateTime.now();
  bool isItActive = false;

  Piece(
      {Key key,
        @required this.image,
        @required this.imageSize,
        @required this.puzzleSize,
        @required this.yOffset,
        @required this.row,
        @required this.col,
        @required this.maxRow,
        @required this.maxCol,
        @required this.bringToTop,
        @required this.sendToBack,
        @required this.updateState,
        @required this.filter,
        @required this.xCenterOffset,
        @required this.pieceSize,
        @required this.backgroundImage,
        })
      : super(key: key)
  {
    left = xCenterOffset;
    top = yOffset;
  }

  void setItActive() {
   isItActive = true;
  }

  void setItInactive() {
    isItActive = false;
  }

  void setOrgPosition() {
    if (filter) {
      oldLeft = xCenterOffset;
      oldTop = 0;
    }
    else {
      oldLeft = left;
      oldTop = top;
    }
  }

  void setCurPosToOrgPos()
  {
    state.setState(() {
      top = oldTop;
      left = oldLeft;
      isMovable = true;
    });
  }

  bool atHome ()
  {
    if ((oldTop == top) && (oldLeft == left))
      return true;
    else
      return false;
  }

  bool atDestination()
  {
    if ((top == 0) && (left == 0))
      return true;
    else
      return false;
  }

  void movePieceBackToOrgPosition() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      state.setState(() {
        if ((oldTop - top).abs() < 10) {
          top = oldTop;
        }
        if ((oldLeft - left).abs() < 10) {
          left = oldLeft;
        }
        if ((oldTop - top) < 0) {
          top -= 5;
        } else if ((oldTop - top) > 0) {
          top +=5;
        }
        if ((oldLeft - left) < 0) {
          left -= 5;
        } else if ((oldLeft - left) > 0) {
          left += 5;
        }
      });
      if ((((oldTop - top).abs().toInt() == 0)) && (((oldLeft - left).abs().toInt() == 0))) {
        print('reached here');
        timer.cancel();
      }
    });
  }

  @override
  PieceState createState() {
    state = new PieceState();
    return state;
  }
}

class PieceState extends State<Piece> {

  static double backgroundOpacity = 1.0;

  // void resetPosition () {
  //   if (!retrievedData && !widget.filter) {
  //     widget.top = widget.oldTop = widget.initTop;
  //     left = oldLeft = widget.initLeft;
  //     retrievedData = true;
  //     isMovable = true;
  //   }
  // }

  setOpacity (double opacity) {
    setState(() {
      backgroundOpacity = opacity;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    widget.state = this;
    //resetPosition();

    if (widget.backgroundImage) {
      widget.isMovable = false;
      print ('Inside Opacity is $backgroundOpacity');
      return Positioned(
          top: 0.0,
          left: widget.xCenterOffset,
          //width: widget.pieceSize.width * widget.maxCol,
          height: widget.puzzleSize.height,
          //(xScale < yScale)? widget.imageSize.height / xScale: widget.imageSize.height / yScale,
          child: Opacity( opacity: backgroundOpacity,
              child: widget.image)//Container(color: Color(0xFF0E3311).withOpacity(0.7)))
      );
    }
    else return Positioned(
        top: widget.top,
        left: widget.left,
        //width: //(xScale < yScale)? widget.imageSize.width / xScale: widget.imageSize.width / yScale,
        height: widget.puzzleSize.height,
        //(xScale < yScale)? widget.imageSize.height / xScale: widget.imageSize.height / yScale,
        child: GestureDetector(
          //         behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!widget.backgroundImage && widget.isMovable) {
              widget.bringToTop(widget);
            print ('Piece is tapped');
            }
            // widget.updateState (() {
            //   widget.turns = ((!widget.isMovable) || (widget.turns == 3)) ? 0 : ++widget.turns;
            //   print ('Number of turns = ${widget.turns}');
            // });
          },
          onPanStart: (_) {
            if (!widget.backgroundImage && widget.isMovable) {
              widget.bringToTop(widget);
            }
          },
          onPanUpdate: (dragUpdateDetails) {
            print ('Trying to move the piece');
            if (widget.isItActive && widget.isMovable && !widget.backgroundImage) {
              widget.updateState(() {
                setState(() {
                  widget.lastTime = DateTime.now();
                  double tX = widget.left + dragUpdateDetails.delta.dx;
                  double tY = widget.top + dragUpdateDetails.delta.dy;
                  double xLeftLimit = -widget.col * widget.pieceSize.width/2;
                  double xRightLimit = (widget.maxCol - widget.col - 1) * widget.pieceSize.width/2 +
                      2.0 * widget.xCenterOffset;
                  if ((tX >= xLeftLimit) && (tX <= (xRightLimit))) {
                    double yTopLimit = -widget.row * widget.pieceSize.height/2;
                    double yBotLimit = 2 * widget.puzzleSize.height -
                        (widget.row + 1) * widget.pieceSize.height/2;
                    if ((tY >= yTopLimit) && (tY <= yBotLimit)) {
                      widget.top += dragUpdateDetails.delta.dy;
                      widget.left += dragUpdateDetails.delta.dx;
                      double widgetLeft = widget.left - widget.xCenterOffset;
                      if ( -10 < widget.top && widget.top < 10 && -10 < widgetLeft && widgetLeft < 10) {
                        widget.top = 0;
                        widget.left = widget.xCenterOffset;
                        widget.isMovable = false;
                        //                          widget.sendToBack(widget);
                      }
                      else {
                        widget.bringToTop(widget);
                      }
                    }
                    else {
                      print (" yTopLimit $yTopLimit tY $tY  yBotLimit $yBotLimit");
                    }
                  }
                });
              });
            }
          },
          child:
          ClipPath(
            child: CustomPaint(
                foregroundPainter: PuzzlePiecePainter(
                    widget.row, widget.col, widget.maxRow, widget.maxCol,
                    (widget.yOffset != 0.0) ? true : false, widget.isMovable),
                child: widget.image
            ),
            clipper: PuzzlePieceClipper(widget.row, widget.col, widget.maxRow, widget.maxCol),
          ),
        )
    );
  }
}

// this class is used to clip the image to the puzzle piece path
class PuzzlePieceClipper extends CustomClipper<Path> {
  final int row;
  final int col;
  final int maxRow;
  final int maxCol;

  PuzzlePieceClipper(this.row, this.col, this.maxRow, this.maxCol);

  @override
  Path getClip(Size size) {
    return getPiecePath(size, row, col, maxRow, maxCol);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// this class is used to draw a border around the clipped image
class PuzzlePiecePainter extends CustomPainter {
  final int row;
  final int col;
  final int maxRow;
  final int maxCol;
  final bool outline;
  final bool isMovable;

  PuzzlePiecePainter(this.row, this.col, this.maxRow, this.maxCol, this.outline, this.isMovable);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
     ..color = outline ? ((isMovable) ? Colors.yellow: Colors.white) : Colors.white//Colors.black54//Color(0x80FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = outline ? ((isMovable) ? 3.0: 4.0) : 0.0;

    canvas.drawPath(getPiecePath(size, row, col, maxRow, maxCol), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// this is the path used to clip the image and, then, to draw a border around it; here we actually draw the puzzle piece
Path getPiecePath(Size size, int row, int col, int maxRow, int maxCol) {
  final width = size.width / maxCol;
  final height = size.height / maxRow;
  final offsetX = col * width;
  final offsetY = row * height;
  final bumpSize = height / 4;

  var path = Path();
  path.moveTo(offsetX, offsetY);

  if (row == 0) {
    // top side piece
    path.lineTo(offsetX + width, offsetY);
  } else {
    // top bump
    path.lineTo(offsetX + width / 3, offsetY);
    path.cubicTo(offsetX + width / 6, offsetY - bumpSize, offsetX + width / 6 * 5, offsetY - bumpSize, offsetX + width / 3 * 2, offsetY);
    path.lineTo(offsetX + width, offsetY);
  }

  if (col == maxCol - 1) {
    // right side piece
    path.lineTo(offsetX + width, offsetY + height);
  } else {
    // right bump
    path.lineTo(offsetX + width, offsetY + height / 3);
    path.cubicTo(offsetX + width - bumpSize, offsetY + height / 6, offsetX + width - bumpSize, offsetY + height / 6 * 5, offsetX + width, offsetY + height / 3 * 2);
    path.lineTo(offsetX + width, offsetY + height);
  }

  if (row == maxRow - 1) {
    // bottom side piece
    path.lineTo(offsetX, offsetY + height);
  } else {
    // bottom bump
    path.lineTo(offsetX + width / 3 * 2, offsetY + height);
    path.cubicTo(offsetX + width / 6 * 5, offsetY + height - bumpSize, offsetX + width / 6, offsetY + height - bumpSize, offsetX + width / 3, offsetY + height);
    path.lineTo(offsetX, offsetY + height);
  }

  if (col == 0) {
    // left side piece
    path.close();
  } else {
    // left bump
    path.lineTo(offsetX, offsetY + height / 3 * 2);
    path.cubicTo(offsetX - bumpSize, offsetY + height / 6 * 5, offsetX - bumpSize, offsetY + height / 6, offsetX, offsetY + height / 3);
    path.close();
  }

  return path;
}
