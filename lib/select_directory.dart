import 'package:flutter/material.dart';
import 'dart:io';

class SelectDirectoryApp extends StatefulWidget {
	const SelectDirectoryApp({Key? key}) : super(key: key);

  @override
  State<SelectDirectoryApp> createState() => _SelectDirectoryAppState();
}

class _SelectDirectoryAppState extends State<SelectDirectoryApp> {
	String dir=Directory.current.path;

  @override
  Widget build(BuildContext context) {
  	//var subDirStream = Directory(this.dir).list(recursive: false, followLinks: false);
    return MaterialApp(
      title: 'Directory Selector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
	      appBar: AppBar(
	        title: Text('Directory Selector'),
	      ),
	      body: Container(
	      	padding: const EdgeInsets.all(32),
	      	child: Column(
  	      	children: <Widget>[
  	      		Container(
	              padding: const EdgeInsets.only(bottom: 8),
	              child: Row( children: <Widget>[
	              	Tooltip(
	              		message: "Go up a directory",
	              		child: OutlinedButton.icon(
		              	  onPressed: () {
		              	      setState((){dir=Directory(dir).parent.path;});
		              	  },
		              	  icon: const Icon(Icons.arrow_circle_up),
		              	  label: Text(""),
		              	),
	              	),
		              Container(
		              	padding: const EdgeInsets.only(left: 8),
		              	child: Text(
			              	dir,
			                style: TextStyle(
			                  fontWeight: FontWeight.bold,
			                ),
		                ),
	                ),
	              ],),
	            ),
  	      		Expanded(
  	      			child: _SubDirs(
  	      				directory: dir,
  	      				onTap: (String directory)=>setState((){dir=directory;})
  	      			),
  	      		),
  	      	],
	        ),
	      ),
	      floatingActionButton: FloatingActionButton(
	        onPressed: () {
	          Navigator.pop(context, dir);
	        },
	        tooltip: 'Add a directory',
	        child: const Icon(Icons.add_task),
	      ), // This trailing comma makes auto-formatting nicer for build methods.
	    ),
    );
  }
}

class _SubDirs extends StatefulWidget{
	Directory dir;
	Function(String) onTap;

	_SubDirs({Key? key, required String directory, required this.onTap}) : 
		dir=Directory(directory), super(key: key);

	@override
	State<_SubDirs> createState() => _SubDirState();	
}

class _SubDirState extends State<_SubDirs> {
	Directory? dir;
	//Function(String) onTap;
	List<Directory>? subdirs;

	//_SubDirState({Key? key, required String directory, required this.onTap}) 
	//	: dir=Directory(directory);

	void _setDir(Directory directory) async{
		List<Directory> sub_directories = <Directory>[];
		
		await for (FileSystemEntity entity in widget.dir.list(recursive: false, followLinks: false)){
			if(entity is Directory) sub_directories.add(entity as Directory);
		}
		setState((){
			dir = directory;
			widget.dir = directory;
			subdirs = sub_directories;
		});
	}

	@override
	void initState(){
		_setDir(widget.dir);
		super.initState();
	}

	@override
	Widget build(BuildContext context){
		List<Widget> children = <Widget>[];

		if(dir?.path != widget.dir.path){
			_setDir(widget.dir);
		} else {
			for (var f in subdirs??<Directory>[]) {
				children.add(
					ListTile(
						leading: const Icon(
					    Icons.folder,
					    color: Colors.green,
					    size: 60,
					  ),
					  title: Text(f.path),
					  subtitle: Text(widget.dir.path),
					  onTap: ()=>widget.onTap(f.path),
					)
				); 
			}
		}

		return ListView(
			padding: const EdgeInsets.all(20.0),
			children: children,
    );
	}
}
