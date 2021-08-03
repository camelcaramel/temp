import 'dart:ui';

import 'package:flutter/material.dart';
import 'classes/presenter/controller.dart';

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
        body: Screen(),
      ),
    );
  }
}

class Screen extends StatefulWidget {
  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  bool _isStepByStep = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Main(),
        Information(),
      ],
    );
  }
}

class Main extends StatefulWidget {
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  bool _isStepByStep = false;

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      // Information의 Console border를 round하게 만들려고 ClipRRect을
      // 사용했지만, child의 margin값으로 인해 top에는 적용이 안되는 문제
      // 발생; 따라서 Main의 bottom에 margin을 줌
      child: Row(
        children: getChildren(),
      ),
    );
  }

  List<Widget> getChildren() {
    List<Widget> list = [getStageOperatingButton(flex: 1)];

    if (_isStepByStep) {
      list.add(getStageWrapper(
        flex: 6,
        listOfStages: [getStage(), getStage()],
      ));
    } else {
      list.add(getStageWrapper(
        flex: 6,
        listOfStages: [getStage()],
      ));
    }

    return list;
  }

  Widget getStageWrapper({flex, listOfStages}) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: EdgeInsets.only(top: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: listOfStages,
          ),
        ),
      ),
    );
  }

  Widget getStageOperatingButton({flex}) {
    return Expanded(
      flex: flex,
      child: Center(
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
                    setState(() {
                      _isStepByStep = false;
                    });
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(),
                child: IconButton(
                  icon: Icon(Icons.pause_outlined),
                  onPressed: () {
                    setState(() {
                      _isStepByStep = true;
                    });
                  },
                ),
              ),
              Container(
                child: IconButton(
                  icon: Icon(Icons.stop_outlined),
                  onPressed: () {},
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getStage() {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
      child: Container(
        width: 600,
        height: 450,
        color: Colors.blueAccent,
      ),
    );
  }
}

class Information extends StatefulWidget {
  @override
  _InformationState createState() => _InformationState();
}

class _InformationState extends State<Information> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        getTransparentBox(flex: 1),
        Console(flex: 4),
        getTransparentBox(flex: 2),
      ],
    );
  }

  Widget getTransparentBox({required flex}) {
    return Expanded(
      flex: flex,
      child: Container(),
    );
  }
}

class Console extends StatefulWidget {
  final int flex;
  final double commandHeight = 20;
  final double fontSize = 13;

  Console({required this.flex});

  _ConsoleState createState() => _ConsoleState();
}

class _ConsoleState extends State<Console> {
  final List<Widget> commands = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  initState() {
    commands.add(_getWriteCommandWidget());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          //margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.only(left: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            border: Border.all(),
            borderRadius: BorderRadius.circular(10),
          ),
          height: 230,
          child: ListView.builder(
            itemExtent: widget.commandHeight,
            itemCount: commands.length,
            itemBuilder: (_, int index) {
              return commands[index];
            },
            controller: _scrollController,
          ),
        ),
      ),
    );
  }

  Widget _getWriteCommandWidget() {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: TextField(
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
          fontSize: widget.fontSize,
          color: Colors.white,
        ),
        keyboardType: TextInputType.text,
        textAlignVertical: TextAlignVertical(y: 0.05),
        controller: _textController,
        onSubmitted: (String command) {
          setState(() {
            commands.insert(commands.length - 1, _getCommandWidget(command));
            _textController.text = "";
            double maxScrollExtent = _scrollController.position.maxScrollExtent;
            _scrollController.animateTo(
                maxScrollExtent + (maxScrollExtent == 0 ? 0 : widget.commandHeight),
                duration: Duration(milliseconds: 500),
                curve: Curves.linear,
            );
          });
        },
      ),
    );
  }

  Widget _getCommandWidget(String command) {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: Row( // ADJUST - a little bit hacky way https://stackoverflow.com/questions/54173241/how-to-vertically-align-text-inside-container
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            command,
            style: TextStyle(
              fontSize: widget.fontSize,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
