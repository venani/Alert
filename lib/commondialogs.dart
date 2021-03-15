import 'package:flutter/material.dart';

class CommonDialogs {
  static bool popped = false;
  static void yesNoDialog (BuildContext context, String question, Function action) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Column(),
              shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: Colors.black)),
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

  static Widget popupDialog (BuildContext context, String title, String info) {
    // Timer(Duration(milliseconds: 10000), () {
    //   if (!popped) {
    //     Navigator.pop(context);
    //     popped = true;
    //   }
    // }
    // );
    return GestureDetector(
      onTapDown: (DragStartDetails) {
        if (!popped) {
          Navigator.pop(context);
          popped = true;
        }
      },
      onVerticalDragStart: (DragStartDetails) {
        if (!popped) {
          Navigator.pop(context);
          popped = true;
        }
      },
      onHorizontalDragStart: (DragStartDetails) {
        if (!popped) {
          Navigator.pop(context);
          popped = true;
        }
      },
      child: AlertDialog(
        title: Center(child: Text(title)),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: Colors.black)),
        content: Text(
            info),
      ),
    );
  }
}
