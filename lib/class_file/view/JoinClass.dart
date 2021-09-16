import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stage4viscuit/class_file/presenter/JoinClassPresenter.dart';
import 'package:stage4viscuit/class_file/presenter/ViewClassPresenter.dart';
import 'package:stage4viscuit/userInfo/userInfo.dart';

class JoinClass extends StatefulWidget {
  final UserData user;
  const JoinClass(this.user, {Key? key}) : super(key: key);

  @override
  _JoinClassState createState() => _JoinClassState();
}

class _JoinClassState extends State<JoinClass> {
  late JoinClassPresenter joinClassPreseter;

  void initState() {
    super.initState();
    joinClassPreseter = new JoinClassPresenter(widget.user, context);
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Join Class'),
        ),
        body: Center(
          child: Container(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  //obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Class Code',
                  ),
                  controller: joinClassPreseter.classCode,
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          joinClassPreseter.whenClickJoin();
                        });
                      },
                      child: Text('Accept'),
                    ))
              ],
            ),
          ),
        ));
  }
}
