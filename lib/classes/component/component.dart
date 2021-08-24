import 'package:collection/collection.dart';
import 'package:flutter/animation.dart';
import 'dart:ui' as UI;
import 'dart:math';
import 'animation.dart';
import '../component/exception.dart';

// TODO: engine_test를 위해서 AnimationType을 잠시 비활성화

typedef AnimationDouble = double;
typedef TestVisibleCallBack = bool Function(AnimationDouble value);

class StageObject {
  String type;
  String name;
  UI.Offset offset;
  double rotation;
  // Size size;
  late TestVisibleCallBack isVisible = (value) => true;

  static final Function _fadeIn = (double x) => x;
  static final Function _fadeOut = (double x) => 1 - x;

  StageObject(this.name, this.offset, this.rotation, [this.type = "empty"]);
  StageObject.named({required this.name, required this.offset, required this.rotation, this.type = "empty"});
  StageObject.clone(StageObject origin) : type = origin.type, name = origin.name, offset = origin.offset, rotation = origin.rotation;

  bool contentEquals(StageObject so) {
    return type == so.type &&
        name == so.name &&
        offset == so.offset &&
        rotation == so.rotation;
  }
  String toString() {
    return '{type: $type, name: $name, offset: $offset, rotation: $rotation}';
  }

  static StageObject lerp(StageObject? begin, StageObject? end, double d) {
    if(begin == null && end == null) throw Exception("적어도 하나의 값은 null이 아니어야 합니다.");

    bool isTwoNotNull = begin != null && end != null;
    if(isTwoNotNull) {
      if(begin.name != end.name || begin.type != end.type) throw Exception("StageObject의 타입과 이름이 같아야 합니다.");
    }

    UI.Offset interpolatedOffset = isTwoNotNull ? UI.Offset.lerp(begin.offset, end.offset, d)! : (begin ?? end)!.offset;
    double interpolatedRotation = isTwoNotNull ? begin.rotation + (1 - d) * end.rotation : (begin ?? end)!.rotation;

    StageObject interpolatedSO = StageObject.named(
        name: (begin ?? end)!.name,
        offset: interpolatedOffset,
        rotation: interpolatedRotation
    );
    if(begin == null) {
      interpolatedSO.isVisible = (value) => _fadeIn(value) >= 0.5;
    } else if(end == null) {
      interpolatedSO.isVisible = (value) => _fadeOut(value) >= 0.5;
    }

    return interpolatedSO;
  }
  /*
  bool get isNone => type == "none" && name == "none";

  StageObject.non1e()
      : type = "none",
        name = "none",
        offset = UI.Offset.infinite,
        rotation = double.infinity;

  // Tween을 위한 연산자 오버라이딩; 연산자는 다음의 식을 위해 사용됨
  // result = begin + (end - begin) * t;
  StageObject operator+ (StageObject another) {
    if(another._forTween != null) {
      return another._forTween < 0.5 ?
      StageObject.none() :
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
    if(isNone) {
      return StageObject._(   // end == StageObject.empty(); -> VANISH
        type: another.type,
        name: another.name,
        offset: another.offset,
        rotation: another.rotation,
        forTween: _forTweenIfEndNull
      );
    } else if(another.isNone) {
      return StageObject._(   // begin == StageObject.empty(); -> CREATE
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

   */
}

abstract class Copyable<T> {
  // 호출의 주체에 대해 SO 단위까지 깊은 복사를 수행한다.
  T copy();
  T deepCopy();
}

abstract class DefaultSOOperation {
  void add(StageObject so);
  bool removeFirstIdentityEqual(StageObject so);
  bool removeFirstContentEqual(StageObject so);
  bool removeAllIdentityEqual(StageObject so);
  bool removeAllContentEqual(StageObject so);
  bool containIdentityEqual(StageObject so);
  bool containContentEqual(StageObject so);
}


// 최대한 SOMap 내부적으로만 사용
class SOList extends DelegatingList<StageObject> implements Copyable<SOList>, DefaultSOOperation {
  final List<StageObject> _listOfSO;

  SOList() : this._([]);
  SOList.empty() : this._(List.empty());
  SOList._(this._listOfSO) : super(_listOfSO);

  SOList copy() {
    SOList copy = SOList();
    copy._listOfSO.addAll(this._listOfSO);
    return copy;
  }
  SOList deepCopy() {
    SOList copy = SOList();
    copy._listOfSO.addAll(this._listOfSO.map((e) {
      return StageObject.clone(e);
    }));
    return copy;
  }
  void add(StageObject so) {
    _listOfSO.add(so);
  }
  bool removeFirstIdentityEqual(StageObject so) {
    for(int i = 0; i < _listOfSO.length; i++) {
      if(!identical(so, _listOfSO[i])) continue;

      _listOfSO.removeAt(i);
      return true;
    }
    return false;
  }
  bool removeFirstContentEqual(StageObject so) {
    for(int i = 0; i < _listOfSO.length; i++) {
      if(!so.contentEquals(_listOfSO[i])) continue;

      _listOfSO.removeAt(i);
      return true;
    }
    return false;
  }
  bool removeAllIdentityEqual(StageObject so) {
    int originLength = _listOfSO.length;
    _listOfSO.removeWhere((e) => identical(e, so));
    return originLength != _listOfSO.length;
  }
  bool removeAllContentEqual(StageObject so) {
    int originLength = _listOfSO.length;
    _listOfSO.removeWhere((e) => so.contentEquals(e));
    return originLength != _listOfSO.length;
  }
  bool containIdentityEqual(StageObject so) {
    for(int i = 0; i < _listOfSO.length; i++) {
      if(!identical(so, _listOfSO[i])) continue;
      return true;
    }
    return false;
  }
  bool containContentEqual(StageObject so) {
    for(int i = 0; i < _listOfSO.length; i++) {
      if(!so.contentEquals(_listOfSO[i])) continue;
      return true;
    }
    return false;
  }
  String toString() {
    String s = "[";
    s += _listOfSO.join(", ");
    return s + "]\n";
  }
}

class SOMap extends DelegatingMap<String, SOList> implements Copyable<SOMap>, DefaultSOOperation {
  final Map<String, SOList> _mapOfSO;

  SOMap() : this._({});
  SOMap._(this._mapOfSO) : super(_mapOfSO);
  factory SOMap.fromIterable(Iterable<StageObject> iterable) {
    var soMap = SOMap();
    for(var so in iterable) soMap.add(so);
    return soMap;
  }

  SOMap copy() {
    SOMap copy = SOMap();
    for(MapEntry<String, SOList> entry in _mapOfSO.entries) {
      copy[entry.key] = entry.value.copy();
    }
    return copy;
  }
  SOMap deepCopy() {
    SOMap copy = SOMap();
    for(MapEntry<String, SOList> entry in _mapOfSO.entries) {
      copy[entry.key] = entry.value.deepCopy();
    }
    return copy;
  }
  void add(StageObject so) {
    String name = so.name;
    _mapOfSO.putIfAbsent(name, () => SOList()).add(so);
  }
  bool removeFirstIdentityEqual(StageObject so) {
    SOList? soList = _mapOfSO[so.name];
    if(soList == null) return false; // 해당 이름을 가진 SOList가 없는 경우

    return soList.removeFirstIdentityEqual(so);
    // 해당 이름을 가진 SOList는 있지만 안에 so가 존재하지 않을 경우 false 리턴
  }
  bool removeFirstContentEqual(StageObject so) {
    SOList? soList = _mapOfSO[so.name];
    if(soList == null) return false;

    return soList.removeFirstContentEqual(so);
  }
  bool removeAllIdentityEqual(StageObject so) {
    SOList? soList = _mapOfSO[so.name];
    if(soList == null) return false;

    return soList.removeAllIdentityEqual(so);
  }
  bool removeAllContentEqual(StageObject so) {
    SOList? soList = _mapOfSO[so.name];
    if(soList == null) return false;

    return soList.removeAllContentEqual(so);
  }
  bool containIdentityEqual(StageObject so) {
    SOList? soList = _mapOfSO[so.name];
    if(soList == null) return false;

    return soList.containIdentityEqual(so);

  }
  bool containContentEqual(StageObject so) {
    SOList? soList = _mapOfSO[so.name];
    if(soList == null) return false;

    return soList.containContentEqual(so);
  }
  String toString() {
    String s = "{\n";
    for(MapEntry<String, SOList> entry in _mapOfSO.entries) {
      s += "\t${entry.key} : ${entry.value}";
    }
    return s + "}\n";
  }

  // SO 단위의 연산
  /*
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
   */

  // SOMap만의 특수한 연산들
  Map<String, List<UI.Offset>> pickOffsetFromSOMap() {
    Map<String, List<UI.Offset>> offsetMap = {};

    for(MapEntry<String, SOList> entry in this.entries) {
      List<UI.Offset> offsetList = [];
      entry.value.forEach((so) {
        offsetList.add(so.offset);
      });
      offsetMap[entry.key] = offsetList;
    }

    return offsetMap;
  }

  Iterable<StageObject> iterableOnSO() {
    Iterable<StageObject> iterable = Iterable.empty();
    for(SOList list in this.values) {
      iterable = iterable.followedBy(list);
    }
    return iterable;
  }
}

// Map<dynamic, List<T>> 꼴의 Map을 List형식으로 바꾼다.
// SOMap을 List로 바꾼 값 내 원소와 SOMap에서 Offset만 뽑고 이뤄진
// Map을 List로 바꾼 값 내 원소가 서로 대응될 수 있도록 만들었다.
List<T> mapToList<T>(Map<dynamic, List<T>> map) {
  List<T> list = [];
  for(MapEntry<dynamic, List<T>> entry in map.entries) {
    list.addAll(entry.value);
  }
  return list;
}
// SOMap이나 SOMap에서 Offset만 뽑고 이뤼진 Map이나 절대좌표를 기준으로
// 좌표변환이 일어날 수 있도록 만들었다.
void translate<T>(Map<dynamic, List<T>> map, UI.Offset absoluteOffset) {
  for(MapEntry<dynamic, List<T>> entry in map.entries) {
    if(T == StageObject) {
      entry.value.forEach((so) {
        (so as StageObject).offset = so.offset + absoluteOffset;
      });
    } else /*T == UI.Offset*/ {
      for(int i = 0; i < entry.value.length; i++) {
        entry.value[i] = ((entry.value[i] as UI.Offset) + absoluteOffset) as T;
      }
    }
  }
}


class Instruction {
  static const double MARGIN = 10; // ADJUST
  late final double top;
  late final double left;
  late final double bottom;
  late final double right;
  final String id;
  SOMap head;
  SOMap body;
  late Map<String, AnimationType> correspondingATMap;

  Instruction(this.head, this.body, {required this.id}) {
    if(head.isEmpty) throw Exception("head에는 적어도 하나의 StageObject가 있어야 합니다.");

    List<StageObject> listOfHead = mapToList(head);
    var firstSOOffset = listOfHead.first.offset + UI.Offset.zero;

    translate(head, -firstSOOffset);
    translate(body, -firstSOOffset);
    _calcSizeWithMargin(listOfHead);
    correspondingATMap = _getAnimationType();
  }

  void _calcSizeWithMargin(Iterable<StageObject> headIterable) {
    double top = double.infinity, bottom = double.negativeInfinity;
    double left = double.infinity, right = double.negativeInfinity;

    for(StageObject so in headIterable) {
      top = min(top, so.offset.dy);
      bottom = max(bottom, so.offset.dy);
      left = min(left, so.offset.dx);
      right = max(right, so.offset.dx);
    }

    this.top = -top + MARGIN;
    this.left = -left + MARGIN;
    this.bottom = bottom + MARGIN;
    this.right = right + MARGIN;
  }
  Map<String, AnimationType> _getAnimationType() {
    Set<String> setOfNameOnHeadAndBody = <String> {};
    Map<String, AnimationType> result = {};

    setOfNameOnHeadAndBody.addAll(head.keys);
    setOfNameOnHeadAndBody.addAll(body.keys);

    late AnimationType type;
    for(String nameOfSO in setOfNameOnHeadAndBody) {
      int hLen = head[nameOfSO]?.length ?? 0,
          bLen = body[nameOfSO]?.length ?? 0;

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

  toString() {
    return "Instruction\n" +
          "#####head\n$head" +
          "#####body\n$body" + "\n";
  }
}

class StageObjectTween extends Tween<StageObject> {
  StageObjectTween(StageObject? begin, StageObject? end) : super(begin: begin, end: end);

  StageObject lerp(double t) {
    return StageObject.lerp(begin, end, t);
  }
}

class KeyFrame {
  SOMap begin;
  List<StageObject> middleOfUnChanged;
  List<StageObjectTween> middleOfChanged;
  SOMap end;
  //late SOMap unchanged;

  // TODO : 추가적인 속성(생성 시간, 어떤 명령어들로 생성되었는지 등)을 추가할 것
  KeyFrame(this.begin, this.middleOfUnChanged, this.middleOfChanged, this.end);

  Frame getFrameAt(AnimationDouble value) {
    SOMap soMap = SOMap();
    for(var so in middleOfUnChanged) {
      soMap.add(so);
    }
    for(var tween in middleOfChanged) {
      StageObject so = tween.lerp(value);
      soMap.add(so);
    }

    return Frame(soMap, value);
  }

}
// correspondingSOMap, finalSOMap 내 SO를 correspondingATMap을 기준으로 묶기
/*
  List<Tween<StageObject>> _bindSOOnHeadAndBody(InstructionSection section) {
    List<Tween<StageObject>> bindList = [];
    for(MapEntry<String, AnimationType> entry in section.instruction.correspondingATMap.entries) {

      switch(entry.value) {
        case AnimationType.DUPLICATE: {
          StageObject begin = section.correspondingSOMap[entry.key][0];
          for(StageObject end in section.finalSOMap[entry.key]) {
            bindList.add(Tween(
                begin: begin,
                end: end
            ));
          }
          break;
        }
        case AnimationType.MERGE: {
          StageObject end = section.finalSOMap[entry.key][0];
          for(StageObject begin in section.correspondingSOMap[entry.key]) {
            bindList.add(Tween(
                begin: begin,
                end: end
            ));
          }
          break;
        }
        case AnimationType.MANY: {
          bindList.addAll(_many(section, entry.key));
          break;
        }
        case AnimationType.CREATE: {
          for(StageObject end in section.finalSOMap[entry.key]) {
            bindList.add(Tween(
                begin: StageObject.none(),
                end: end
            ));
          }
          break;
        }
        case AnimationType.VANISH: {
          for(StageObject begin in section.correspondingSOMap[entry.key]) {
            bindList.add(Tween(
                begin: begin,
                end: StageObject.none()
            ));
          }
          break;
        }
        case AnimationType.ONE: {
          bindList.add(Tween(
              begin: section.correspondingSOMap[entry.key][0],
              end: section.finalSOMap[entry.key][0]
          ));
          break;
        }
        case AnimationType.UNDEFINED:
        default:
          break;
      }
    }

    return bindList;
  }

  List<Tween<StageObject>> _many(InstructionSection section, String name) {
    List<Tween<StageObject>> bindList = [];
    for(StageObject begin in section.correspondingSOMap[name]) {
      for(StageObject end in section.finalSOMap[name]) {
        bindList.add(Tween(
            begin: begin,
            end: end
        ));
      }
    }

    return bindList;
  }

   */

class Frame {
  SOMap soMap;
  AnimationDouble value;

  Frame(this.soMap, this.value);
}

// fillSuitableISOn의 재귀호출이 일어날 때 트리의 노드를
// 위아래로 이동하면서 바뀌지 않는 값을 가짐
class PartiallyPreparedInstructionSection {
  final Instruction instruction;
  final UI.Offset absoluteOffset;

  PartiallyPreparedInstructionSection({required this.instruction, required this.absoluteOffset});

  InstructionSection getInstructionSection({required SOMap before, required int specificity}) {
    SOMap after = instruction.body.deepCopy();
    translate(after, absoluteOffset);

    return InstructionSection(
      correspondingATMap: instruction.correspondingATMap,
      before: before,
      after: after,
      specificity: specificity,
      absoluteOffset: absoluteOffset
    );
  }
}

class InstructionSection {
  Map<String, AnimationType> correspondingATMap;
  SOMap before;
  SOMap after;
  int specificity = 0;
  UI.Offset absoluteOffset;

  InstructionSection({required this.correspondingATMap, required this.before, required this.after, required this.specificity, required this.absoluteOffset});
}
