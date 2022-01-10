import 'package:flutter/material.dart';
import 'select_directory.dart';
import 'dart:io';

class Commit {
  final String hash, author, date, message;
  Commit({required this.hash, required this.author, required this.date, required this.message});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? dir, cmdText, cmdError;
  List<Commit> commitList = []; 
  static final RegExp reg = RegExp(r"commit (\S+)\s+Author: ([^\n^\r]+)\s*Date: ([^\n^\r]+)\s*(\S[^\n^\r]+)");
  static const init_msg = "Please select a git repository.\n" + 
    "Tap the floating floatingActionButton choosing a directory.";

  Future<void> _showGitRepoError(String error, BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user need not tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error getting git repository details'),
          content: Text(error),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> getCmdText(String? directory, BuildContext context) async {
    var result = await Process.run(
      'git', 
      ['log'],
      workingDirectory: directory,
      runInShell: true,
    );
    String ctext = result.stdout;
    String etext = result.stderr;

    if(etext.length>0){
      await this._showGitRepoError(etext, context);
      return ;
    }

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
  }

  Widget buildCommitWidget(BuildContext context, int index){
    var commit = commitList[index];

    var commitMessage = Container(
      child: Text(
        commit.message,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      padding: EdgeInsets.only(top: 8, bottom: 8),
    );
    var commitHash = Text(commit.hash);
    var commitAuthor = Text(commit.author);
    var commitDate = Text(commit.date);

    return Column(
      children: [
        Row(children: [Expanded(child: commitHash   )            ]),
        Row(children: [Expanded(child: commitMessage)            ]),
        Row(children: [Expanded(child: commitAuthor), commitDate,]),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body = const Center(child: Text(init_msg));
  
    if((dir??"").length>0){
      if((cmdError??"").length==0){
        body = ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: commitList.length,
          itemBuilder: (BuildContext context, int index) 
                            => buildCommitWidget(context,index),
        );
      } else {
        body = Center(child: Text(cmdError??"No Command Error"));
      }
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
          ).then((String? directory)=>getCmdText(directory, context));
        },
        tooltip: 'Add a git directory',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}



