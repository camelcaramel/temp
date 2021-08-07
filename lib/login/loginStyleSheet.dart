import 'package:flutter/material.dart';

class LoginStyleSheet {
  static final emailInputDeco = new InputDecoration(
    icon: Icon(Icons.email),
    labelText: "이메일",
  );
  static final passwordInputDeco = new InputDecoration(
    icon: Icon(Icons.password),
    labelText: "비밀번호",
  );
  static final nameInputDeco = new InputDecoration(
    icon: Icon(Icons.people),
    labelText: "이름",
  );
  static final loginInputBoxDeco = new BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: Colors.blue),
  );
}
