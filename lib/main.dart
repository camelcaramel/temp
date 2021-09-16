import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stage4viscuit/profilePage/profilePage.dart';
import 'package:stage4viscuit/userInfo/userInfo.dart';

import 'login/loginPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final Future<FirebaseApp> _initalization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    String uid = "rF1WcFOen4Y8Zg0aGCosUeKmSzq2";
    // return ProfilePage(uid);

    // return FutureBuilder(
    //     future: _initalization,
    //     builder: (context, snapshot) {
    //       if (snapshot.hasError) {
    //         // TODO: error handling need
    //         print("firebase init error occurred");
    //       }
    //       if (snapshot.connectionState == ConnectionState.done) {
    //         print('connection no problem');

    return MaterialApp(
      title: 'GiDDong',
      theme: ThemeData(primarySwatch: Colors.blue, primaryColor: Colors.black),
      home: ProfilePage(uid),
      // home: Splash(),
      debugShowCheckedModeBanner: false,
    );
    //       }
    //       return CircularProgressIndicator();
    //     });
  }
}

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool isReady = false;
  late UserData info;

  String nullSaftyUid(User? user) {
    if (user != null) {
      if (user.uid.isEmpty) {
        return "nothing";
      } else {
        print("useruid = ${user.uid}");
        return user.uid;
      }
    } else {
      return "nothing";
    }
  }

  Map<String, dynamic> nullSaftyUserData(Map<String, dynamic>? data) {
    if (data != null) {
      return data;
    } else {
      throw ("error occured");
    }
  }

  String nullSaftyStringCheck(String? s) {
    if (s != null)
      return s;
    else
      throw ("string is null when load profile page");
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.setPersistence(Persistence.NONE);
    // 로그인 세션 유지 안함
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (!snapshot.hasData) {
          return LoginPage();
        } else {
          String uid = nullSaftyUid(snapshot.data);
          //TODO: remove this line
          uid = "rF1WcFOen4Y8Zg0aGCosUeKmSzq2";
          return ProfilePage(uid);
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
              },
              child: Text("logout")),
        ),
      );
    }
  }
}

class ErrorPage extends StatefulWidget {
  const ErrorPage(this.errorMessage, {Key? key}) : super(key: key);
  final String errorMessage;
  @override
  _ErrorPageState createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    return Container(child: Text(widget.errorMessage));
  }
}
