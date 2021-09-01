import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stage4viscuit/login/loginStyleSheet.dart';
import 'package:stage4viscuit/login/signUpPage.dart';
import 'package:stage4viscuit/main.dart';
import 'package:stage4viscuit/profilePage/profilePage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _idController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("loginPage"),
      ),
      body: Center(
          child: Container(
        width: 200,
        height: 600,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                decoration: LoginStyleSheet.loginInputBoxDeco,
                child: TextFormField(
                  controller: _idController,
                  decoration: LoginStyleSheet.emailInputDeco,
                ),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: LoginStyleSheet.passwordInputDeco,
              ),
              TextButton(
                  onPressed: () {
                    // 파이어베이스어스로 로그인하고 로그인 성공하면 메인페이지로 이동
                    FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: _idController.text,
                            password: _passwordController.text)
                        .then((value) {
                      setState(() {});
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ProfilePage(nullSaftyUid(value.user))));
                    }).catchError((e) {
                      FirebaseAuthException error = e;
                      //TODO: 로그인 에러 잡는 코드 작성 필요
                      print(e);
                      if (error.code == "hello") {}
                    });
                  },
                  child: Text("Login")),
              TextButton(onPressed: () {}, child: Text("Join The Class")),
              TextButton(
                  onPressed: () {
                    //TODO: 디버그 프린트 문 지우기
                    print("sign up button was clicked");
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignUpPage()));
                  },
                  child: Text("Sign Up"))
            ],
          ),
        ),
      )),
    );
  }
}
