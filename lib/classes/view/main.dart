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
        body: Screen(ScreenPresenter()),
      ),
    );
  }
}

class Screen extends StatefulWidget {
  late final ScreenPresenter screenPresenter;

  Screen(this.screenPresenter);

  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
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
  final ScreenPresenter screenPresenter;

  StageSection({required this.screenPresenter});

  _StageSectionState createState() => _StageSectionState();
}

class _StageSectionState extends State<StageSection> implements View {
  late StageSectionViewModel _viewModel;

  void initState() {
    super.initState();
    widget.screenPresenter.stageSectionView = this;
  }

  void refresh({required ViewModel viewModel}) {
    setState(() {
      _viewModel = viewModel as StageSectionViewModel;
    });
  }

  Widget build(BuildContext context) {
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

class InteractionSection extends StatefulWidget {
  final ScreenPresenter screenPresenter;
  InteractionSection({required this.screenPresenter});

  _InteractionSectionState createState() => _InteractionSectionState();
}

class _InteractionSectionState extends State<InteractionSection>
    implements View {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  late final Widget writeCommand;

  late InteractionSectionViewModel _viewModel;

  initState() {
    super.initState();
    widget.screenPresenter.interactionSectionView = this;
    writeCommand = _getWriteCommand();
  }

  void refresh({required ViewModel viewModel}) {
    setState(() {
      _viewModel = viewModel as InteractionSectionViewModel;
    });
  }

  Widget build(BuildContext context) {
    return Container(
      width: 1500,
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 600,
              height: 230,
              padding: EdgeInsets.only(left: 5),
              margin: EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                border: Border.all(),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.builder(
                itemExtent: 20,
                itemCount: _viewModel.console.commands.length + 1,
                itemBuilder: (_, int index) {
                  if (index == _viewModel.console.commands.length) return writeCommand;
                  return _viewModel.console.commands[index];
                },
                controller: _scrollController,
              ),
            ),
          ),
          Container(
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
                      onPressed: () {
                        widget.screenPresenter.clickPlayButton();
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(),
                    child: IconButton(
                      icon: Icon(Icons.pause_outlined),
                      onPressed: () {
                        widget.screenPresenter.clickPauseButton();
                      },
                    ),
                  ),
                  Container(
                    child: IconButton(
                      icon: Icon(Icons.stop_outlined),
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
          ),
        ],
      ),
    );
  }

  Widget _getWriteCommand() {
    return Container(
      width: 590,
      color: const Color(0xFF2A2A2A),
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
            contentPadding: EdgeInsets.only(),
          ), // style
          style: TextStyle(
            fontSize: Console.commandFontSize,
            color: Colors.white,
          ),
          keyboardType: TextInputType.text,
          textAlignVertical: TextAlignVertical(y: 0.05),
          controller: _textController,
          onSubmitted: (String command) {
            widget.screenPresenter.writeOnConsole(command);
            _textController.text = "";
            double maxScrollExtent = _scrollController.position.maxScrollExtent;
            _scrollController.animateTo(
              maxScrollExtent +
                  (maxScrollExtent == 0 ? 0 : Console.commandHeight),
              duration: Duration(milliseconds: 500),
              curve: Curves.linear,
            );
          }),
    );
  }
}
