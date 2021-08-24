import 'dart:async';
import 'dart:collection';
import 'dart:ui' as UI;
import 'package:collection/collection.dart';
import '../component/component.dart';

abstract class Storage {
  bool _lock = false;
  void lock();
  void unlock();
  StorageSnapshot snapshot();
  void add(dynamic value);
  void remove(dynamic target);
  void clear();
}
abstract class StorageSnapshot {}

class InstructionStorage implements Storage {
  List<Instruction> storage = [];
  bool _lock = false;

  void lock() => _lock = true;
  void unlock() => _lock = false;
  StorageSnapshot snapshot() {
    if(_lock == false) throw Exception("Snapshot을 얻기 전에 객체를 잠그세요.");
    return InstructionStorageSnapshot(instructionStorage: this);
  }
  void add(covariant Instruction instruction) {
    if(_lock == true) throw Exception("현재 읽기만 가능합니다.");
    storage.add(instruction);
  }
  void remove(covariant Instruction target) {
    if(_lock == true) throw Exception("현재 읽기만 가능합니다.");

    for(int i = 0; i < storage.length; i++) {
      if(storage[i].id != target.id) continue;
      storage.removeAt(i);
      break;
    }
  }
  void clear() {
    if(_lock == true) throw Exception("현재 읽기만 가능합니다.");

    storage.clear();
  }
  String toString() {
    String s = "######InstructionStorage######\n";
    for (var instruction in storage) {
      s += instruction.toString();
    }
    return s;
  }

}
class InstructionStorageSnapshot implements StorageSnapshot {
  InstructionStorage instructionStorage;
  // offsetMapPerInstruction은 각각의 명령어 내 head 내
  // SOList 내 StageObject의 Offset값만을 저장하고 있다.
  late Map<String, Map<String, List<UI.Offset>>> offsetMapPerInstruction = {};
  late Map<String, UI.Offset> absoluteOffsetMapPerInstruction = {};

  InstructionStorageSnapshot({required this.instructionStorage}) {
    for(Instruction instruction in instructionStorage.storage) {
      String instructionID = instruction.id;

      var offsetOfHead = instruction.head.pickOffsetFromSOMap();

      offsetMapPerInstruction[instructionID] = offsetOfHead;
      absoluteOffsetMapPerInstruction[instructionID] = UI.Offset.zero;
    }
  }

}

class StageStorage implements Storage {
  SOMap storage = SOMap();
  bool _lock =false;

  void lock() => _lock = true;
  void unlock() => _lock = false;
  StorageSnapshot snapshot() {
    if(_lock == false) throw Exception("Snapshot을 얻기 전에 객체를 잠그세요.");

    return StageStorageSnapshot(base: storage.deepCopy());
  }
  void add(covariant StageObject so) {
    if(_lock == true) throw Exception("현재 읽기만 가능합니다.");
    storage.add(so);
  }
  void remove(covariant StageObject so) {
    if(_lock == true) throw Exception("현재 읽기만 가능합니다.");
    storage.removeAllIdentityEqual(so);
  }
  void clear() {
    if(_lock == true) throw Exception("현재 읽기만 가능합니다.");
    storage.clear();
  }
}

abstract class StageStorageSnapshotObserver {
  void updateSSSnapshotSize(int size);
}

class StageStorageSnapshot extends DelegatingQueue<KeyFrame> implements StorageSnapshot {
  SOMap latestEndOfSOMap;
  Queue<KeyFrame> _queue;
  int maxSize;
  int minSize;
  int startSize;
  List<StageStorageSnapshotObserver> observers = [];
  Completer<void> _overStartSize = Completer();

  StageStorageSnapshot({required SOMap base, int maxSize = 30, int minSize = 1, int startSize = 3}) : this._(base, Queue(), maxSize, minSize, startSize);
  StageStorageSnapshot._(this.latestEndOfSOMap, this._queue, this.maxSize, this.minSize, this.startSize) : super(_queue);

  void register(StageStorageSnapshotObserver observer) {
    observers.add(observer);
    observer.updateSSSnapshotSize(_queue.length); // observer의 초기값 설정을 위해서
  }
  void updateSize(int size) {
    //print("queue's size: ${_queue.length}");
    for(var observer in observers) observer.updateSSSnapshotSize(size);
  }

  void push(KeyFrame keyFrame) {
    if(_queue.length >= maxSize) throw Exception("Queue에 더 이상 넣을 수 없습니다.");
    _queue.add(keyFrame);
    latestEndOfSOMap = keyFrame.end;
    updateSize(_queue.length);
    if(!_overStartSize.isCompleted && _queue.length == startSize) _overStartSize.complete();
  }
  KeyFrame poll() {
    if(_queue.length <= minSize) throw Exception("Queue에서 더 이상 빼낼 수 없습니다.");
    KeyFrame first = _queue.removeFirst();
    updateSize(_queue.length);
    return first;
  }

  Future<void> get whenFilledAsStartSize => _overStartSize.future;
}

/*
class InstructionStorage implements Storage {
  List<Instruction> storage;

  InstructionStorage() : storage = [];

  void add(Instruction instruction) {
    storage.add(instruction);
  }
  void remove(Instruction instruction) {
    storage.remove(instruction);
  }
  void clear() {
    storage.clear();
  }
  Iterable<Instruction> get() {
    return storage;
  }
}
 */
/*
class StageSnapshotStorage implements Storage {
  SOMap base;
  List<StageObject> delta;
  int currentStep = 0;

  List<SOMap> snapshot;

  StageSnapshotStorage() : base = SOMap(), delta = [], snapshot = [];

  void addOnBase(StageObject so) {
    base.addSO(so);
  }
  void addOnDelta(StageObject so) {
    delta.length = currentStep;
    delta.add(so);
    currentStep++;
  }
  bool next() {
    if(currentStep == delta.length) return false;
    currentStep++;
    return true;
  }
  bool previous() {
    if(currentStep == 0) return false;
    currentStep--;
    return true;
  }
  SOMap get() {
    SOMap soMap = base.copy();
    for(int i = 0; i < currentStep; i++) soMap.addSO(delta[i]);
    return soMap;
  }
  SOMap getLatest() {
    SOMap soMap = base.copy();
    for(int i = 0; i < delta.length; i++) soMap.addSO(delta[i]);
    return soMap;
  }
}
 */
/*
class EngineResultQueue extends DelegatingQueue<EngineResult> {
  final Queue<EngineResult> _queue;
  static const MAX_SIZE = 30;
  Completer<void> prefill = Completer();

  EngineResultQueue() : this._(Queue());
  EngineResultQueue._(this._queue) : super(_queue);

  void push(EngineResult result) {
    add(result);
    if(!prefill.isCompleted && length >= 3) prefill.complete();
  }
  EngineResult poll() {
    return removeLast();
  }
  EngineResult peek() {
    return _queue.last;
  }
  Future<void> ready() async {
    return prefill.future;
  }
  int get remainSpace {
    return MAX_SIZE - length;
  }
}
*/


