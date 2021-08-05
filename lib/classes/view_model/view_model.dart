import 'package:flutter/material.dart';
import '../presenter/stage_presenter.dart';
import '../view/stage.dart';
import './view_model_interface.dart';

class StageSectionViewModel implements ViewModel {
  late Widget stageOne;
  late Widget stageTwo;

  late List<Widget> stages;

  StageSectionViewModel() {
    stageOne = blank();
    stageTwo = blank();

    stages = [stageOne];
  }


  Widget blank() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Container(
        width: 600,
        height: 450,
        color: Colors.blueAccent,
      ),
    );
  }

  void after(StagePresenter stagePresenter) {
    stageOne = Stage(
        stagePresenter: stagePresenter,
        stageNum: 1
    );
    stageTwo = Stage(
        stagePresenter: stagePresenter,
        stageNum: 2
    );
  }
}

class StageViewModel implements ViewModel {

}

class StageOneViewModel extends StageViewModel {

}

class StageTwoViewModel extends StageViewModel {

}

class InteractionSectionViewModel implements ViewModel {
  Console console;

  InteractionSectionViewModel() : this.console = Console();

}

class Console {

  static const double commandFontSize = 13;
  static const double commandHeight = 20;

  final List<Command> commands;

  Console() : commands = [];

  void write(String command) {
    commands.add(_getCommandWidget(command));
  }

   Future<String?> interpret(String command) async {
    if(command == "cls") {
      commands.clear();

    }
  }

  Command _getCommandWidget(String command, [Color color = Colors.white]) {
    return Command(command, color);
  }
}

class Command extends StatelessWidget {
  final String command;
  final Color color;
  Command(this.command, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: Row(
        // ADJUST - a little bit hacky way https://stackoverflow.com/questions/54173241/how-to-vertically-align-text-inside-container
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            command,
            style: TextStyle(
              fontSize: Console.commandFontSize,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}


