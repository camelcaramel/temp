import 'package:collection/collection.dart';
import 'dart:ui' as UI;
import 'dart:math';
import 'animation.dart';

class StageObject {
  String type;
  String name;
  UI.Offset offset;
  double rotation;
  // Size size;
  dynamic _forTween;
  static final Function _forTweenIfBeginNull = (double x) => x;
  static final Function _forTweenIfEndNull = (double x) => 1 - x;

  StageObject(this.name, this.offset, this.rotation, [this.type = "empty", this._forTween]);
  StageObject.named({required String name, required UI.Offset offset, required double rotation, String type = "empty", dynamic forTween}) : this(name, offset, rotation, type, forTween);
  StageObject.copy(StageObject origin)
      : type = origin.type,
        name = origin.name,
        offset = origin.offset,
        rotation = origin.rotation;
  StageObject.empty()
      : type = "empty",
        name = "empty",
        offset = UI.Offset.infinite,
        rotation = double.infinity;

  /*
  dynamic get(SOKey key) {
    switch(key) {
      case SOKey.TYPE : return type;
      case SOKey.NAME : return name;
      case SOKey.OFFSET : return offset;
      case SOKey.ROTATION : return rotation;
      default: return null;
    }
  }
   */
  bool contentEquals(StageObject so) {
    return type == so.type &&
        name == so.name &&
        offset == so.offset &&
        rotation == so.rotation;
  }
  bool isEmpty() {
    return name == "empty";
  }
  String toString() {
    return '{type: $type, name: $name, offset: $offset, rotation: $rotation}';
  }


  // Tween을 위한 연산자 오버라이딩; 연산자는 다음의 식을 위해 사용됨
  // result = begin + (end - begin) * t;
  StageObject operator+ (StageObject another) {
    if(another._forTween != null) {
      return another._forTween < 0.5 ?
      StageObject.empty() :
      StageObject.named(
        type: another.type,
        name: another.name,
        offset: another.offset,
        rotation: another.rotation
      );
    }
    return StageObject.named(
      type: type,
      name: name,
      offset: offset + another.offset,
      rotation: rotation + another.rotation
    );
  }
  StageObject operator- (StageObject another) {
    if(isEmpty()) {
      return StageObject.named(   // end == StageObject.empty(); -> VANISH
        type: another.type,
        name: another.name,
        offset: another.offset,
        rotation: another.rotation,
        forTween: _forTweenIfEndNull
      );
    } else if(another.isEmpty()) {
      return StageObject.named(   // begin == StageObject.empty(); -> CREATE
        type: type,
        name: name,
        offset: offset,
        rotation: rotation,
        forTween: _forTweenIfBeginNull
      );
    }
    return StageObject.named(   // DUPLICATE, MERGE, ONE
      type: type,
      name: name,
      offset: offset - another.offset,
      rotation: rotation - another.rotation
    );
  }
  StageObject operator* (double d) {
    if(this._forTween != null) {
      _forTween = _forTween(d);
      return this;
    }
    offset *= d;
    rotation *= d;
    return this;
  }
}

abstract class Copyable<T> {
  // 호출의 주체에 대해 SO 단위까지 깊은 복사를 수행한다.
  T copy();
  T deepCopy();
}

// 최대한 SOMap 내부적으로만 사용
class SOList extends DelegatingList<StageObject> implements Copyable<SOList> {
  final List<StageObject> listOfSO;

  SOList() : this._([]);
  SOList.empty() : this._(List.empty());
  SOList._(this.listOfSO) : super(listOfSO);
  //SOList.from(List<StageObject> list) : this.listOfSO = list, super(list);

  SOList copy() {
    SOList copy = SOList();
    copy.listOfSO.addAll(this.listOfSO);
    return copy;
  }
  SOList deepCopy() {
    SOList copy = SOList();
    copy.listOfSO.addAll(this.listOfSO.map((e) {
      return StageObject.copy(e);
    }));
    return copy;
  }


  StageObject operator [](var idx) {
    if(length <= idx) {
      print("warning: SOMapIndexOutOfBoundException - $idx");
      return StageObject.empty();
    }
    return listOfSO[idx];
  }

  String toString() {
    String s = "[";
    s += listOfSO.join(", ");
    return s + "]\n";
  }
}

class SOMap extends DelegatingMap<String, SOList> implements Copyable<SOMap> {
  final Map<String, SOList> mapOfSO;

  SOMap() : this._({});
  SOMap._(this.mapOfSO) : super(mapOfSO);

  SOMap copy() {
    SOMap copy = SOMap();
    for(MapEntry<dynamic, SOList> entry in entries) {
      copy[entry.key] = entry.value.copy();
    }
    return copy;
  }
  SOMap deepCopy() {
    SOMap copy = SOMap();
    for(MapEntry<dynamic, SOList> entry in entries) {
      copy[entry.key] = entry.value.deepCopy();
    }
    return copy;
  }

  // SO 단위의 연산
  void addSO(StageObject so) {
    putIfAbsent(so.name, () => SOList()).add(so);
  }
  void removeSO(StageObject so) {
    this[so.name].remove(so);
  }
  void removeContentEqualSO(StageObject so) {
    removeSO(this[so.name].firstWhereIndexedOrNull((_, elem) => so.contentEquals(elem))!);
  }
  bool containsSO(StageObject so) {
    if(!containsKey(so.name)) return false;
    return this[so.name].contains(so);
  }

  // 전체 SO를 다루는 연산
  void translate(UI.Offset offset) {
    for(SOList listOfSO in values) {
      listOfSO.forEach((so) => so.offset += offset);
    }
  }
  Iterable<StageObject> iteratorOnSO() {
    Iterable<StageObject> iterator = Iterable.empty();
    for(SOList list in values) {
      iterator = iterator.followedBy(list);
    }
    return iterator;
  }
  void addAll(covariant SOMap another) {
    for(MapEntry<String, SOList> entry in another.entries) {
      mapOfSO.putIfAbsent(entry.key, () => SOList()).addAll(entry.value);
    }
  }

  // 널이 나오지 않도록 오버라이딩; 단, 경고를 출력
  SOList operator[] (var key) {
    if(mapOfSO[key] == null) {
      print("warning: KeyIsNotValid - SOMap[$key]");
      return SOList.empty();
    }
    return mapOfSO[key]!;
  }

  String toString() {
    String s = "{\n";
    for(MapEntry<String, SOList> entry in mapOfSO.entries) {
      s += "\t${entry.key} : ${entry.value}";
    }
    return s + "}\n";
  }
}

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

class EngineResult {
  late List<InstructionSection> listOfIS;
  late SOMap begin;
  late SOMap end;
  late SOMap unchanged;

  EngineResult(this.listOfIS, this.begin, this.end, this.unchanged);
}

class InstructionSection {
  Instruction instruction;
  SOMap correspondingSOMap;
  late SOMap finalSOMap;
  int specificity = 0;
  late UI.Offset absoluteOffset;

  //late List<Tween<StageObject>> _bindListOfSO;

  InstructionSection(this.instruction) : correspondingSOMap = SOMap();
  InstructionSection.copy(InstructionSection origin)
      : instruction = origin.instruction,
        correspondingSOMap = origin.correspondingSOMap.copy(),
        specificity = origin.specificity,
        absoluteOffset = origin.absoluteOffset;


  // correspondingSOMap, absoluteOffset을 구성하기 위한 명령어
  void addSO(StageObject so) {
    correspondingSOMap.addSO(so);
  }
  void removeSO(StageObject so) {
    correspondingSOMap[so.name].remove(so);
  }
  bool isSelectedSO(StageObject so) {
    if(!correspondingSOMap.containsKey(so.name)) return false;
    return correspondingSOMap[so.name].contains(so);
  }

  // finalSOMap을 InstructionSection마다 저장
  // 매 순간 계산하는 방법을 생각해보았으나 시간에서 너무 오버헤드가 일어날 것 같음
  void makeFinalSOMap() {
    instruction.setAbsoluteOffsetToCriterion = absoluteOffset;
    finalSOMap = instruction.body.deepCopy();
  }
}
