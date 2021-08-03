import 'dart:async';
import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../component/component.dart';
import '../presenter/presenter.dart';
import '../model/storage.dart';

class Engine {
  final Presenter presenter;
  final Storage storage;
  late bool canRun;
  late Completer engineStop;

  Engine({required this.presenter, required this.storage});

  void start() {
    var stream = run();
    canRun = true;
    engineStop = Completer();
    stream.listen(
        (e) {
          storage.erStorage.push(e);
        },
        onDone: () {
          engineStop.complete();
        }
    );
  }
  Future<void> stop() async { // start()를 사용할 수 있을 때 future가 끝남
    canRun = false;
    return engineStop.future;
  }

  Stream<EngineResult> run() async* {
    while(canRun) {
      // checking conditions...
      if(storage.erStorage.remainSpace <= 0) continue;

      SOMap begin = storage.erStorage.nextBegin;

      List<InstructionSection> listOfIS;
      listOfIS = findIS(begin);
      listOfIS = selectIS(listOfIS);
      deriveFinalSOMapOn(listOfIS);

      SOMap end = begin.copy();
      SOMap unchanged = begin.copy();
      for(var instructionSection in listOfIS) {
        for(StageObject so in instructionSection.correspondingSOMap.iteratorOnSO()) {
          end.removeSO(so);
          unchanged.removeSO(so);
        }
        for(StageObject so in instructionSection.finalSOMap.iteratorOnSO()) {
          end.addSO(so);
        }
      }

      yield EngineResult(listOfIS, begin, end, unchanged);
    }
  }

  /*
  List<InstructionSection> ready(SOMap soMap) { // Animation's Status == dismissed

    List<InstructionSection> listOfIS;
    listOfIS = findInstructionSections(soMap);
    //listOfIS = sameSpecificityRandomizer(listOfIS);
    listOfIS = selectInstructionSections(listOfIS);
    readyForInstructionSection(listOfIS);

    _listOfIS = listOfIS;

    return listOfIS;
  }

  SOMap run(double d) { // Animation's Status == forward
    SOMap soMap = SOMap();
    for(var instructionSection in _listOfIS) {
      soMap.addAll(instructionSection.getMiddleSOMap(d));
    }

    return soMap; // for stage's mapOfSOFromEngine
  }

  SOMap end() { // Animation's status == complete
    SOMap soMap = SOMap();
    for(var instructionSection in _listOfIS) {
      soMap.addAll(instructionSection.finalSOMap);
    }
    return soMap;
  }

   */

  List<InstructionSection> findIS(SOMap soMap) {
    List<InstructionSection> result = [];

    for(Instruction instruction in storage.inStorage.get()) {

      for(int i = 0; i < soMap[instruction.relativeCriterionSO.name].length; i++) {
        StageObject so = soMap[instruction.relativeCriterionSO.name][i];

        instruction.setAbsoluteOffsetToCriterion = so.offset;

        InstructionSection section = InstructionSection(instruction);
        section.addSO(so);

        _dfs(
          section: section,
          listOfHead: List.from(instruction.head.iteratorOnSO(), growable: false),
          mapOfSOOnStage: soMap,
          depth: 1,
          result: result
        );
      }
    }

    return result;
  }

  // 일반적으로 하나의 깊이만을 들어감 -> average cost = O(d); d = 명령어의 크기
  void _dfs({required InstructionSection section,
            required listOfHead,
            required SOMap mapOfSOOnStage,
            required int depth,
            required List<InstructionSection> result})
  {
    if(listOfHead.length == depth) {
      InstructionSection foundSection = InstructionSection.copy(section);
      foundSection.absoluteOffset = section.instruction!.absoluteOffset;
      result.add(foundSection);
    }

    late StageObject so;
    StageObject instructionSO = listOfHead[depth]!;
    int len = mapOfSOOnStage[instructionSO.name].length;
    for(int i = 0; i < len; i++) {
      so = mapOfSOOnStage[instructionSO.name][i];

      int specificity = calcSpecificity(instructionSO.offset, so.offset);
      if(!section.instruction!.possibleSection.contains(so.offset) ||
          section.isSelectedSO(so) ||
          specificity == 0
      ) continue;

        section.addSO(so);
        section.specificity += specificity;

        _dfs(
            section: section,
            listOfHead: listOfHead,
            mapOfSOOnStage: mapOfSOOnStage,
            depth: depth + 1,
            result: result
        );

        section.specificity -= specificity;
        section.removeSO(so);
    }
  }

  int calcSpecificity(Offset offsetOfInstructionSO, Offset offsetOfStageSO) {
    double distanceSquared = (offsetOfInstructionSO - offsetOfStageSO).distanceSquared;

    // ADJUST - possibleSection의 MARGIN값을 고려하여 값 설정
    const limit = 100;
    int func(double x) => x <= limit ? (-x + 100).floor() : 0;

    return func(distanceSquared);
  }

  List<InstructionSection> selectIS(List<InstructionSection> listOfIS) {
    List<InstructionSection> result = [];

    // 정렬이 unstable 이라서 무작위 뽑기를 안해도 괜찮을 것 같다.
    listOfIS.sort((a, b) => b.specificity - a.specificity);

    HashSet<StageObject> setForDuplicatedSO = HashSet();
    HashSet<StageObject> setForTemp = HashSet();
    
c:  for(var instructionSection in listOfIS) {
      for(StageObject so in instructionSection.correspondingSOMap.iteratorOnSO()) {

        if(setForDuplicatedSO.contains(StageObject)) {
          setForTemp.clear();
          continue c;
        }

        setForTemp.add(so);
      }
      result.add(instructionSection);

      setForDuplicatedSO.addAll(setForTemp);
      setForTemp.clear();
    }

    return result;
  }

  /*
  List<InstructionSection> sameSpecificityRandomizer(List<InstructionSection> listOfIS) {
    List<InstructionSection> result = [];
    late List<int> numbers;

    listOfIS.add(InstructionSection(null));

    for(int i = 0, currentSpecificity = listOfIS[0].specificity, leftIdx = 0; i < listOfIS.length; i++) {
      int specificity = listOfIS[i].specificity;
      if(currentSpecificity == specificity) continue;

      int range = i - leftIdx;
      numbers = List.generate(range, (index) => index, growable: false)..shuffle();
      for(int j = 0; j < range; j++) {
        int newIdx = leftIdx + numbers[j];
        result.add(listOfIS[newIdx]);
      }

      currentSpecificity = specificity;
    }

    return result;
  }
   */
  void deriveFinalSOMapOn(List<InstructionSection> listOfIS) {
    for(var instructionSection in listOfIS) {
      instructionSection.makeFinalSOMap();
    }
  }
}
/*
class InstructionSection1 {
  Instruction? instruction;
  Map<String, List<int>> mapOfCorrespondSO = {};
  int specificity;
  String? _latestSOName;
  int? _latestSOIdx;

  InstructionSection(this.instruction) : specificity = 0;
  InstructionSection.copy(InstructionSection origin) // deep copy
      : instruction = origin.instruction,
        specificity = origin.specificity 
  {
    for(MapEntry<String, List<int>> entry in origin.mapOfCorrespondSO.entries) {
      for(int idx in entry.value) {
        mapOfCorrespondSO.putIfAbsent(entry.key, () => []).add(idx);
      }
    }
  }
  InstructionSection.empty() : specificity = -1;


  void addSO(String name, int idx) {
    mapOfCorrespondSO.putIfAbsent(name, () => []).add(idx);
    
    _latestSOName = name;
    _latestSOIdx = idx;
  }
  void removeLatestSO() {
    if(_latestSOIdx == null) return;
    mapOfCorrespondSO[_latestSOName]!.removeWhere((currentIdx) => currentIdx == _latestSOIdx);
    _latestSOIdx = _latestSOName = null;
  }
  bool isSelectedSO(String name, int idx) {
    return mapOfCorrespondSO[name]!.any((currentIdx) => currentIdx == idx);
  }
}
 */