import 'dart:io';

import 'package:chat/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key key}) : super(key: key);
  @override
  _ChatScreenState createState() => new _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FirebaseUser _currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      _currentUser = user;
    });
  }

  Future<FirebaseUser> _getUser() async {
    if (_currentUser != null) return _currentUser;

    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      //Pode ser utilizado com outros provedores, facebook, twitter etc

      final FirebaseUser user = authResult.user;

      return user;
    } catch (error) {
      print(error);
      return null;
    }
  }

  void _sendMessage({String text, File imgFile}) async {
    final FirebaseUser user = await _getUser();

    if (user == null) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Não foi possível fazer o login, tente novamente.'),
        backgroundColor: Colors.red,
      ));
    }

    Map<String, dynamic> data = {
      "uid": user.uid,
      'senderName': user.displayName,
      'senderPhotoUrl': user.photoUrl
    };

    if (imgFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imgFile);
      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl'] = url;
    }

    if (text != null) data['text'] = text;
    Firestore.instance.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: Text('App Name'),
          elevation: 0,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('messages').snapshots(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      List<DocumentSnapshot> documents =
                          snapshot.data.documents.reversed.toList();

                      return ListView.builder(
                          itemCount: documents.length,
                          reverse: true, //mensagens mostrar debaixo para cima
                          itemBuilder: (context, index) {
                            return ListTile(
                                title:
                                    ChatMessage(documents[index].data, true));
                          });

                      break;
                  }
                },
              ),
            ),
            TextComposer(_sendMessage),
          ],
        ));
  }
}
