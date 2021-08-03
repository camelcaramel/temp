import '../model/storage.dart';
import '../model/engine.dart';
import '../component/component.dart';
import '../component/animation.dart';
import '../view/stage.dart';
import 'package:flutter/animation.dart';


class Presenter {

  late final Stage stage;
  late final Storage storage;
  late final Engine engine;
  late EngineResult engineResult;

  Presenter({required this.stage}) {
    storage = Storage(presenter: this);
    engine = Engine(presenter: this, storage: storage);
  }

  Future<void> start() async {
    await storage.erStorage.ready();
    engineResult = storage.erStorage.poll();
  }
  Future<void> stop() async {
    await engine.stop();
    storage.erStorage.clear();
  }

  SOMap getUnchangedSOs() {
    return engineResult.unchanged;
  }
  SOMap getChangedSOs(double d) {
    SOMap soMap = SOMap();
    for(var instructionSection in engineResult.listOfIS) {
      var bindList = _bindSOOnHeadAndBody(instructionSection);

      for(Tween<StageObject> tween in bindList) {
        soMap.addSO(tween.transform(d));
      }
    }

    return soMap;
  }

  // correspondingSOMap, finalSOMap 내 SO를 correspondingATMap을 기준으로 묶기
  List<Tween<StageObject>> _bindSOOnHeadAndBody(InstructionSection section) {
    List<Tween<StageObject>> bindList = [];
    for(MapEntry<String, AnimationType> entry in section.instruction.correspondingATMap.entries) {

      switch(entry.value) {
        case AnimationType.DUPLICATE: {
          StageObject begin = section.correspondingSOMap[entry.key][0];
          for(StageObject end in section.finalSOMap[entry.key]) {
            bindList.add(Tween(
                begin: begin,
                end: end
            ));
          }
          break;
        }
        case AnimationType.MERGE: {
          StageObject end = section.finalSOMap[entry.key][0];
          for(StageObject begin in section.correspondingSOMap[entry.key]) {
            bindList.add(Tween(
                begin: begin,
                end: end
            ));
          }
          break;
        }
        case AnimationType.MANY: {
          bindList.addAll(_many(section, entry.key));
          break;
        }
        case AnimationType.CREATE: {
          for(StageObject end in section.finalSOMap[entry.key]) {
            bindList.add(Tween(
                begin: StageObject.empty(),
                end: end
            ));
          }
          break;
        }
        case AnimationType.VANISH: {
          for(StageObject begin in section.correspondingSOMap[entry.key]) {
            bindList.add(Tween(
                begin: begin,
                end: StageObject.empty()
            ));
          }
          break;
        }
        case AnimationType.ONE: {
          bindList.add(Tween(
              begin: section.correspondingSOMap[entry.key][0],
              end: section.finalSOMap[entry.key][0]
          ));
          break;
        }
        case AnimationType.UNDEFINED:
        default:
          break;
      }
    }

    return bindList;
  }

  List<Tween<StageObject>> _many(InstructionSection section, String name) {
    List<Tween<StageObject>> bindList = [];
    for(StageObject begin in section.correspondingSOMap[name]) {
      for(StageObject end in section.finalSOMap[name]) {
        bindList.add(Tween(
            begin: begin,
            end: end
        ));
      }
    }

    return bindList;
  }
}
