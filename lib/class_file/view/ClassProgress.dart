import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stage4viscuit/class_file/presenter/ClassprogressPresenter.dart';
import 'package:stage4viscuit/class_file/presenter/ViewClassPresenter.dart';
import 'package:stage4viscuit/userInfo/userInfo.dart';

class ClassProgress extends StatefulWidget {
  final String classCode;
  final String className;

  const ClassProgress(this.classCode, this.className, {Key? key})
      : super(key: key);

  @override
  _ClassProgressState createState() => _ClassProgressState();
}

class _ClassProgressState extends State<ClassProgress> {
  ClasspregressPresenter classprogressPresenter = new ClasspregressPresenter();
  List<UserButton> userButton = [];

  void initState() {
    super.initState();

    //userButton.add(UserButton('haha', 'zxc', 1));

    FirebaseFirestore.instance
        .collection('Class')
        .doc(widget.classCode)
        .get()
        .then((value) {
      setState(() {
        List<dynamic> usersCode = value.get('ClassMember');
        List<String> usersName = [];
        List<dynamic> usersScore = value.get('ClassScore');

        for (int i = 0; i < usersCode.length; i++) {
          FirebaseFirestore.instance
              .collection('Users')
              .doc(usersCode[i].toString())
              .get()
              .then((userInstance) {
            setState(() {
              print(userInstance.get('name').toString());
              print(usersCode[i].toString());
              print(int.parse(usersScore[i].toString()));
              userButton.add(UserButton(
                  userInstance.get('name').toString(),
                  usersCode[i].toString(),
                  int.parse(usersScore[i].toString()),
                  widget.classCode));
              //print(userInstance.get('name'));
              //usersName.add(userInstance.get('name'));
            });
          });
        }
        print(usersCode);
        print(usersName);
        print(usersScore);
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.className),
        ),
        body: Row(
          children: [
            Column(
              children: userButton,
            ),
            //ElevatedButton(onPressed: getPressed, child: Text('Submit')),
          ],
        ));
  }
}

class UserButton extends StatefulWidget {
  final String userName;
  final String userID;
  final int userScore;
  final String classID;

  const UserButton(this.userName, this.userID, this.userScore, this.classID,
      {Key? key})
      : super(key: key);

  @override
  _UserButtonState createState() => _UserButtonState();
}

class _UserButtonState extends State<UserButton> {
  final test = TextEditingController();

  void getPressed() {
    int changedScore = int.parse(test.text);

    FirebaseFirestore.instance
        .collection('Class')
        .doc(widget.classID)
        .get()
        .then((value) {
      setState(() {
        List<dynamic> userCodeList = value.get('ClassMember');
        List<dynamic> userScoreList = value.get('ClassScore');
        //late int pivot;

        for (int i = 0; i < userCodeList.length; i++) {
          if (userCodeList[i].toString() == widget.userID) {
            userScoreList[i] = changedScore;
            FirebaseFirestore.instance
                .collection('Class')
                .doc(widget.classID)
                .update({'ClassScore': userScoreList});
            break;
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
            width: 300,
            child: TextField(
              //obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: widget.userName,
              ),
              controller: test,
            )),
        SizedBox(
            width: 300,
            child: ElevatedButton(
              onPressed: getPressed,
              child: Text('Submit ' + widget.userName + ' Score'),
            ))
      ],
    );
    /*TextField(
      //obscureText: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: widget.userName,
      ),
      controller: test,
    );*/
  }
}
