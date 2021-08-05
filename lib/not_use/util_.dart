import 'dart:collection';

class Pair<T1, T2> {
  final T1 first;
  final T2 second;

  Pair(this.first, this.second);

  int get hashCode {
    return (T1.hashCode + T2.hashCode) * 31;
  }

  bool operator ==(Object other) {
    if(other is! Pair<T1, T2>) return false;

    return this.first == other.first &&
           this.second == other.second;

  }
}

abstract class Checkable<K> {
  void check(int idx, [K? key]);
  void unCheck(int idx, [K? key]);
  void toggle(int idx, [K? key]);
  bool isChecked(int idx, [K? key]);
  void clearAll();
}

// maxSize per key = 58
class CheckingMap<K> extends Checkable<K> {
  final HashMap<K, int> map = HashMap();

  CheckingMap(List<K> keys, List<int> sizes) {
    for(int i = 0; i < keys.length; i++) {
      if((map[keys[i]] = sizes[i]) > 58) throw Exception("CheckingMap's one entry size is over 58");
    }
  }

  int size(K key) {
    return map.containsKey(key) ? map[key]!.toUnsigned(6) : -1;
  }
  void check(int idx, [K? key]) {
    if(key == null) throw Exception("key is null");
    if(idx >= size(key)) throw Exception("index out of range");

    int v = map[key]!;
    map[key] = v | (1 << (idx + 6));
  }
  bool isChecked(int idx, [K? key]) {
    if(key == null) throw Exception("key is null");
    if(idx >= size(key)) throw Exception("index out of range");

    int v = map[key]!;
    return v & (1 << (idx + 6)) == 0 ? false : true;
  }
  void toggle(int idx, [K? key]) {
    if(key == null) throw Exception("key is null");
    if(idx >= size(key)) throw Exception("index out of range");

    int v = map[key]!;
    map[key] = v ^ (1 << (idx + 6));
  }
  void unCheck(int idx, [K? key]) {
    if(key == null) throw Exception("key is null");
    if(idx >= size(key)) throw Exception("index out of range");

    int v = map[key]!;
    map[key] = v & ~(1 << (idx + 6));
  }
  void clearAll() {
    for(K key in map.keys) {
      map[key] = size(key);
    }
  }
}

// Char 크기(65536)의 2개의 값을 한 쌍으로 가짐
class CharPair {
  int _ = 0;
  CharPair();

  int operator[] (int i) {
    if(i == 0) return _.toUnsigned(16);
    else return (_ >> 16).toUnsigned(16);
  }
  void operator[]= (int i, int value) {
    if(i == 0) _ = ((_ >> 16) << 16) + value.toUnsigned(16);
    else _ = _.toUnsigned(16) + (value.toUnsigned(16) << 16);
  }
}