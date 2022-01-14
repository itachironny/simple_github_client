import 'package:flutter/material.dart';
import 'select_directory.dart';
import 'dart:io';

class Commit {
  final String hash, author, date, message;
  Commit({required this.hash, required this.author, required this.date, required this.message});
}

enum CloneRepoState {
  not_started, cloning, success, error
}

class GitRepoUrl {
  static final RegExp reg = RegExp(r"/([^/]+)\.git");
  static String? getFolder(String url){
    var match = reg.firstMatch(url);
    if(match == null){
      print("No folder found in git repo url : <>${url}<>");
      return null;
    } else {
      print("Git repo url match is ${match.group(1)}");
    }
    return match.group(1);
  }
}

class CloneRepo {
  final String url, directory;
  String ctext = "", etext = "";
  CloneRepoState state = CloneRepoState.not_started; 
  CloneRepo({required this.url, required this.directory});
  Future<void> start() async {
    print("Starting cloning ${url} inside ${directory}");
    state = CloneRepoState.cloning;
    var result = await Process.run(
      'git', 
      ['clone',url],
      workingDirectory: directory,
      runInShell: true,
    );

    this.ctext = result.stdout;
    this.etext = result.stderr;

    this.state = (result.exitCode == 0) ? CloneRepoState.success : CloneRepoState.error;

    print("Cloning done. Exit code : ${result.exitCode}");
    print([this.ctext,this.etext]);
  }
}

AlertDialog buildCloneAlertDialog(BuildContext context){
  String? recv_url, recv_dir;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  return AlertDialog(
    scrollable: true,
    title: Text('Enter repo details'),
    content: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'URL'),
              onSaved: (String? value){recv_url=value;},
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                var folder = GitRepoUrl.getFolder(value);
                if (folder == null) {
                  return "No folder found in ${value}";
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Clone directory'),
              onSaved: (String? value){recv_dir=value;},
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
          ],
        )
      ),
    ),
    actions: <Widget>[
      ElevatedButton(
        child: Text('Cancel'),
        onPressed: (){
          Navigator.pop(context);
        },
      ),
      ElevatedButton(
        child: Text('Okay'),
        onPressed: (){
          if (_formKey.currentState?.validate() ?? false) {
            _formKey.currentState?.save();
            Navigator.pop<CloneRepo>(context, CloneRepo(
              url: recv_url??"", 
              directory: recv_dir??""
            ));
          }
        },
      ),
    ],
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? dir, cmdText;
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
    setState((){dir=directory;cmdText=ctext;commitList=commits;});
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

  Widget buildCloneWidget(BuildContext context){
    return ElevatedButton(
      child: const Text('Clone Passwordless'),
      onPressed: () async {
        CloneRepo? cloner = await showDialog<CloneRepo>(
          context: context,
          builder: (BuildContext context)=>buildCloneAlertDialog(context),
        );
        if(cloner == null) return;
        await cloner.start();
        switch (cloner.state) {
          case CloneRepoState.success :
            String fdir = cloner.directory + 
              (cloner.directory.endsWith("/") ? "" : "/") + 
              (GitRepoUrl.getFolder(cloner.url) ?? "") ;
            print("Going to "+fdir);
            getCmdText(fdir, context);
            break;
          case CloneRepoState.error :
            _showGitRepoError(cloner.etext, context);
            break;
          default:
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body = const Center(child: Text(init_msg));
  
    if((dir??"").length>0)
    body = ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: commitList.length,
      itemBuilder: (BuildContext context, int index) 
                        => buildCommitWidget(context,index),
    );

    final ButtonStyle style =
        TextButton.styleFrom(primary: Theme.of(context).colorScheme.onPrimary);

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Choose local git repo'),
            onPressed: () {
              Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (context) => SelectDirectoryApp()),
              ).then((String? directory)=>getCmdText(directory, context));
            },
          ),
          buildCloneWidget(context),
        ],
      ),
      body: Container(child: body),
      //floatingActionButton: FloatingActionButton(
      //  onPressed: () {
      //    Navigator.push<String>(
      //      context,
      //      MaterialPageRoute(builder: (context) => SelectDirectoryApp()),
      //    ).then((String? directory)=>getCmdText(directory, context));
      //  },
      //  tooltip: 'Add a git directory',
      //  child: const Icon(Icons.add),
      //), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}



