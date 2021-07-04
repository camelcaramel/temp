import 'dart:collection';

import 'package:flutter/cupertino.dart';

import 'instruction.dart';
import 'component.dart';
import 'animation.dart';
import 'dart:ui';

class Engine {

  late List<InstructionSection> _listOfIS;

  Engine() {
    InstructionSource.instance = InstructionSource();
  }

  // signal 형태로 호출
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

  List<InstructionSection> findInstructionSections(SOMap soMap) {
    List<InstructionSection> result = [];

    for(Instruction instruction in InstructionSource.instance.instructions) {

      for(int i = 0; i < soMap[instruction.relativeCriterionSO.name].length; i++) {
        StageObject so = soMap[instruction.relativeCriterionSO.name][i];

        instruction.setAbsoluteOffsetToCriterion = so.offset;

        InstructionSection section = InstructionSection(instruction);
        section.addSO(so);

        _DFS(
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
  void _DFS({required InstructionSection section,
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

        _DFS(
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

  List<InstructionSection> selectInstructionSections(List<InstructionSection> listOfIS) {
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

  void readyForInstructionSection(List<InstructionSection> listOfIS) {
    for(var instructionSection in listOfIS) {
      instructionSection.ready();
    }
  }
}

class InstructionSection {
  Instruction? instruction;
  SOMap correspondingSOMap;
  int specificity = 0;
  late Offset absoluteOffset;

  late SOMap finalSOMap;
  late List<Tween<StageObject>> _bindListOfSO;

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
    if(correspondingSOMap.containsKey(so)) return false;
    return correspondingSOMap[so].contains(so);
  }

  void ready() {
    makeFinalSOMap();
    bindSOOnHeadAndBody();
  }
  // finalSOMap을 InstructionSection마다 저장
  // 매 순간 계산하는 방법을 생각해보았으나 시간에서 너무 오버헤드가 일어날 것 같음
  void makeFinalSOMap() {
    instruction!.setAbsoluteOffsetToCriterion = absoluteOffset;
    finalSOMap = instruction!.body;
  }

  // correspondingSOMap, finalSOMap 내 SO를 correspondingATMap을 기준으로 묶기
  void bindSOOnHeadAndBody() {

    for(MapEntry<String, AnimationType> entry in instruction!.correspondingATMap.entries) {
      switch(entry.value) {
        case AnimationType.DUPLICATE: {
          StageObject begin = correspondingSOMap[entry.key][0];
          for(StageObject end in finalSOMap[entry.key]) {
            _bindListOfSO.add(Tween(
              begin: begin,
              end: end
            ));
          }
          break;
        }
        case AnimationType.MERGE: {
          StageObject end = finalSOMap[entry.key][0];
          for(StageObject begin in correspondingSOMap[entry.key]) {
            _bindListOfSO.add(Tween(
              begin: begin,
              end: end
            ));
          }
          break;
        }
        case AnimationType.MANY: {
          _many(entry.key);
          break;
        }
        case AnimationType.CREATE: {
          for(StageObject end in finalSOMap[entry.key]) {
            _bindListOfSO.add(Tween(
              begin: StageObject.empty(),
              end: end
            ));
          }
          break;
        }
        case AnimationType.VANISH: {
          for(StageObject begin in correspondingSOMap[entry.key]) {
            _bindListOfSO.add(Tween(
              begin: begin,
              end: StageObject.empty()
            ));
          }
          break;
        }
        case AnimationType.ONE: {
          _bindListOfSO.add(Tween(
            begin: correspondingSOMap[entry.key][0],
            end: finalSOMap[entry.key][0]
          ));
          break;
        }
        case AnimationType.UNDEFINED:
        default:
          break;
      }
    }
  }

  void _many(String name) {
    for(StageObject begin in correspondingSOMap[name]) {
      for(StageObject end in finalSOMap[name]) {
        _bindListOfSO.add(Tween(
          begin: begin,
          end: end
        ));
      }
    }
  }

  // correspondingSOMap, finalSOMap 을 토대로 중간 SO를 구하는 명령어
  SOMap getMiddleSOMap(double d) {
    SOMap middleSOMap = SOMap();
    for(Tween<StageObject> tween in _bindListOfSO) {
      middleSOMap.addSO(tween.transform(d));
    }
    return middleSOMap;
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