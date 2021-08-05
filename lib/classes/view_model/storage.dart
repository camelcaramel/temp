import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as UI;
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:stage4viscuit/classes/component/exception.dart';
import '../component/component.dart';
import 'engine.dart';

enum StorageDest {
  ALL,
  INST,
  STFUL,
  STLESS,
}

class Storage {
  late final InstructionStorage inStorage;
  late final MemorableStatusStorage msStorage;
  late final EngineResultStorage erStorage;
  late final Engine engine;

  // DEBUG : 로컬에 있는 이미지 파일을 토대로 수행
  final ImageStorage imgStorage = ImageStorage();

  Storage([String? json]) {
    inStorage = InstructionStorage();
    msStorage = MemorableStatusStorage();
    erStorage = EngineResultStorage();
    engine = Engine(storage: this);

   if(json == null) return;

   Map<String, dynamic> jsonObj = jsonDecode(json);
   _initFromJson(jsonObj);
  }

  Future<void> initialize() async {
    await imgStorage.load();
    await engine.initialize();
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

class ImageStorage {
  Map<String, UI.Image> _uiImgMap;
  Map<String, Uint8List> _byteImgMap;

  ImageStorage() : _uiImgMap = {}, _byteImgMap = {};

  Iterable<String> get imgNames {
    return _uiImgMap.keys;
  }
  UI.Image uiImg(String name) {
    if(_uiImgMap[name] == null) throw NoSourceException();
    return _uiImgMap[name]!.clone();
  }
  Uint8List byteImg(String name) {
    if(_byteImgMap[name] == null) throw NoSourceException();
    return _byteImgMap[name]!;
  }
  UI.Size size(String name) {
    UI.Image img = uiImg(name);
    return UI.Size(img.width.toDouble(), img.height.toDouble());
  }


  Future<void> load() async {
    String jsonString = await rootBundle.loadString("asset/imageData.json");
    var jsonObj = jsonDecode(jsonString);

    for(MapEntry<String, dynamic> entry in jsonObj["images"].entries) {
      await _load(entry.key, entry.value);
    }
  }

  Future<void> _load(String name, String fileName) async {
    ByteData data = await rootBundle.load("asset/images/$fileName");

    Uint8List list = Uint8List.view(data.buffer);
    _byteImgMap[name] = list;

    Completer<void> completer = Completer();
    UI.decodeImageFromList(list, (UI.Image img) {
      _uiImgMap[name] = img;
      completer.complete();
    });

    return completer.future;
  }
}