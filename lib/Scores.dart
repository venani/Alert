import 'package:mindfulAlert/main.dart';

import 'levelhistory.dart';
import 'storage.dart';
import 'package:flutter/material.dart';
import 'commondialogs.dart';

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

  static String getLastString () {
    List<String> list = getList();
    String lastResult = list.last;

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
  void initState() {
    // TODO: implement initState
    List<String> list = Scores.getList();
    int index = 0;
    list.forEach((element) {
      index++;
      print('$index $element');
    });
    super.initState();
  }
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
                       String testStatus = Scores.getList()[index].split('-')[1].split(' ')[1].split('?')[0];
                       Color testColor = LevelHistory.testColor(testStatus);
                       print ('Test status is $testStatus $testColor');
                       print (' index is $index/${Scores.getList().length} entry is ${Scores.getList()[index]}');
                       print ('Component 1 ${Scores.getList()[index].split('?')[0]}');
                       print ('Component 2 ${ Scores.getList()[index].split('?')[1]}');
                        return Card(color: testColor,
                            borderOnForeground: true,
                            child: ListTile(isThreeLine: true, tileColor: testColor,
                                subtitle: Text("${Scores.getList()[index].split('?')[0]}"),
                                title: Text("${Scores.getList()[index].split('?')[1]}",
                                    style: TextStyle(color:Colors.black))));
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
