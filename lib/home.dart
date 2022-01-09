import 'package:flutter/material.dart';
import 'select_directory.dart';
import 'dart:io';

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
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final count=2000, nextRange=50;
  int start=0,end=51;
  List<int> fullItemList=[];
  List<String> itemList=[];

  String? dir, cmdText, cmdError;

  _MyHomePageState(){
    for (var i = 0; i < count; i++) {
      fullItemList.add(i);
    }
    //itemList=
    fullItemList.sublist(0,51).forEach((int j){itemList.add("$j");});
  }

  Future<int> getCmdText(String? directory) async {
    var result = await Process.run(
      'git', 
      ['log'],
      workingDirectory: directory,
      runInShell: true,
    );
    String ctext = result.stdout;
    String etext = result.stderr;
    setState((){dir=directory;cmdText=ctext;cmdError=etext;});
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    Widget body = ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: nextRange,
      itemBuilder: (BuildContext context, int index){
        return ItemContainer(text:itemList[index]);
      }, // TODO: Add actual widget
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
    if(dir!=null) body=Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: <Widget>[
          Text(cmdText??"NULL"),
          const Divider(),
          Text(cmdError??"NULL"),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (context) => SelectDirectoryApp()),
          ).then((String? directory)=>getCmdText(directory));
        },
        tooltip: 'Add a directory',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}



