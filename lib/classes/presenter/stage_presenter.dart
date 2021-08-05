import 'package:flutter/animation.dart';
import 'dart:async';
import './presenter_interface.dart';
import '../component/component.dart';
import '../component/animation.dart';
import '../view/view_interface.dart';
import '../view/stage.dart';
import '../view_model/view_model.dart';
import '../view_model/storage.dart';

class StagePresenter implements Presenter {
  late final View _stageOne;
  late final View _stageTwo;

  late final StageViewModel stageOneViewModel;
  late final StageViewModel stageTwoViewModel;

  set stageView(View view) {
    int stageNum = (view as Stage).stageNum;
    switch(stageNum) {
      case 1:
        _stageOne = view;
        _stageOne.refresh(viewModel: stageOneViewModel);
        break;
      case 2:
        _stageTwo = view;
        _stageTwo.refresh(viewModel: stageTwoViewModel);
        break;
    }
  }

  final Storage storage;

  late EngineResult engineResult;

  static Future<StagePresenter> create([String? json]) async {
    var stagePresenter = StagePresenter._(json);
    await stagePresenter.initialize();
    return stagePresenter;
  }

  StagePresenter._([String? json])
      : storage = Storage(json),
        stageOneViewModel = StageOneViewModel(),
        stageTwoViewModel = StageTwoViewModel();


  Future<void> initialize() async {
    await storage.initialize();
  }

  Future<void> start() async {
    storage.engine.start();
    await storage.erStorage.ready();
    engineResult = storage.erStorage.poll();
  }
  Future<void> stop() async {
    await storage.engine.stop();
    storage.erStorage.clear();
    storage.erStorage.prefill = Completer<void> ();
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
