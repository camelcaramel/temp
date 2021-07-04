import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:stage4viscuit/classes/instruction.dart';
import 'package:stage4viscuit/classes/stage.dart';
import 'package:stage4viscuit/classes/engine.dart';
import 'package:stage4viscuit/classes/component.dart';
import 'dart:ui' as UI;
import 'package:flutter/animation.dart';
import 'util_.dart';


// TODO : 명령어 파싱 디버깅 ✔
// TODO : 명령어 내 name을 적절한 값으로 치환 ✔
// TODO : 에셋 로드 전 circular 표시 ✔
// TODO : 명령어 json 입력창 구현
// TODO : 아웃풋창 구현


abstract class ImageSource {
  UI.Image getImage(String name);
  Uint8List getByteImage(String name);
  UI.Size getSize(String name);
}

abstract class IController {
  void play();
  void pause();
  void stop();

}

abstract class Observer {
  void update({required String whatSource, required String msg, arg1, arg2, arg3});
}


class Controller implements IController, Observer {
  final stage;
  final engine;

  double d = 0;

  //late UI.Canvas canvas; // need to initailize every tick
  final setState;
  final AnimationController animationController;

  Controller({required this.animationController, required this.setState, required ImageSource imageSource})
      : stage = Stage(imageSource: imageSource), engine = Engine() {
    StageSource.instance.register(this);
    InstructionSource.instance.register(this);

    animationController.addStatusListener((status) {
      if(status == AnimationStatus.dismissed) {
        List<InstructionSection> listOfIS = engine.ready(stage.getSOMapAtStart());
        stage.removeSOInInstructionSection(listOfIS);

      } else if(status == AnimationStatus.completed) {
        stage.soMapOnStage.addAll(engine.end());
      }
    });

    animationController.addListener(() {
      // 그리기
      setState(() {
        d = animationController.value;

        SOMap soMapFromEngine = engine.run(d);
        stage.soMapFromEngine = soMapFromEngine;

      });
    });
  }

  void update({required String whatSource, required String msg, arg1, arg2, arg3}) {
    switch(whatSource) {
      case "instruction": {


        break;
      }
      case "stage": {


        break;
      }
    }
    stop();
  }

  void play() {
    animationController.repeat();
  }

  void pause() {
    animationController.value = 0;
  }

  void stop() {
    stage.soMapFromEngine = null;
    animationController.value = d = 0;
  }
}