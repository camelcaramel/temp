import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _idController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _userNameController = new TextEditingController();

  void signUpProcess(String id, String password, String name) {
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: id, password: password)
        .then((value) {
      // 올바르게 유저가 회원가입이 된다면
      print("create user done");

      User? user = value.user;
      if (user == null) {
        // user null safty 검사 만약 널이라면 엑셉션 발생
        return Exception("user is empty error");
      } else {
        // 유저의 정보를 파이어스토어에 저장
        // TODO: 여기 지금 카테고리가 무조건 선생으로 만들어지게 되어있음
        FirebaseFirestore.instance.collection("Users").doc(user.uid).set({
          "email": id,
          "name": name,
          "category": "teacher",
          "uid": user.uid,
          "projectList": []
        }).then((value) {
          // 파이어스토어에 올바르게 저장이 된다면 아래 코드 실행
          print("register user info done");
          Navigator.pop(context);
        }).catchError((e) {
          // 파이어스토어에 유저 정보 저장 중 오류가 발생하는 경우
          print("error occured in register user info error string : \n $e");
        });
      }
    }).catchError((e) {
      // 어센티케이션에 저장 중에 오류가 발생한다면 아래 코드 실행
      print("error occured in create user errorcode : /n $e");
    }).onError((error, stackTrace) {
      // 테스트 코드
      print("on Error");
      print("error thing : ${error}");
      print("stackTrace : $stackTrace");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("signUpPage"),
      ),
      body: Center(
          child: Container(
        width: 200,
        height: 600,
        child: Column(
          children: [
            TextFormField(
              controller: _userNameController,
            ),
            TextFormField(
              controller: _idController,
            ),
            TextFormField(
              controller: _passwordController,
            ),
            TextButton(
                onPressed: () {
                  String email = _idController.text;
                  String password = _passwordController.text;
                  String userName = _userNameController.text;

                  // 회원가입과 사용자 정보를 파이어스토어에 저장
                  signUpProcess(email, password, userName);
                },
                child: Text("Sign Up"))
          ],
        ),
      )),
    );
  }
}
