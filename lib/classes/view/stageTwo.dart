import 'package:flutter/material.dart';
import '../presenter/stage_presenter.dart';
import '../view_model/view_model_interface.dart';
import '../view_model/view_model.dart';
import 'view_interface.dart';

// Animation 없음
class StageTwo extends StatefulWidget {
  final GlobalKey _globalKey;
  final StagePresenter stagePresenter;

  StageTwo({required this.stagePresenter}) : _globalKey = GlobalKey();

  StageTwoState createState() => StageTwoState();
}

class StageTwoState extends State<StageTwo> implements View {
  bool isFirstBuildDone = false;
  late StageViewModel _viewModel;

  void initState() {
    super.initState();
    widget.stagePresenter.stageTwoView = this;
  }

  void afterBuild(_) {
    if(!isFirstBuildDone) {
      widget.stagePresenter.stageTwoViewAccessible.complete();
    }
    isFirstBuildDone = true;
  }

  void refresh({required ViewModel viewModel}) {
    setState(() {
      _viewModel = viewModel as StageViewModel;
    });
  }

  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback(afterBuild);
    return Container(
      margin: EdgeInsets.all(10),
      child: RepaintBoundary(
        key: widget._globalKey,
        child: CustomPaint(
          size: Size(600, 450),
          painter: StageTwoPainter(/*생성자를 통해 적절한 값 제공*/),
        ),
      ),
    );
  }
}

class StageTwoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    throw UnimplementedError();
  }

}