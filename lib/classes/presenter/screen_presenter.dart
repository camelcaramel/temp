import 'dart:async';
import './stage_presenter.dart';
import './presenter_interface.dart';
import '../view/view_interface.dart';
import '../view_model/view_model.dart';

class ScreenPresenter implements Presenter {
  late final StagePresenter stagePresenter;

  late final View _stageSectionView;
  late final View _interactionSectionView;
  final Completer<void> _stageSectionViewMounted;
  final Completer<void> _interactionSectionViewMounted;

  late final StageSectionViewModel stageSectionViewModel;
  late final InteractionSectionViewModel interactionSectionViewModel;
  ScreenPresenter() :
    interactionSectionViewModel = InteractionSectionViewModel(),
    stageSectionViewModel = StageSectionViewModel(),
    _stageSectionViewMounted = Completer(),
    _interactionSectionViewMounted = Completer()
  {
    Future.wait([
      _stageSectionViewMounted.future,
      _interactionSectionViewMounted.future
    ]).then((_) {
      writeOnConsole("enginePresenter 생성 중...");
      StagePresenter.create().then((StagePresenter stagePresenter) {
        this.stagePresenter = stagePresenter;
        _stageSectionView.refresh(
            viewModel: stageSectionViewModel..after(stagePresenter));
        writeOnConsole("enginePresenter 생성됨");
      });
    });
  }

  set stageSectionView(View view) {
    _stageSectionView = view;
    _stageSectionViewMounted.complete();
    _stageSectionView.refresh(viewModel: stageSectionViewModel);
  }

  set interactionSectionView(View view) {
    _interactionSectionView = view;
    _interactionSectionViewMounted.complete();
    _interactionSectionView.refresh(viewModel: interactionSectionViewModel);
  }


  void clickPlayButton() {}
  void clickPauseButton() {}
  void clickStopButton() {}

  void writeOnConsole(String command) {
    var console = interactionSectionViewModel.console;
    console.write(command);
    console.interpret(command).then((String? result) {
      if(result == null) return;

    });
    _interactionSectionView.refresh(viewModel: interactionSectionViewModel);
  }
}
