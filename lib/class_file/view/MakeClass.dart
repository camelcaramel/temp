import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stage4viscuit/class_file/presenter/MakeClassPresenter.dart';
import 'package:stage4viscuit/userInfo/userInfo.dart';

class MakeClass extends StatefulWidget {
  final UserData user;

  const MakeClass(this.user, {Key? key}) : super(key: key);

  @override
  _MakeClassState createState() => _MakeClassState();
}

class _MakeClassState extends State<MakeClass> {
  late MakeClassPresenter classPresenter;

  void initState() {
    super.initState();
    classPresenter = new MakeClassPresenter(widget.user, context);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("makeclass"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            //새 클래스 이름 입력
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: 300,
                  child: TextField(
                    //obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Class Name',
                    ),
                    controller: classPresenter.classname,
                  )),
            ],
          ),
          Row(
            //새 클래스 이름 입력
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: 300,
                  child: TextField(
                    //obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Class Code',
                    ),
                    controller: classPresenter.classcode,
                  )),
            ],
          ),
          Row(
            //모두 입력하고 버튼 눌렀을때
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      classPresenter.ClassMakePushed();
                    },
                    child: Text('Accept'),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
