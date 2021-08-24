import 'package:flutter/animation.dart';
import 'package:stage4viscuit/classes/view_model/storage.dart';
import 'dart:async';
import 'presenter_interface.dart';
import '../component/component.dart';
import '../component/animation.dart';
import '../view_model/view_model.dart';
import '../view_model/engine.dart';
import '../view/view_interface.dart';

class StagePresenter implements Presenter {
  late final View _stageOneView;
  late final View _stageTwoView;
  final Completer<void> stageOneViewAccessible = Completer();
  final Completer<void> stageTwoViewAccessible = Completer();
  Future<void> get whenStageOneViewAccessible => stageOneViewAccessible.future;
  Future<void> get whenStageTwoViewAccessible => stageTwoViewAccessible.future;

  late final StageViewModel stageViewModel;
  late StageViewModelOnRunning stageViewModelOnRunning;
  late FrameManager frameManager;

  static Future<StagePresenter> create() async {
    var stagePresenter = StagePresenter._();
    stagePresenter.stageViewModel = await StageViewModelWithLocalImage.create();
    return stagePresenter;
  }
  StagePresenter._();

  set stageOneView(View view) {
    _stageOneView = view;
    _stageOneView.refresh(viewModel: stageViewModel);
  }
  set stageTwoView(View view) {
    _stageTwoView = view;
    _stageTwoView.refresh(viewModel: stageViewModel);
  }

  Future<void> start() async { // stageOneView에 접근할 수 있다고 가정
    stageViewModelOnRunning = stageViewModel.stageViewModelOnRunning;
    frameManager = FrameManager(stageOneView: _stageOneView, stageViewModelOnRunning: stageViewModelOnRunning);

    await frameManager.start();

    _stageOneView.refresh(viewModel: stageViewModelOnRunning);
  }
  void pause() { // stageOneView, stageTwoView에 접근할 수 있다고 가정
    if(stageViewModelOnRunning.animationStatus != ExtendedAnimationStatus.FORWARD)
        throw Exception("애니메이션이 forward상태여야 합니다. 현재: ${stageViewModelOnRunning.animationStatus}");

    stageViewModelOnRunning.animationStatus = ExtendedAnimationStatus.PAUSE;
    _stageOneView.refresh(viewModel: stageViewModel);
  }
  void resume() { // stageOneView, stageTwoView에 접근할 수 있다고 가정

  }
  void stop() { // stageOneView, stageTwoView에 접근할 수 있다고 가정

  }
  // #일단 보류 void nextFrame() {} // stageOneView, stageTwoView에 접근할 수 있다고 가정
  void nextKeyFrame() { // stageOneView, stageTwoView에 접근할 수 있다고 가정

  }
}

// stageViewModelOnRunning을 관리
// 코드를 실행(running)하는 상태가 되면 StagePresenter는
// 관련된 권한을 FrameManager에게 위임
// StagePresenter는 외부에서 쉽게 사용가능한 API를 제공하는 역할
class FrameManager {
  // TODO: 나중에 buffer기능 넣어서 Frame 간 전후이동 가능케 하기

  StageViewModelOnRunning stageViewModelOnRunning;
  View _stageOneView;

  FrameManager({required View stageOneView, required this.stageViewModelOnRunning}) : _stageOneView = stageOneView;

  // dummy implementation; buffer를 구현해야 함
  /*
  setFrom({int keyFrameNum = 0, AnimationDouble animationDouble = 0}) {
    if(keyFrameNum >= sSSnapshot.startSize) throw Exception("buffer에 존재하지 않는 keyFrame 번호입니다.");
    if(animationDouble < 0 || animationDouble >= 1) throw Exception("옳바르지 않은 animationDouble 값 입니다. (0 <= animationDouble < 1");

    stageViewModel.keyFrame = sSSnapshot.poll();
    stageViewModel.animationDouble = 0;
    stageViewModel.frame = stageViewModel.keyFrame.getFrameAt(stageViewModel.animationDouble);
  }
   */

  Future<void> start() async {
    stageViewModelOnRunning.engine.start();
    await stageViewModelOnRunning.sSSnapshot.whenFilledAsStartSize;

    stageViewModelOnRunning.animationStatus = ExtendedAnimationStatus.START;
    _stageOneView.refresh(viewModel: stageViewModelOnRunning);
  }

  void nextFrame(AnimationDouble animationDouble) {
    if(stageViewModelOnRunning.animationDouble > animationDouble) {
      stageViewModelOnRunning.keyFrame = stageViewModelOnRunning.sSSnapshot.poll();
      //print("next frame");
    }

    stageViewModelOnRunning.animationDouble = animationDouble;
    stageViewModelOnRunning.frame = stageViewModelOnRunning.keyFrame.getFrameAt(animationDouble);

    _stageOneView.refresh(viewModel: stageViewModelOnRunning);
  }

  void afterStartOnStageOneView() {
    stageViewModelOnRunning.animationStatus = ExtendedAnimationStatus.FORWARD;
  }
  void afterPauseOnStageOneView(AnimationDouble value) {

  }
  void afterResumeOnStageOneView() {

  }
  void afterStopOnStageOneView() {

  }
}