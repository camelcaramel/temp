import 'dart:typed_data';
import 'dart:ui' as UI;
import 'package:flutter/material.dart';
import '../classes/component/exception.dart';
import '../classes/component/component.dart';
import '../classes/presenter/stage_presenter.dart';

enum StageStatus {
  RUN,
  STOP,
  PAUSE,
}

class Stage {
  static late final Stage instance;
  static bool _isCreated = false;
  static Future<void> create(AnimationController animationController, setState) async {
    if(_isCreated) return Future<void>.value();

    instance = Stage._(animationController, setState);
    await instance.initialize();
    await instance.presenter.initialize();
    _isCreated = true;
  }

  final AnimationController animationController;
  final setState;
  late final Presenter presenter;
  StageStatus status;

  Stage._(this.animationController, this.setState) : status = StageStatus.STOP {
    presenter = Presenter(stage: this);

    animationController.addListener(() {

      setState(() {

      });
    });
    // 만약 다음의 상황이 일어날 경우 미묘한 이상함이 존재할 수 있음
    // 일단 인지는 해놓자
    // 1. d=0.998일 때의 그림이 그려짐
    // 2. addStatusListener 콜백 함수 실행 -> engineResult가 다음값으로 변경됨
    // 3. engineResult를 토대로 그림
    animationController.addStatusListener((status) {
      if(status == AnimationStatus.completed) {
        if(presenter.storage.erStorage.isEmpty) throw NoElementException();
        presenter.engineResult = presenter.storage.erStorage.poll();
      }
    });

  }

  Future<void> initialize() async {

  }

  void draw(Canvas canvas) {
    switch(status) {
      case StageStatus.STOP:
        SOMap soMap = presenter.storage.msStorage.base;
        _draw(canvas, soMap);
        break;
      case StageStatus.PAUSE:

        break;
      case StageStatus.RUN:
        _draw(canvas, presenter.getUnchangedSOs());
        _draw(canvas, presenter.getChangedSOs(animationController.value));
        break;
    }
  }
  void _draw(Canvas canvas, SOMap soMap) {
    Paint paint = Paint();

    for(MapEntry<String, SOList> entry in soMap.entries) {
      UI.Image img = presenter.storage.imgStorage.uiImg(entry.key);

      for(StageObject so in entry.value) {
        canvas.drawImage(img, so.offset, paint);
      }

      img.dispose();
    }
  }

  void stop() async {
    await presenter.stop();

    status = StageStatus.STOP;
    animationController.reset();
  }
  void start() async {
    await presenter.start();

    status = StageStatus.RUN;
    animationController.repeat();
  }
}

/*
class StageSource1 {
  static late final StageSource instance;

  final ImageSource _imageSource;
  StageSource({required imageSource}) : _imageSource = imageSource;

  SOMap firstSOMap = SOMap(); // only stage's access acceptable!!

  final List<Observer> observers = [];
  //Observer패턴
  void register(Observer observer) {
    observers.add(observer);
  }
  void _notify(String msg, {arg1, arg2, arg3}) {
    for(Observer observer in observers) {
      observer.update(
          whatSource: "Instruction",
          msg: msg,
          arg1: arg1,
          arg2: arg2,
          arg3: arg3
      );
    }
  }

  // public API
  void add(StageObject so) {
    _notify("add", arg1: "start");
    firstSOMap.addSO(so);
    _notify("add", arg1: "end");
  }
  void remove(Offset offset) {
    _notify("remove", arg1: "start");
    StageObject? so = find(offset);
    if(so != null) firstSOMap.removeSO(so);
  }
  StageObject? find(Offset offset) {
    for (StageObject so in firstSOMap.iteratorOnSO()) {
      Rect rect = Rect.fromLTWH(
          so.offset.dx,
          so.offset.dy,
          _imageSource.getSize(so.name).width,
          _imageSource.getSize(so.name).height);

      if (rect.contains(offset)) return so;
    }
    return null;
  }

  // 이미지 위에 draggable한 투명 박스 생성
  List<Widget> createDraggableWidget(Offset paintOffset) {
    List<Widget> draggableBlankBoxes = [];
    for (StageObject so in firstSOMap.iteratorOnSO()) {
      draggableBlankBoxes.add(DraggableBlankBox(
          so: so, paintOffset: paintOffset, imageSource: _imageSource));
    }

    return draggableBlankBoxes;
  }

}
*/

class DraggableBlankBox extends StatefulWidget {
  final StageObject so;
  final Offset paintOffset;
  final Uint8List byteImg;
  final UI.Size size;

  DraggableBlankBox({
    required this.so,
    required this.paintOffset,
    required this.byteImg,
    required this.size
  });

  _DraggableBlankBoxState createState() => _DraggableBlankBoxState();
}

class _DraggableBlankBoxState extends State<DraggableBlankBox> {
  late Offset mouseDownOffset;

  Widget build(BuildContext context) {
    return Positioned(
      left: widget.so.offset.dx,
      top: widget.so.offset.dy,
      child: GestureDetector(
        onPanDown: (var details) {
          mouseDownOffset = details.globalPosition - widget.paintOffset;
        },
        child: Draggable(
          child: Container(
            width: widget.size.width,
            height: widget.size.height,
            child: Text(""),
          ),
          feedback:
              Image.memory(widget.byteImg),
          onDragStarted: () {
            //StageSource.instance.remove(mouseDownOffset);
          },
          onDragEnd: (var details) {
            final Offset mouseUpOffset = details.offset - widget.paintOffset;

            // TODO: canvas의 사이즈를 조사하여 넘어가는 이미지를 그리지 않는 처리 필요

            widget.so.offset = mouseUpOffset;
            //StageSource.instance.add(widget.so);
          },
        ),
      ),
    );
  }
}

