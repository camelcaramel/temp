import 'package:flutter/material.dart';
import '../presenter/stage_presenter.dart';
import '../view_model/view_model.dart';
import '../view_model/view_model_interface.dart';
import './view_interface.dart';

class Stage extends StatefulWidget {
  final GlobalKey _globalKey;
  final StagePresenter stagePresenter;
  final stageNum;

  Stage({required this.stagePresenter, required this.stageNum}) : _globalKey = GlobalKey();

  _StageState createState() => _StageState();
}

class _StageState extends State<Stage> implements View {
  late StageViewModel _viewModel;

  void initState() {
    super.initState();
    widget.stagePresenter.stageView = this;
  }

  void refresh({required ViewModel viewModel}) {
    setState(() {
      _viewModel = viewModel as StageViewModel;
    });
  }

  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: widget._globalKey,
      child: CustomPaint(
        size: Size(600, 450),
        painter: MyPainter(/*생성자를 통해 적절한 값 제공*/),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  void paint(Canvas canvas, Size size) {

  }

  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }


}
