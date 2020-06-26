import 'package:chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());

  Firestore.instance
      .collection('col')
      .document('doc')
      .setData({'texto': 'daniel'});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Generated App',
      theme: new ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF212121),
          accentColor: const Color(0xFF64ffda),
          canvasColor: const Color(0xFF303030),
          iconTheme: IconThemeData(color: Colors.black87)),
      home: new ChatScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('App Name'),
      ),
      body: new Container(
        padding: const EdgeInsets.all(0.0),
        alignment: Alignment.center,
      ),
    );
  }
}
