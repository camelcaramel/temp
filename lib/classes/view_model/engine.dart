import 'dart:async';
import 'dart:collection';
import 'dart:ui' as UI;
import 'package:flutter/foundation.dart';
import 'package:stage4viscuit/classes/view_model/storage.dart';
import '../component/component.dart';
import '../component/animation.dart';


abstract class Engine {
  InstructionStorageSnapshot _instructionStorageSnapshot;
  StageStorageSnapshot _stageStorageSnapshot;
  // pause될 때 buffer되지는 않는지 확인 필요
  StreamSubscription<KeyFrame>? _subscription;

  Engine(this._instructionStorageSnapshot, this._stageStorageSnapshot);

  void whenReceive(KeyFrame keyFrame) {
    _stageStorageSnapshot.push(keyFrame);
  }

  void start() {
    Stream<KeyFrame> stream = getStreamOfKeyFrame();
    _subscription = stream.listen(
        whenReceive,
        onDone: () {

        }
    );
  }
  void pause() {
    _subscription?.pause();
  }
  void resume() {
    _subscription?.resume();
  }
  Future<void> stop() async {
    return _subscription?.cancel();
  }

  Stream<KeyFrame> getStreamOfKeyFrame() async* {
    while(true) {
      var keyFrame = await getKeyFrame();

      yield keyFrame;
    }
  }
  Future<KeyFrame> getKeyFrame();

  // destruction을 지원하면 수정할 수 있음
  // https://github.com/dart-lang/language/issues/207
  // TODO: 좀더 self-explanatory한 이름으로 지어야 함
  List<dynamic> filter(List<InstructionSection> listOfIS, SOMap begin) {
    List<InstructionSection> residue = [];

    // 정렬이 unstable이라서 무작위 뽑기를 안해도 괜찮을 것 같다.
    listOfIS.sort((a, b) => b.specificity - a.specificity);

    HashSet<StageObject> setForUnOccupiedSO = HashSet.from(begin.iterableOnSO());
    HashSet<StageObject> setForOneIS = HashSet();

    c:
    for(var instructionSection in listOfIS) {
      for(var so in instructionSection.before.iterableOnSO()) {

        if(!setForUnOccupiedSO.contains(so)) {
          setForOneIS.clear();
          continue c;
        }

        setForOneIS.add(so);
      }
      setForUnOccupiedSO.removeAll(setForOneIS);
      setForOneIS.clear();

      residue.add(instructionSection);
    }

    return [residue, setForUnOccupiedSO];
  }


  /*
  late bool _canRun;
  late Completer _engineStop;
  late SOMap _begin;

  void start() {
    _begin = stageViewModel.stageSnapshotStorage.base;

    var stream = _run();
    _canRun = true;
    _engineStop = Completer();
    stream.listen(
        (e) {
          stageViewModel.engineResultStorage.push(e);
        },
        onDone: () {
          _engineStop.complete();
        }
    );
  }
  Future<void> stop() async { // start()를 사용할 수 있을 때 future가 끝남
    _canRun = false;
    return _engineStop.future;
  }

  Stream<EngineResult> _run() async* {
    while(_canRun) {
      // checking conditions...
      if(stageViewModel.engineResultStorage.remainSpace <= 0) continue;

      var begin = _begin;

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

      _begin = end;
      yield EngineResult(listOfIS, begin, end, unchanged);
    }
  }



  List<InstructionSection> findIS(SOMap soMap) {
    List<InstructionSection> result = [];

    for(Instruction instruction in stageViewModel.instructionStorage.get()) {

      List<StageObject> listOfHead = List.from(instruction.head.iteratorOnSO(), growable: false);

      for(int i = 0; i < soMap[listOfHead[0].name].length; i++) {
        StageObject so = soMap[listOfHead[0].name][i];

        instruction.setAbsoluteOffsetToCriterion = so.offset;

        InstructionSection section = InstructionSection(instruction);
        section.addSO(so);

        _dfs(
          section: section,
          listOfHead: listOfHead,
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
      foundSection.absoluteOffset = section.instruction.absoluteOffset;
      result.add(foundSection);
    }

    late StageObject so;
    StageObject instructionSO = listOfHead[depth]!;
    int len = mapOfSOOnStage[instructionSO.name].length;
    for(int i = 0; i < len; i++) {
      so = mapOfSOOnStage[instructionSO.name][i];

      int specificity = calcSpecificity(instructionSO.offset, so.offset);
      if(!section.instruction.possibleSection.contains(so.offset) ||
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
  */
  // below is sameSpecificityRandomizer()
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

}

class EngineV1 extends Engine {

  EngineV1({required InstructionStorageSnapshot instructionStorageSnapshot, required StageStorageSnapshot stageStorageSnapshot})
      : super(instructionStorageSnapshot, stageStorageSnapshot);

  Future<KeyFrame> getKeyFrame() async {
    SOMap begin = _stageStorageSnapshot.latestEndOfSOMap;
    List<InstructionSection> listOfIS = await _getKeyFramePart1(begin);

    var result = filter(listOfIS, begin);
    listOfIS = result[0];
    List<StageObject> middleOfUnChanged = (result[1] as HashSet<StageObject>).toList(growable: false);
    List<StageObjectTween> middleOfChanged = _makeMiddleOfChanged(listOfIS);

    SOMap end = begin.copy();

    await _getKeyFramePart2(end, listOfIS); // remove
    await _getKeyFramePart3(end, listOfIS); // add

    return KeyFrame(begin, middleOfUnChanged, middleOfChanged, end);
  }

  Future<List<InstructionSection>> _getKeyFramePart1(SOMap begin) async {
    await Future.delayed(Duration.zero);
    return generate(begin, _instructionStorageSnapshot);
  }
  Future<void> _getKeyFramePart2(SOMap end, List<InstructionSection> listOfIS) async {
    await Future.delayed(Duration.zero);
    for(var instructionSection in listOfIS) {
      for(var so in instructionSection.before.iterableOnSO()) {
        end.removeAllIdentityEqual(so);
      }
    }
  }
  Future<void> _getKeyFramePart3(SOMap end, List<InstructionSection> listOfIS) async {
    await Future.delayed(Duration.zero);
    for(var instructionSection in listOfIS) {
      for(var so in instructionSection.after.iterableOnSO()) {
        end.add(so);
      }
    }
  }

  List<StageObjectTween> _makeMiddleOfChanged(List<InstructionSection> listOfIS) {
    List<StageObjectTween> tweenList = [];
    for(var instructionSection in listOfIS) {
      for(MapEntry<String, AnimationType> entry in instructionSection.correspondingATMap.entries) {
        switch(entry.value) {
          case AnimationType.DUPLICATE:
            StageObject begin = instructionSection.before[entry.key]![0];
            for(StageObject end in instructionSection.after[entry.key]!) {
              tweenList.add(StageObjectTween(begin, end));
            }
            break;
          case AnimationType.MERGE:
            StageObject end = instructionSection.after[entry.key]![0];
            for(StageObject begin in instructionSection.before[entry.key]!) {
              tweenList.add(StageObjectTween(begin, end));
            }
            break;
          case AnimationType.MANY:
            for(StageObject begin in instructionSection.before[entry.key]!) {
              for(StageObject end in instructionSection.after[entry.key]!) {
                tweenList.add(StageObjectTween(begin, end));
              }
            }
            break;
          case AnimationType.CREATE:
            for(StageObject end in instructionSection.after[entry.key]!) {
              tweenList.add(StageObjectTween(null, end));
            }
            break;
          case AnimationType.VANISH:
            for(StageObject begin in instructionSection.before[entry.key]!) {
              tweenList.add(StageObjectTween(begin, null));
            }
            break;
          case AnimationType.ONE:
            tweenList.add(StageObjectTween(
                instructionSection.before[entry.key]![0],
                instructionSection.after[entry.key]![0]
            ));
            break;
          case AnimationType.UNDEFINED:
            break;
        }
      }
    }

    return tweenList;
  }
}

// stageStorageSnapshot의 크기를 적절하게 유지함
class EngineV2 extends EngineV1 implements StageStorageSnapshotObserver {
  late int sSSnapshotSize;

  EngineV2({required InstructionStorageSnapshot instructionStorageSnapshot, required StageStorageSnapshot stageStorageSnapshot})
      : super(instructionStorageSnapshot: instructionStorageSnapshot, stageStorageSnapshot: stageStorageSnapshot) {
    _stageStorageSnapshot.register(this);
  }

  void updateSSSnapshotSize(int size) {
    sSSnapshotSize = size;
    manageSubscriptionAccordingTo(size);
  }

  void manageSubscriptionAccordingTo(int size) {
    if(_subscription == null) return;

    if(!_subscription!.isPaused && size >= _stageStorageSnapshot.maxSize - 3) {
      // '최대 크기 - 3'보다 커지면 engine 잠시멈춤
      pause();
    }
    if(_subscription!.isPaused && size < _stageStorageSnapshot.maxSize - 6) {
      // '최대 크기 - 6'보다 작아지면 engine 재개
      resume();
    }
  }
}

// 아래의 함수들은 공통된 역할(InstructionSection 생성)을 위해 존재함
// generate()
// fillSuitableISOn()
// calcSpecificity()
// getPossibleArea()
// 나중에 isolate를 위해서 최상위 함수로 선언
List<InstructionSection> generate(SOMap current,
    InstructionStorageSnapshot snapshot) {
  List<InstructionSection> listOfIS = [];

  List<Instruction> instructions = snapshot.instructionStorage.storage;

  for (var instruction in instructions) {
    String instructionID = instruction.id;
    List<StageObject> listOfHead = mapToList(instruction.head);
    int indexOfHead = 0;
    StageObject firstSOOnHead = listOfHead[indexOfHead];

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

