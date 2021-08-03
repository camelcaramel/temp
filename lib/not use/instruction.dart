import '../classes/component/component.dart';
import 'dart:convert';
import 'dart:ui' as UI;
import 'dart:math';
import '../classes/presenter/controller.dart';
import '../classes/test/debug.dart';

class Instruction {
  static const double MARGIN = 10; // ADJUST
  final SOMap _head;
  final SOMap _body;
  // EdgeInsets을 사용하는 것도 고려해볼 것
  late final double _top;
  late final double _left;
  late final double _bottom;
  late final double _right;
  late final StageObject relativeCriterionSO;

  late UI.Offset absoluteOffset = UI.Offset.zero;

  late Map<String, AnimationType> correspondingATMap;

  Instruction(this._head, this._body) {
    Iterable<StageObject> headIterable = _head.iteratorOnSO();
    relativeCriterionSO = headIterable.first;

    _head.translate(-relativeCriterionSO.offset);
    _body.translate(-relativeCriterionSO.offset);
    _calcSizeWithMargin(headIterable);
    correspondingATMap = _getAnimationType();
  }

  _calcSizeWithMargin(Iterable<StageObject> headIterable) {
    double top = double.infinity, bottom = double.negativeInfinity;
    double left = double.infinity, right = double.negativeInfinity;

    for(StageObject so in headIterable) {
      top = min(top, so.offset.dy);
      bottom = max(bottom, so.offset.dy);
      left = min(left, so.offset.dx);
      right = max(right, so.offset.dx);
    }

    _top = relativeCriterionSO.offset.dy - top + MARGIN;
    _left = relativeCriterionSO.offset.dx - left + MARGIN;
    _bottom = bottom - relativeCriterionSO.offset.dy + MARGIN;
    _right = right - relativeCriterionSO.offset.dx + MARGIN;
  }

  Map<String, AnimationType> _getAnimationType() {
    Set<String> setOfNameOnHeadAndBody = <String> {};
    Map<String, AnimationType> result = {};

    setOfNameOnHeadAndBody.addAll(head.keys);
    setOfNameOnHeadAndBody.addAll(body.keys);

    late AnimationType type;
    for(String nameOfSO in setOfNameOnHeadAndBody) {
      int hLen = _head[nameOfSO].length,
          bLen = _body[nameOfSO].length;

      if (hLen == 1 && bLen > 1)
        type = AnimationType.DUPLICATE;
      else if (hLen > 1 && bLen == 1)
        type = AnimationType.MERGE;
      else if (hLen > 1 && bLen > 1)
        type = AnimationType.MANY;
      else if (hLen == 0)
        type = AnimationType.CREATE;
      else if (bLen == 0)
        type = AnimationType.VANISH;
      else if (hLen == 1 && bLen == 1) type = AnimationType.ONE;

      result[nameOfSO] = type;
    }

    return result;
  }

  set setAbsoluteOffsetToCriterion(UI.Offset offset) => absoluteOffset = offset;
  SOMap get head {
    _head.translate(-relativeCriterionSO.offset + absoluteOffset);
    return _head;
  }
  SOMap get body {
    _body.translate(-relativeCriterionSO.offset + absoluteOffset);
    return _body;
  }
  UI.Rect get possibleSection {
    return UI.Rect.fromLTRB(
        absoluteOffset.dx - _left,
        absoluteOffset.dy - _top,
        absoluteOffset.dx + _right,
        absoluteOffset.dy + _bottom
    );
  }
}

// Controller가 기대하는 것
// 데이터 가져오기
// 데이터 변화 알려주기
//  - 로드 중인지
//  - 최신 상태인지
//  - 기타 등등
class InstructionSource {
  static late final InstructionSource instance;
  InstructionSource();

  List<Instruction> instructions = []; // only engine's access acceptable!!

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
  void create(String jsonString) {
    _notify("create", arg1: "start");
    instructions.clear();
    append(jsonString);
    _notify("create", arg2: "end");
  }
  void append(String jsonString) {
    _notify("append", arg1: "start");
    instructions.addAll(_getInstructionsFromJson(jsonString));
    _notify("append", arg1: "end");
  }

  // 내부 함수
  List<Instruction> _getInstructionsFromJson(String jsonString) {
    List<Instruction> instructions = [];
    if(jsonString.isEmpty) return instructions;

    Map<String, dynamic> jsonObj = jsonDecode(jsonString);

    var instructionJsonObjArr = jsonObj["rules"];
    for(var instructionJsonObj in instructionJsonObjArr) {
      Instruction instruction = _createInstruction(instructionJsonObj);
      instructions.add(instruction);
    }

    return instructions;
  }

  Instruction _createInstruction(var instructionJsonObj) {
    SOMap head = _createSOMapFromJsonObj(instructionJsonObj["head"]);
    SOMap body = _createSOMapFromJsonObj(instructionJsonObj["body"]);

    return Instruction(head, body);
  }

  /*
  SOMap _createSOMapFromJsonObj(var soJsonObjArr) {
    SOMap soMap = SOMap();

    for (var soJsonObj in soJsonObjArr) {
      String type = soJsonObj["type"];
      String name = soJsonObj["name"];

      UI.Offset offset = UI.Offset(soJsonObj["x"].toDouble(), soJsonObj["y"].toDouble());
      double rotation = soJsonObj["rotation"].toDouble();

      soMap.addSO(StageObject.named(name: name, offset: offset, rotation: rotation, type: type));
    }

    return soMap;
  }
   */

  // DEBUG
  Iterator<String> iterator = LocalImageSource.instance.images.keys.iterator;
  Map<String, String> nameMap = {};
  SOMap _createSOMapFromJsonObj(var soJsonObjArr) {
    SOMap soMap = SOMap();

    for (var soJsonObj in soJsonObjArr) {
      String type = soJsonObj["type"];

      String name = soJsonObj["name"];
      if(nameMap.containsKey(name)) {
        print("1: $name");
        name = nameMap[name]!;
      } else {
        if(!iterator.moveNext()) {
          throw "error: 준비된 이미지보다 더 많은 이미지를 필요로 합니다.";
        }
        nameMap[name] = iterator.current;
        print("2: $name");
        name = iterator.current;
        print("3: $name");

      }

      UI.Offset offset = UI.Offset(soJsonObj["x"].toDouble(), soJsonObj["y"].toDouble());
      double rotation = soJsonObj["rotation"].toDouble();

      soMap.addSO(StageObject.named(name: name, offset: offset, rotation: rotation, type: type));
    }

    return soMap;
  }
}