import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as UI;
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';
import '../presenter/stage_presenter.dart';
import '../view/stageOne.dart';
import '../view/stageTwo.dart';
import 'view_model_interface.dart';
import 'engine.dart';
import 'storage.dart';
import '../component/component.dart';
import '../component/exception.dart';

class StageSectionViewModel implements ViewModel {
  late Widget stageOne;
  late Widget stageTwo;

  late List<Widget> stages;

  StageSectionViewModel() {
    stageOne = blank();
    stageTwo = blank();

    stages = [stageOne];
  }


  Widget blank() {
    return Container(
      margin: EdgeInsets.all(10),
      width: 600,
      height: 450,
      color: Colors.blueAccent,
    );
  }

  void replaceBlankToStage(StagePresenter stagePresenter) {
    stageOne = StageOne(
        stagePresenter: stagePresenter
    );
    stageTwo = StageTwo(
        stagePresenter: stagePresenter
    );
    stages = [stageOne];
  }
}

class ConsoleSectionViewModel implements ViewModel {
  static const double commandFontSize = 13;
  static const double commandHeight = 20;

  final List<ConsoleText> consoleTexts;


  ConsoleSectionViewModel() : consoleTexts = [];

  void write(String text) {
    consoleTexts.add(_getConsoleText(text));
  }

  ConsoleText _getConsoleText(String text, [Color color = Colors.white]) {
    return ConsoleText(text, color);
  }
}

class ConsoleText extends StatelessWidget {
  final String text;
  final Color color;

  ConsoleText(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: Row(
        // ADJUST - a little bit hacky way https://stackoverflow.com/questions/54173241/how-to-vertically-align-text-inside-container
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 590,
            //color: Colors.blue,
            child: Text(
              text,
              style: TextStyle(
                fontSize: ConsoleSectionViewModel.commandFontSize,
                color: color,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomColor {
  static const disabled = Colors.grey;
  static const green = Colors.lightGreen;
  static const red = Colors.red;
}

class ButtonSectionViewModel implements ViewModel {
  Color playButtonColor = CustomColor.disabled;
  Color pauseButtonColor = CustomColor.disabled;
  Color stopButtonColor = CustomColor.disabled;
}

enum ExtendedAnimationStatus { // animationController가 전체 과정 중 현재 해야할 것을 나타냄
  START, // 할것: 시작
  FORWARD, // 할것: 계속진행
  PAUSE, // 할것: 잠시멈춤
  RESUME, // 할것: 재개
  STOP, // 할것: 끝내기
  USER, // 할것: 통제권이 user에게 있으므로 아무것도 못함
  BEFORE // 할것: 아직 애니메이션 전이므로 아무것도 할게 없음
}

abstract class ImageAccessible {
  UI.Image uiImg(String name);
  Uint8List byteImg(String name);
  UI.Size size(String name);
}

abstract class StageViewModel implements ViewModel, ImageAccessible, PainterDecoratorObtainable {
  // Canvas(Stage) 위에 그려질 객체의 생성 및 연산과 관련하여 다뤄지는 sub-viewModel
  final InstructionStorage instructionStorage;
  final StageStorage stageStorage;

  StageViewModel() :
        instructionStorage = InstructionStorage(),
        stageStorage = StageStorage();

  void fillFromJson(String json) {
    dynamic jsonObj;
    try {
      jsonObj = jsonDecode(json);
    } on FormatException {
      print("Json을 디코딩하는데 에러 발생");
      rethrow;
    }

    try {
      for (var ruleJsonObj in jsonObj["rules"]) {
        if (ruleJsonObj["type"] == "rule") {
          SOMap head = createSOMapFromJsonObj(ruleJsonObj["head"]);
          SOMap body = createSOMapFromJsonObj(ruleJsonObj["body"]);

          instructionStorage.add(Instruction(head, body, id: "null"));
        } else {
          // 명령어 view에 안경에 올리지 않은 이미지의 경우
        }
      }
    } on TypeError {
      print("명령어를 만드는데 에러 발생");
      rethrow;
    }

    try {
      for (var soJsonObj in jsonObj["stage"]) {
        StageObject so = createSOFromJsonObj(soJsonObj);
        stageStorage.add(so);
      }
    } on TypeError {
      print("stage 내 SO를 만드는데 에러 발생");
      rethrow;
    }
  }
  StageObject createSOFromJsonObj(var jsonObj) {
    String type = jsonObj["type"];
    String name = jsonObj["name"];
    UI.Offset offset = UI.Offset(jsonObj["x"], jsonObj["y"]);
    double rotation = jsonObj["rotation"].toDouble();

    return StageObject.named(name: name, offset: offset, rotation: rotation, type: type);
  }
  SOMap createSOMapFromJsonObj(var jsonArrObj) {
    SOMap soMap = SOMap();

    for (var jsonObj in jsonArrObj) {
      StageObject so = createSOFromJsonObj(jsonObj);
      soMap.add(so);
    }

    return soMap;
  }

  StageViewModelOnRunning get stageViewModelOnRunning {
    var iSSnapshot = (instructionStorage..lock()).snapshot() as InstructionStorageSnapshot;
    var sSSnapshot = (stageStorage..lock()).snapshot() as StageStorageSnapshot;

    return StageViewModelOnRunning(instructionStorageSnapshot: iSSnapshot,
        stageStorageSnapshot: sSSnapshot, imageAccessor: this);
  }

  // 무엇을 그릴지 알려줌 -> view를 최대한 멍청하게 만듦
  // 예를 들어 List<Image>에 대응되는 List<bool>에 따라
  // 그릴지 말지를 view에서 결정할 수도 있지만,
  // List<bool>에 따른 새로운 List<Image>를 view-model에서 만들어
  // view에게 넘겨 줄 수 있음
  PainterDecorator get painterDecorator {
    return SOMapPainter(soMap: stageStorage.storage, imageAccessor: this);
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

class StageViewModelOnRunning implements ViewModel, PainterDecoratorObtainable {
  late Engine engine;
  StageStorageSnapshot sSSnapshot;

  // StageOne의 Animation상태와 관련하여 다뤼짐
  ExtendedAnimationStatus animationStatus = ExtendedAnimationStatus.STOP;

  // Canvas(Stage) 위에 실제로 그릴 객체와 관련하여 다뤄짐
  AnimationDouble animationDouble = 1;
  late KeyFrame keyFrame;
  late Frame frame; // <- keyFrame과 animationDouble의 조합으로 나온 결과

  ImageAccessible imageAccessor;

  StageViewModelOnRunning({required InstructionStorageSnapshot instructionStorageSnapshot, required StageStorageSnapshot stageStorageSnapshot, required this.imageAccessor})
      : sSSnapshot = stageStorageSnapshot
  {
    engine = EngineV2(instructionStorageSnapshot: instructionStorageSnapshot, stageStorageSnapshot: sSSnapshot);
  }

  PainterDecorator get painterDecorator {
    return SOMapPainter(soMap: frame.soMap, imageAccessor: imageAccessor);
  }
}

class StageViewModelWithLocalImage extends StageViewModel {
  Map<String, UI.Image> _uiImgMap;
  Map<String, Uint8List> _byteImgMap;
  Map<String, String> _nameMapping;
  late List<String> availName;
  int _availNameIndex = 0;

  StageViewModelWithLocalImage._() : _uiImgMap = {}, _byteImgMap = {}, _nameMapping = {};

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

  static Future<StageViewModelWithLocalImage> create() async {
    var stageViewModel = StageViewModelWithLocalImage._();
    await stageViewModel._load();
    stageViewModel.availName = stageViewModel._uiImgMap.keys.toList(growable: false);
    return stageViewModel;
  }

  Future<void> _load([String? json]) async {
    json = await rootBundle.loadString("asset/imageData.json");
    var jsonObj = jsonDecode(json);

    for (MapEntry<String, dynamic> entry in jsonObj["images"].entries) {
      await _loadImg(entry.key, entry.value);
    }
  }
  Future<void> _loadImg(String name, String fileName) async {
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

  StageObject createSOFromJsonObj(var jsonObj) {
    String type = jsonObj["type"];
    String name = _nameMapping.putIfAbsent(jsonObj["name"] as String, () {
      if(_availNameIndex >= availName.length) throw NoElementException();
      return availName[_availNameIndex++];
    });
    UI.Offset offset = UI.Offset(jsonObj["x"], jsonObj["y"]);
    double rotation = jsonObj["rotation"].toDouble();

    return StageObject.named(name: name, offset: offset, rotation: rotation, type: type);
  }
  SOMap createSOMapFromJsonObj(var jsonArrObj) {
    return super.createSOMapFromJsonObj(jsonArrObj);
  }
}