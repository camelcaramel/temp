import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'login/loginPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final Future<FirebaseApp> _initalization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initalization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // TODO: error handling need
            print("firebasae init error occured");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            print('connection no problem');

            return MaterialApp(
              title: 'GiDDong',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: Splash(),
              debugShowCheckedModeBanner: false,
            );
          }
          return CircularProgressIndicator();
        });
  }
}

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (!snapshot.hasData) {
          return LoginPage();
        } else {
          return MainPage(snapshot.data);
        }
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage(this.user, {Key? key}) : super(key: key);
  final User? user;
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late String uid;

  String nullSaftyUid(User? user) {
    if (user != null) {
      if (user.uid.isEmpty) {
        return "nothing";
      } else {
        return user.uid;
      }
    } else {
      return "nothing";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return Container(
        child: Text("unknown error"),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: ((uid = nullSaftyUid(widget.user)) == "nothing")
              ? Text("user info error")
              : Text(uid),
        ),
        body: Container(
          child: TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
              child: Text("logout")),
        ),
      );
    }
  }
}