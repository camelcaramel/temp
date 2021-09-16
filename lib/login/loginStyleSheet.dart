import 'package:flutter/material.dart';

class LoginStyleSheet {
  static final emailInputDeco = new InputDecoration(
    icon: Icon(Icons.email),
    labelText: "email",
  );
  static final passwordInputDeco = new InputDecoration(
    icon: Icon(Icons.password),
    labelText: "password",
  );
  static final nameInputDeco = new InputDecoration(
    icon: Icon(Icons.people),
    labelText: "name",
  );
  static final loginInputBoxDeco = new BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: Colors.blue),
  );
  static final BoxDecoration TextboxDeco = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: Colors.blue),
  );
}
