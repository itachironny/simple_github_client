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

class Commit {
  final String hash, author, date, message;
  Commit({required this.hash, required this.author, required this.date, required this.message});
}

class _MyHomePageState extends State<MyHomePage> {
  final count=2000, nextRange=50;
  int start=0,end=51;
  List<int> fullItemList=[];
  List<String> itemList=[];

  String? dir, cmdText, cmdError;
  List<Commit> commitList = []; 
  static final RegExp reg = RegExp(r"commit (\S+)\s+Author: ([^\n^\r]+)\s*Date: ([^\n^\r]+)\s*(\S[^\n^\r]+)");

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

    var commits = <Commit>[];

    for(var i in reg.allMatches(ctext)) print(i.groups(<int>[1,2,3,4]));
    for(var i in reg.allMatches(ctext)) commits.add(Commit(
      hash: i.group(1)??"",
      author: i.group(2)??"",
      date: i.group(3)??"",
      message: i.group(4)??"",
    ));

    print(<String>[ctext]);
    print(<String>[etext]);
    setState((){dir=directory;cmdText=ctext;cmdError=etext;commitList=commits;});
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
    
    if((dir??"").length>0){
      if((cmdError??"").length==0){
        body = ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: commitList.length,
          itemBuilder: (BuildContext context, int index){
            var commit = commitList[index];
            return Column(
              children: <Widget>[
                // Hash
                Row(children: [Expanded(child: Text(commit.hash)) ]),
                Row(
                  // commit msg
                  children: [
                    Expanded(
                      child: Container(
                        child: Text(
                          commit.message,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    // Author
                    Expanded(child: Text(commit.author)),
                    // Date
                    Text(commit.date), 
                  ],
                ),
                const Divider(),
              ],
            );
          },
          //separatorBuilder: (BuildContext context, int index) => const Divider(),
        );
      } else {
        body = Center(child: Text(cmdError??"No Command Error"));
      }
    } else {
      const init_msg = """Please select a git repository.
      Tap the floating floatingActionButton choosing a directory.""";
      body = const Center(child: Text(init_msg));
    }

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(child: body),
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



