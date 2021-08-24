import 'dart:convert';
import 'dart:ui' as UI;
import '../component/component.dart';
import '../view_model/storage.dart';

class Need {
  InstructionStorage instructionStorage = InstructionStorage();
  StageStorage stageStorage = StageStorage();

  Need();

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

          instructionStorage.add(Instruction(head, body, id: 'fake'));
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

  SOMap get current {
    stageStorage.lock();
    return (stageStorage.snapshot() as StageStorageSnapshot).latestEndOfSOMap;
  }
  InstructionStorageSnapshot get snapshot {
    instructionStorage.lock();
    return instructionStorage.snapshot() as InstructionStorageSnapshot;
  }

  List<InstructionSection> generate(SOMap current,
      InstructionStorageSnapshot snapshot) {
    List<InstructionSection> listOfIS = [];

    List<Instruction> instructions = snapshot.instructionStorage.storage;

    for (var instruction in instructions) {

      String instructionID = instruction.id;
      List<StageObject> listOfHead = mapToList(instruction.head);
      int indexOfHead = 0;
      StageObject firstSOOnHead = listOfHead[indexOfHead];

      // 명령어 첫 번째 SO에 만족하는 Stage 내 SO가 없을 경우 처리
      if(current[firstSOOnHead.name] == null) return [];

      for (var absoluteSO in current[firstSOOnHead.name]!) {
        UI.Offset absoluteOffset = absoluteSO.offset;

        translate(snapshot.offsetMapPerInstruction[instructionID]!,
            -snapshot.absoluteOffsetMapPerInstruction[instructionID]! +
                absoluteOffset);
        snapshot.absoluteOffsetMapPerInstruction[instructionID] = absoluteOffset;

        List<UI.Offset> listOfHeadOffset = mapToList(
            snapshot.offsetMapPerInstruction[instructionID]!);
        UI.Rect possibleArea = getPossibleArea(absoluteOffset, instruction);
        PartiallyPreparedInstructionSection pi = PartiallyPreparedInstructionSection(
            instruction: instruction, absoluteOffset: absoluteOffset);
        Set<StageObject> set = Set();

        fillSuitableISOn(
            listOfIS: listOfIS,
            listOfHead: listOfHead,
            listOfHeadOffset: listOfHeadOffset,
            indexOfHead: indexOfHead,
            current: current,
            possibleArea: possibleArea,
            set: set,
            totalSpecificity: 0,
            pi: pi
        );
      }
    }

    return listOfIS;
  }
  void fillSuitableISOn({
    required List<InstructionSection> listOfIS,
    required List<StageObject> listOfHead,
    required List<UI.Offset> listOfHeadOffset,
    required int indexOfHead,
    required SOMap current,
    required UI.Rect possibleArea,
    required Set<StageObject> set,
    required int totalSpecificity,
    required PartiallyPreparedInstructionSection pi
  }) {
    if (indexOfHead == listOfHead.length) {
      SOMap before = SOMap.fromIterable(set);
      listOfIS.add(pi.getInstructionSection(
          before: before,
          specificity: totalSpecificity
      ));
      return;
    }

    var soOnHead = listOfHead[indexOfHead];
    UI.Offset soOnHeadOffset = listOfHeadOffset[indexOfHead];
    for (var soOnCurrent in current[soOnHead.name]!) {
      if (set.contains(soOnCurrent)) continue;

      int specificity;
      if (!possibleArea.contains(soOnCurrent.offset) ||
          (specificity = calcSpecificity(soOnHeadOffset, soOnCurrent.offset)) == 0
      ) continue;

      set.add(soOnCurrent);
      fillSuitableISOn(
          listOfIS: listOfIS,
          listOfHead: listOfHead,
          listOfHeadOffset: listOfHeadOffset,
          indexOfHead: indexOfHead + 1,
          current: current,
          possibleArea: possibleArea,
          set: set,
          totalSpecificity: totalSpecificity + specificity,
          pi: pi
      );
      set.remove(soOnCurrent);
    }
  }
  int calcSpecificity(UI.Offset soOnHead, UI.Offset soOnCurrent) {
    double distanceSquared = (soOnHead - soOnCurrent).distanceSquared;

    // ADJUST - possibleSection의 MARGIN값을 고려하여 값 설정
    const limit = 100;
    int func(double x) => x <= limit ? (-x + 100).floor() : 0;

    return func(distanceSquared);
  }
  UI.Rect getPossibleArea(UI.Offset absoluteOffset, Instruction instruction) {
    return UI.Rect.fromLTRB(
        absoluteOffset.dx - instruction.left,
        absoluteOffset.dy - instruction.top,
        absoluteOffset.dx + instruction.right,
        absoluteOffset.dy + instruction.bottom
    );
  }


}


