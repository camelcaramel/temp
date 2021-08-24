import 'dart:ui';
import 'package:flutter/material.dart';
import '../presenter/screen_presenter.dart';
import '../view_model/view_model.dart';
import '../view_model/view_model_interface.dart';
import './view_interface.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DEBUG for stage4viscuit',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          headline6: TextStyle(
            fontSize: 13,
          ),
        ),
      ),
      home: Scaffold(
        body: Screen(ScreenPresenterConsoleEnhanced()),
      ),
    );
  }
}

class Screen extends StatefulWidget {
  late final ScreenPresenterConsoleEnhanced screenPresenter;

  Screen(this.screenPresenter);

  ScreenState createState() => ScreenState();
}

class ScreenState extends State<Screen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          StageSection(
            screenPresenter: widget.screenPresenter,
          ),
          InteractionSection(
            screenPresenter: widget.screenPresenter,
          ),
        ],
      ),
    );
  }
}

class StageSection extends StatefulWidget {
  final ScreenPresenterConsoleEnhanced screenPresenter;

  StageSection({required this.screenPresenter});

  StageSectionState createState() => StageSectionState();
}

class StageSectionState extends State<StageSection> implements View {
  late StageSectionViewModel _viewModel;
  bool isFirstBuildDone = false;

  void initState() {
    super.initState();
    widget.screenPresenter.stageSectionView = this;
  }

  void refresh({required ViewModel viewModel}) {
    setState(() {
      _viewModel = viewModel as StageSectionViewModel;
    });
  }

  void afterBuild(_) {
    if(!isFirstBuildDone) {
      widget.screenPresenter.stageSectionViewAccessible.complete();
      isFirstBuildDone = true;
    }
  }

  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback(afterBuild);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      width: 1500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(),
      ),
      child: Center(
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: _viewModel.stages),
      ),
    );
  }
}

class InteractionSection extends StatelessWidget {
  final ScreenPresenterConsoleEnhanced screenPresenter;
  InteractionSection({required this.screenPresenter});

  Widget build(BuildContext context) {
    return Container(
      width: 1500,
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ConsoleSection(screenPresenter: screenPresenter),
          ButtonSection(screenPresenter: screenPresenter),
          FreezeIndicator(),
        ],
      ),
    );
  }
}

class ConsoleSection extends StatefulWidget {
  final ScreenPresenterConsoleEnhanced screenPresenter;
  ConsoleSection({required this.screenPresenter});

  ConsoleSectionState createState() => ConsoleSectionState();
}

class ConsoleSectionState extends State<ConsoleSection> implements View {
  late ConsoleSectionViewModel _viewModel;
  bool isFirstBuildDone = false;

  final ScrollController scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();
  late Widget textWritingWidget;

  void initState() {
    super.initState();
    widget.screenPresenter.consoleSectionView = this;
    // 유저에게 보이기 전에 writeCommand 위젯이 생긴다.
    // writeCommand 위젯이 보일 때는 이미 consoleSectionView가
    // screenPresenter에 연결되어 있고, 따라서 writeCommand가
    // 가능한 시점이다.
    textWritingWidget = _getTextWritingWidget();
  }

  void refresh({required ViewModel viewModel}) {
    setState(() {
      _viewModel = viewModel as ConsoleSectionViewModel;
    });
  }

  void afterBuild(_) {
    if(!isFirstBuildDone) {
      widget.screenPresenter.consoleSectionViewAccessible.complete();
      isFirstBuildDone = true;
    }
    scrollToBottom();
  }

  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback(afterBuild);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 600,
        height: 210,
        padding: EdgeInsets.only(left: 5),
        margin: EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          border: Border.all(),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListView.builder(
          //itemExtent: 20,
          itemCount: _viewModel.consoleTexts.length + 1,
          itemBuilder: (_, int index) {
            if (index == _viewModel.consoleTexts.length) return textWritingWidget;
            return _viewModel.consoleTexts[index];
          },
          controller: scrollController,
        ),
      ),
    );
  }

  Widget _getTextWritingWidget() {
    return Container(
      width: 590,
      child: TextField(
          maxLines: null,
          autofocus: true,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
            contentPadding: EdgeInsets.only(top: 10),
            isDense: true,
          ), // style
          style: TextStyle(
            fontSize: ConsoleSectionViewModel.commandFontSize,
            color: Colors.white,
          ),
          keyboardType: TextInputType.text,
          textAlignVertical: TextAlignVertical(y: 0.05),
          controller: textController,
          onSubmitted: (String command) {
            widget.screenPresenter.writeOnConsoleWithInterpreting(command);
            textController.text = "";
          }),
    );
  }

  void scrollToBottom() {
    double maxScrollExtent = scrollController.position.maxScrollExtent;

    scrollController.jumpTo(
      maxScrollExtent
      //maxScrollExtent + (maxScrollExtent == 0 ? 0 : ConsoleSectionViewModel.commandHeight),
    );
  }
}

class ButtonSection extends StatefulWidget {
  final ScreenPresenterConsoleEnhanced screenPresenter;
  ButtonSection({required this.screenPresenter});

  ButtonSectionState createState() => ButtonSectionState();
}

class ButtonSectionState extends State<ButtonSection> implements View {
  late ButtonSectionViewModel _viewModel;
  bool isFirstBuildDone = false;

  void initState() {
    super.initState();
    widget.screenPresenter.buttonSectionView = this;
  }

  void refresh({required ViewModel viewModel}) {
    setState(() {
      _viewModel = viewModel as ButtonSectionViewModel;
    });
  }

  void afterBuild(_) {
    if(isFirstBuildDone == false) {
      widget.screenPresenter.buttonSectionViewAccessible.complete();
      isFirstBuildDone = true;
    }
  }

  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback(afterBuild);
    return Container(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(),
              child: IconButton(
                icon: Icon(Icons.play_arrow_outlined),
                color: _viewModel.playButtonColor,
                onPressed: () {
                  widget.screenPresenter.clickPlayButton();
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(),
              child: IconButton(
                icon: Icon(Icons.pause_outlined),
                color: _viewModel.pauseButtonColor,
                onPressed: () {
                  widget.screenPresenter.clickPauseButton();
                },
              ),
            ),
            Container(
              child: IconButton(
                icon: Icon(Icons.stop_outlined),
                color: _viewModel.stopButtonColor,
                onPressed: () {
                  widget.screenPresenter.clickStopButton();
                },
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FreezeIndicator extends StatefulWidget {
  FreezeIndicatorState createState() => FreezeIndicatorState();
}

class FreezeIndicatorState extends State<FreezeIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double value = 0;
  
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this
    )..addListener(() {
      setState(() {
        value = _controller.value;
      });
    })..repeat();
  }
  
  Widget build(BuildContext context) {
    return Container(
      child: Text("${value.toStringAsFixed(3)}")
    );
  }
}
