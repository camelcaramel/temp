import 'dart:ui';
import 'package:collection/collection.dart';

/*
enum SOKey {
  TYPE,
  NAME,
  OFFSET,
  ROTATION,
}
*/

class StageObject {
  String type;
  String name;
  Offset offset;
  double rotation;
  // Size size;
  dynamic _forTween;
  static final Function _forTweenIfBeginNull = (double x) => x;
  static final Function _forTweenIfEndNull = (double x) => 1 - x;

  StageObject(this.name, this.offset, this.rotation, [this.type = "empty", this._forTween]);
  StageObject.named({required String name, required Offset offset, required double rotation, String type = "empty", dynamic forTween}) : this(name, offset, rotation, type, forTween);
  StageObject.copy(StageObject origin)
      : type = origin.type,
        name = origin.name,
        offset = origin.offset,
        rotation = origin.rotation;
  StageObject.empty()
      : type = "empty",
        name = "empty",
        offset = Offset.infinite,
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

abstract class SOUnitCopyable<T> {
  // 호출의 주체에 대해 SO 단위까지 깊은 복사를 수행한다.
  T copy();
}

// 최대한 SOMap 내부적으로만 사용
class SOList extends DelegatingList<StageObject> implements SOUnitCopyable<SOList> {
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

  /*
  SOList(this.listOfSO);
  SOList.empty() : listOfSO = [];
  SOList.copy(SOList origin)
    : listOfSO = List.from(origin.listOfSO);

   */
  /*
  void add(StageObject so) {
    listOfSO.add(so);
  }
  void addAllFromIterable(Iterable<StageObject> iterable) {
    listOfSO.addAll(iterable);
  }
  void addAllFromSOList(SOList soList) {
    listOfSO.addAll(soList.listOfSO);
  }
  void remove(StageObject so) {
    listOfSO.remove(so);
  }
  bool contains(StageObject so) {
    return listOfSO.contains(so);
  }

  List<StageObject> toList() {
    return listOfSO;
  }
  void translateZero(Offset offset) {
    for(int i = 0; i < listOfSO.length; i++) {
      listOfSO[i].offset = listOfSO[i].offset + offset;
    }
  }
  StageObject operator[] (idx) {
    return idx >= listOfSO.length ? StageObject.empty() : listOfSO[idx];
  }
  static List<double> calcDistanceOfUDLR(SOListable impl, Offset origin) {
    double up = double.infinity, down = double.negativeInfinity;
    double left = double.infinity, right = double.negativeInfinity;
    for(StageObject so in impl.toList()) {
      up = min(up, so.offset.dy);
      down = max(down, so.offset.dy);
      left = min(left, so.offset.dx);
      right = max(right, so.offset.dx);
    }

    up -= origin.dy;
    down -= origin.dy;
    left -= origin.dx;
    right -= origin.dx;

    return <double> [up, down, left, right];
  }

  StageObject get first => listOfSO[0];
  int get length => listOfSO.length;

   */
}

class SOMap extends DelegatingMap<String, SOList> implements SOUnitCopyable<SOMap> {
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
  void translate(Offset offset) {
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
