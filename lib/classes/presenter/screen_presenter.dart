import 'dart:async';
import '../component/exception.dart';
import 'stage_presenter.dart';
import './presenter_interface.dart';
import '../view/view_interface.dart';
import '../view_model/view_model.dart';

class ScreenPresenter implements Presenter {
  late final StagePresenter stagePresenter;

  late final View _stageSectionView;
  late final View _consoleSectionView;
  late final View _buttonSectionView;
  final Completer<void> stageSectionViewAccessible = Completer();
  final Completer<void> consoleSectionViewAccessible = Completer();
  final Completer<void> buttonSectionViewAccessible = Completer();
  Future<void> get whenStageSectionViewAccessible => stageSectionViewAccessible.future;
  Future<void> get whenConsoleSectionViewAccessible => consoleSectionViewAccessible.future;
  Future<void> get whenButtonSectionViewAccessible => buttonSectionViewAccessible.future;

  Completer<void> isScreenPresenterCreated = Completer();
  Completer<void> isStagePresenterCreated = Completer();

  late final StageSectionViewModel stageSectionViewModel;
  late final ConsoleSectionViewModel consoleSectionViewModel;
  late final ButtonSectionViewModel buttonSectionViewModel;

  ScreenPresenter()
      : stageSectionViewModel = StageSectionViewModel(),
        consoleSectionViewModel = ConsoleSectionViewModel(),
        buttonSectionViewModel = ButtonSectionViewModel()
  {
    isScreenPresenterCreated.complete();
    whenConsoleSectionViewAccessible.then((_) {
      writeOnConsole("stagePresenter 생성 중...");
      return StagePresenter.create();
    }).then((StagePresenter stagePresenter) {
      this.stagePresenter = stagePresenter;
      stageSectionViewModel.replaceBlankToStage(stagePresenter);
      _stageSectionView.refresh(viewModel: stageSectionViewModel);
      isStagePresenterCreated.complete();
      writeOnConsole("stagePresenter 생성됨");
    }).then((_) {
      afterAllPresenterCreated();
    });
  }

  void afterAllPresenterCreated() {

  }

  set stageSectionView(View view) {
    _stageSectionView = view;
    _stageSectionView.refresh(viewModel: stageSectionViewModel);
  }
  set consoleSectionView(View view) {
    _consoleSectionView = view;
    _consoleSectionView.refresh(viewModel: consoleSectionViewModel);
  }
  set buttonSectionView(View view) {
    _buttonSectionView = view;
    _buttonSectionView.refresh(viewModel: buttonSectionViewModel);
  }

  void clickPlayButton() {}
  void clickPauseButton() {}
  void clickStopButton() {}

  void writeOnConsole(String text) {
    consoleSectionViewModel.write(text);
    _consoleSectionView.refresh(viewModel: consoleSectionViewModel);
  }

  void writeMultiOnConsole(Iterable<String> texts) {
    for(String text in texts) writeOnConsole(text);
  }
}

class ScreenPresenterConsoleEnhanced extends ScreenPresenter {
  final Map<String, Command> commandMapping = {};
  Command? currentCommand;
  List<String> receivedArgument = [];

  void afterAllPresenterCreated() {
    addCommand(CLS());
    addCommand(JsonCommand());
    addCommand(AllCommand());
    addCommand(StartCommand());
  }

  // 메소드 내 모든 Presenter가 생성되어야 함
  void addCommand<P extends Presenter>(Command<P> command) {
    List<Future<void>> condition = [];

    command.writeOnConsole = this.writeOnConsole;

    late Presenter presenter;
    if(P == StagePresenter) {
      presenter = stagePresenter;
      condition.add(isStagePresenterCreated.future);
    } else if(P == ScreenPresenterConsoleEnhanced) {
      presenter = this;
      condition.add(isScreenPresenterCreated.future);
    } else {
      throw UnsupportedException();
    }

    for(ViewName viewName in command.requiredView) {
      switch(viewName) {
        case ViewName.StageOneView:
          condition.add(stagePresenter.whenStageOneViewAccessible);
          break;
        case ViewName.StageTwoView:
          condition.add(stagePresenter.whenStageTwoViewAccessible);
          break;
        case ViewName.StageSectionView:
          condition.add(whenStageSectionViewAccessible);
          break;
        case ViewName.ConsoleSectionView:
          condition.add(whenConsoleSectionViewAccessible);
          break;
        case ViewName.ButtonSectionView:
          condition.add(whenButtonSectionViewAccessible);
          break;
        default:
          throw UnsupportedException();
      }
    }

    Future.wait(condition).then((_) {
      command._presenter = presenter as P;
      commandMapping[command.commandName] = command;
    });
  }

  void writeOnConsoleWithInterpreting(String text) {
    writeOnConsole(text);
    interpret(text).then((List<String>? interpreted) {
      if(interpreted == null) return;

      writeMultiOnConsole(interpreted);
    });
  }

  Future<List<String>?> interpret(String text) async {

    bool canExecuteCommand = false;

    if(currentCommand == null) {
      if(commandMapping.containsKey(text)) {
        currentCommand = commandMapping[text];
        if(currentCommand!.neededArgumentCount == 0) canExecuteCommand = true;
      } else {
        return ["지원하지 않는 명령어입니다."];
      }
    } else {
      receivedArgument.add(text);
      if(currentCommand!.neededArgumentCount == receivedArgument.length) {
        canExecuteCommand = true;
      }
    }
    if(!canExecuteCommand) return null;

    List<String>? result = await currentCommand!.execute(receivedArgument);

    receivedArgument.clear();
    currentCommand = null;

    return result;
  }
}

enum ViewName {
  StageOneView,
  StageTwoView,
  StageSectionView,
  ConsoleSectionView,
  ButtonSectionView,
}

abstract class Command<P extends Presenter> {
  late final P _presenter;
  late final writeOnConsole;

  final String commandName;
  final int neededArgumentCount;
  //final String? idForSameClassObj; // 동일한 클래스로 생성된 View나 ViewModel 객체를 서로 구분하기 위한 식별자
  late final List<ViewName> requiredView;

  Command(this.commandName, this.neededArgumentCount, {List<ViewName>? requiredView}) {
    this.requiredView = requiredView ?? List<ViewName>.empty();
  }

  Future<List<String>?> execute(List<String> argument) async {
    List<String>? result = await run(argument);
    refreshHook();
    return result;
  }

  Future<List<String>?> run(List<String> argument);
  void refreshHook() {}
}

class CLS extends Command<ScreenPresenterConsoleEnhanced> {
  CLS() : super("cls", 0);

  Future<List<String>?> run(List<String> argument) async {
    _presenter.consoleSectionViewModel.consoleTexts.clear();
  }

  void refreshHook() {
    _presenter._consoleSectionView.refresh(
        viewModel: _presenter.consoleSectionViewModel);
  }
}

class JsonCommand extends Command<StagePresenter> {
  JsonCommand() : super("json", 1, requiredView: [ViewName.StageOneView, ViewName.ConsoleSectionView]);

  Future<List<String>?> run(List<String> argument) async {
    String json = argument[0];
    try {
      _presenter.stageViewModel.fillFromJson(json);
    } on FormatException {
      return ["Json 자체가 잘못되었습니다."];
    } on TypeError {
      return ["Json이 요구되는 형식에 맞지 않습니다."];
    }

    return ["해석 완료"];
  }
}

class AllCommand extends Command<ScreenPresenterConsoleEnhanced> {
  AllCommand() : super("all", 0);

  Future<List<String>?> run(List<String> argument) async {
    List<String> commandNames = _presenter.commandMapping.keys.map((command) => "---$command").toList();
    return commandNames;
  }
}

class StartCommand extends Command<StagePresenter> {
  StartCommand() : super("start", 0, requiredView: [ViewName.StageOneView, ViewName.ConsoleSectionView]);

  Future<List<String>?> run(List<String> argument) async {
    writeOnConsole("시작 준비 중...");
    await _presenter.start();
    return ["시작되었습니다."];
  }
}


