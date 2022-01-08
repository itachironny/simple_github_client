import 'package:flutter/material.dart';
import 'select_directory.dart';

class ItemContainer extends StatelessWidget {
  final String text;
  const ItemContainer({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Container(
      height: 50,
      //color: Colors.amber[colorCodes[index]],
      child: Center(child: Text('Entry ${this.text}')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final count=2000, nextRange=50;
  int start=0,end=51;
  List<int> fullItemList=[];
  List<String> itemList=[];

  _MyHomePageState(){
    for (var i = 0; i < count; i++) {
      fullItemList.add(i);
    }
    //itemList=
    fullItemList.sublist(0,51).forEach((int j){itemList.add("$j");});
  }

  //void getNextRange(){
  //  var nextStart=start+
  //}

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: nextRange,
        itemBuilder: (BuildContext context, int index){
          return ItemContainer(text:itemList[index]);
        }, // TODO: Add actual widget
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (context) => SelectDirectoryApp()),
          ).then((String? directory){
          	setState((){itemList[0]=directory??"NULL";});
          });
        },
        tooltip: 'Add a directory',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}



