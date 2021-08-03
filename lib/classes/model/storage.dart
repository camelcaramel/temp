import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:ui' as UI;
import 'package:collection/collection.dart';
import '../presenter/presenter.dart';
import '../component/component.dart';

enum StorageDest {
  ALL,
  INST,
  STFUL,
  STLESS,
}

class Storage {
  final Presenter presenter;
  final InstructionStorage inStorage = InstructionStorage();
  final MemorableStatusStorage msStorage = MemorableStatusStorage();
  final EngineResultStorage erStorage = EngineResultStorage();

  Storage({required this.presenter, String? json}) {
   if(json == null) return;

   Map<String, dynamic> jsonObj = jsonDecode(json);
   _initFromJson(jsonObj);
  }

  void _initFromJson(jsonObj) {
    // init instructionStorage
    for(var rule in jsonObj["rules"]) {
      if(rule["type"] == "rule") {
        SOMap head = _createSOMapFromJsonObj(rule["head"]);
        SOMap body = _createSOMapFromJsonObj(rule["body"]);

        inStorage.add(Instruction(head, body));
      } else {
        // 명령어 view에 안경에 올리지 않은 이미지의 경우
      }
    }

    // init memorableStatusStorage
    for(var so in jsonObj["stage"]) {
      msStorage.addOnBase(so);
    }

    // init engineResultStorage
    erStorage.nextBegin = msStorage.base;
  }

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

  /*
  // read
  String getState(StorageDest dest) {
    String state = "";
    switch(dest) {
      case StorageDest.ALL:
        state += instructionSource.state();
        state += stfulStageStatus.state();
        state += stlessStageStatus.state();
        break;
      case StorageDest.INST:
        state = instructionSource.state();
        break;
      case StorageDest.STFUL:
        state = stfulStageStatus.state();
        break;
      case StorageDest.STLESS:
        state = stlessStageStatus.state();
        break;
    }
    return state;
  }

  // update
  void update(StorageDest dest, value) {
    switch(dest) {
      default:
        throw UnsupportedException();
    }
  }

  // delete
  void delete(StorageDest dest, value) {
    switch(dest) {
      case StorageDest.INST:
        instructionSource.delete(value);
        break;
      case StorageDest.STFUL:
        stfulStageStatus.delete(value);
        break;
      case StorageDest.STLESS:
        stlessStageStatus.delete(value);
        break;
      default:
        throw UnsupportedException();
    }
  }
  void clear(StorageDest dest) {
    switch(dest) {
      case StorageDest.ALL:
        instructionSource.clear();
        stfulStageStatus.clear();
        stlessStageStatus.clear();
        break;
      case StorageDest.INST:
        instructionSource.clear();
        break;
      case StorageDest.STFUL:
        stfulStageStatus.clear();
        break;
      case StorageDest.STLESS:
        stlessStageStatus.clear();
        break;
    }
  }

   */
}

class InstructionStorage {
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

// DEBUG
/*
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
   */
}

class MemorableStatusStorage {
  SOMap base;
  List<StageObject> delta;
  int currentStep = 0;

  List<SOMap> snapshot;

  MemorableStatusStorage() : base = SOMap(), delta = [], snapshot = [];

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

class EngineResultStorage extends DelegatingQueue<EngineResult> {
  final Queue<EngineResult> storage;
  static const MAX_SIZE = 30;
  SOMap nextBegin;
  Completer<void> prefill = Completer();

  EngineResultStorage() : this._(Queue(), SOMap());
  EngineResultStorage._(this.storage, this.nextBegin) : super(storage);

  void push(EngineResult result) {
    add(result);
    nextBegin = result.end;
    if(!prefill.isCompleted && length >= 3) prefill.complete();
  }
  EngineResult poll() {
    return removeLast();
  }
  Future<void> ready() async {
    return prefill.future;
  }
  int get remainSpace {
    return MAX_SIZE - length;
  }
}