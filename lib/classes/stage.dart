import 'component.dart';
import 'package:more/collection.dart';
import 'engine.dart';
import 'dart:ui' as UI;
import 'controller.dart';
import 'package:flutter/material.dart';

class Stage {
  final ImageSource imageSource;
  late SOMap soMapOnStage;
  late SOMap? soMapFromEngine;

  Stage({required this.imageSource}) {
   StageSource.instance = StageSource(imageSource: this.imageSource);
  }

  void draw(UI.Canvas canvas) {
    for (StageObject so in soMapOnStage.iteratorOnSO()) {
      _drawSO(so, canvas);
    }

    for (StageObject so in soMapFromEngine!.iteratorOnSO()) {
      _drawSO(so, canvas);
    }
  }

  void _drawSO(StageObject so, Canvas canvas) {
    if (so.isEmpty()) return;
  }

  SOMap getSOMapAtStart() {
    if (soMapFromEngine == null) return StageSource.instance.firstSOMap;
    return soMapOnStage;
  }

  //void removeOnStage(StageObject so) { }

  void removeAllOnStage(Iterable<StageObject> iterable) {}

  void removeSOInInstructionSection(List<InstructionSection> listOfIS) {
    for (InstructionSection instructionSection in listOfIS) {
      removeAllOnStage(instructionSection.correspondingSOMap.iteratorOnSO());
    }
  }
}

// Controller가 기대하는 것
// 데이터 가져오기
// 데이터(firstMap) '변화' 알려주기
//  - 로드 중인지
//  - 최신 상태인지
//  - 기타 등등
class StageSource {
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


class DraggableBlankBox extends StatefulWidget {
  final StageObject so;
  final Offset paintOffset;
  final ImageSource imageSource;

  DraggableBlankBox(
      {required this.so, required this.paintOffset, required this.imageSource});

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
            width: widget.imageSource.getSize(widget.so.name).width,
            height: widget.imageSource.getSize(widget.so.name).height,
            child: Text(""),
          ),
          feedback:
              Image.memory(widget.imageSource.getByteImage(widget.so.name)),
          onDragStarted: () {
            StageSource.instance.remove(mouseDownOffset);
          },
          onDragEnd: (var details) {
            final Offset mouseUpOffset = details.offset - widget.paintOffset;

            // TODO: canvas의 사이즈를 조사하여 넘어가는 이미지를 그리지 않는 처리 필요

            widget.so.offset = mouseUpOffset;
            StageSource.instance.add(widget.so);
          },
        ),
      ),
    );
  }
}
