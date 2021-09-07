import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stage4viscuit/class_file/presenter/ViewClassPresenter.dart';
import 'package:stage4viscuit/class_file/view/ClassProgress.dart';
import 'package:stage4viscuit/userInfo/userInfo.dart';

class ViewClass extends StatefulWidget {
  final UserData user;

  const ViewClass(this.user, {Key? key}) : super(key: key);

  @override
  _ViewClassState createState() => _ViewClassState();
}

class _ViewClassState extends State<ViewClass> {
  late ViewClassPresenter viewPresenter;
  List<ClassButton> classList = [];

  @override
  void initState() {
    super.initState();
    viewPresenter = new ViewClassPresenter(widget.user, context);

    FirebaseFirestore.instance.collection('Class').get().then((value) {
      setState(() {
        List<dynamic> usersCode = [];

        for (var item in value.docs) {
          usersCode = item.get('ClassMember');

          bool flag = false;
          for (var code in usersCode) {
            if (code.toString() == widget.user.uid) {
              flag = true;
              break;
            }
          }
          if (flag == true) {
            classList.add(ClassButton(
                item.get('ClassName').toString(), item.id.toString()));
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.user.name + '님의 클래스'),
        ),
        body:
            //Column(children: classList)
            ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: classList.length,
          itemBuilder: (BuildContext context, int index) {
            return classList[index];
          },
        ));
  }
}

class ClassButton extends StatefulWidget {
  final String ClassID;
  final String ClassName;

  const ClassButton(this.ClassName, this.ClassID, {Key? key}) : super(key: key);

  @override
  _ClassButtonState createState() => _ClassButtonState();
}

class _ClassButtonState extends State<ClassButton> {
  late ButtonPresenter buttonPresenter;

  @override
  void initState() {
    buttonPresenter = new ButtonPresenter();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ClassProgress(widget.ClassID, widget.ClassName)),
          );
        },
        child: Text(widget.ClassName));
  }
}
