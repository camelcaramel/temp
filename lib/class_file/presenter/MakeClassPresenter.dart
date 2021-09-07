import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stage4viscuit/userInfo/userInfo.dart';

class MakeClassPresenter {
  final classname = TextEditingController();
  final classcode = TextEditingController();
  late UserData info;
  late BuildContext context;

  MakeClassPresenter(UserData login, BuildContext nowContext) {
    info = login;
    context = nowContext;
  }

  void ClassMakePushed() {
    FirebaseFirestore.instance.collection('Class').add({
      "ClassName": classname.text,
      "ClassCode": classcode.text,
      "ClassMember": [info.uid]
    }).then((value) {
      // 파이어스토어에 올바르게 저장이 된다면 아래 코드 실행
      print("class register user info done");
    }).catchError((e) {
      // 파이어스토어에 유저 정보 저장 중 오류가 발생하는 경우
      print("error occured in register class info error string : \n $e");
    });

    Navigator.pop(context);
  }
}
