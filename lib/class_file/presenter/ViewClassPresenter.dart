import 'package:flutter/material.dart';
import 'package:stage4viscuit/userInfo/userInfo.dart';

class ViewClassPresenter {
  late UserData info;
  late BuildContext context;

  ViewClassPresenter(UserData login, BuildContext nowContext) {
    info = login;
    context = nowContext;
  }
}

class ButtonPresenter {
  ButtonPresenter() {}
}
