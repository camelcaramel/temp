import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stage4viscuit/userInfo/userInfo.dart';

class JoinClassPresenter {
  final classCode = TextEditingController();
  late BuildContext context;
  late UserData info;
  late List<dynamic> classUsers;

  JoinClassPresenter(UserData login, BuildContext nowContext) {
    info = login;
    context = nowContext;
  }

  void whenClickJoin() {
    FirebaseFirestore.instance.collection('Class').get().then((value) {
      String classID;
      for (var item in value.docs) {
        print(item.get('ClassCode'));
        if (item.get('ClassCode') == classCode.text) {
          classUsers = item.get('ClassMember');
          for (var name in classUsers) {
            //중복처리하는 부분
          }
          classUsers.add(info.uid);

          updateUsers(item.id);

          break;
        }
      }
    });
    Navigator.pop(context);
  }

  void updateUsers(String ID) {
    FirebaseFirestore.instance
        .collection('Class')
        .doc(ID)
        .update({"ClassMember": classUsers}).then((value) {
      print('업데이트 끝');
    });
  }
}
