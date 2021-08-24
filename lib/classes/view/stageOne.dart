import 'package:flutter/material.dart';
import 'dart:ui' as UI;
import '../component/component.dart';
import '../presenter/stage_presenter.dart';
import '../view_model/view_model_interface.dart';
import '../view_model/view_model.dart';
import 'view_interface.dart';

class StageOne extends StatefulWidget {
  final GlobalKey _globalKey;
  final StagePresenter stagePresenter;

  StageOne({required this.stagePresenter}) : _globalKey = GlobalKey();

  StageOneState createState() => StageOneState();
}

// 애니메이션 관련해서는 오직 StagePresenter의 FrameManager와 연락함
class StageOneState extends State<StageOne> with SingleTickerProviderStateMixin implements View {
  bool isFirstBuildDone = false;
  late ViewModel _viewModel;
  late FrameManager _frameManager;

  late AnimationController animationController;

  void initState() {
    super.initState();
    widget.stagePresenter.stageOneView = this;

    animationController = new AnimationController(
      duration: Duration(seconds: 1), // 값을 변경하면 애니메이션 속도 조절 가능
      vsync: this
    )..addListener(() {
      _frameManager.nextFrame(animationController.value);
    });
  }

  void afterBuild(_) {
    if(!isFirstBuildDone) {
      widget.stagePresenter.stageOneViewAccessible.complete();
    }
    isFirstBuildDone = true;
  }

  void refresh({required ViewModel viewModel}) {
    setState(() {
      _viewModel = viewModel;
    });
    if(_viewModel is StageViewModel) {

    } else /*_viewModel is StageViewModelOnRunning*/ {
      switch((_viewModel as StageViewModelOnRunning).animationStatus) {
        case ExtendedAnimationStatus.BEFORE:

          break;
        case ExtendedAnimationStatus.START:
        // 이때 frameManager가 초기화됨
          _frameManager = widget.stagePresenter.frameManager;
          animationController.repeat();

          _frameManager.afterStartOnStageOneView();
          break;
        case ExtendedAnimationStatus.FORWARD:
          break;
        case ExtendedAnimationStatus.PAUSE:
          animationController.stop();
          double currentValue = animationController.value;

          _frameManager.afterPauseOnStageOneView(currentValue);
          break;
        case ExtendedAnimationStatus.RESUME:
          animationController.repeat();

          _frameManager.afterResumeOnStageOneView();
          break;
        case ExtendedAnimationStatus.STOP:

          _frameManager.afterStopOnStageOneView();
          break;
        case ExtendedAnimationStatus.USER:
          break;
      }
    }
  }

  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback(afterBuild);
    /*
    return Container(
      child: _viewModel is StageViewModelOnRunning ?
        Text("${(_viewModel as StageViewModelOnRunning).animationDouble.toStringAsFixed(3)}, status: ${animationController.status}") :
        Text("not ready"),
    );
     */
    return Container(
      margin: EdgeInsets.all(10),
      child: ClipRect(
        child: CustomPaint(
          size: Size(600, 450),
          painter: StageOnePainter(decorator: (_viewModel as PainterDecoratorObtainable).painterDecorator),
        ),
      ),
    );
  }
}

/*
커맨드 패턴 :
build()마다 커맨드 객체의 재사용 가능
데코레이터 패턴 :
bulid()마다 새로운 객체 생성, but Dart의 가비지 컬렉션의 특징 때문에
보다 적은 오버헤드를 기대할 수 있음
*/

class StageOnePainter extends CustomPainter {
  PainterDecorator? _decorator;

  StageOnePainter({required PainterDecorator? decorator}) : _decorator = decorator;

  void paint(Canvas canvas, Size size) {
    _paintBorder(canvas, size);
    _decorator?.paint(canvas, size);
  }

  void _paintBorder(Canvas canvas, Size size) {
    Paint paint = Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = Colors.blue;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

abstract class PainterDecorator {
  late PainterDecorator? decorator;
  void paint(Canvas canvas, Size size);
}

// 현재 구현 클래스 내부에서 하드코딩함; 사용자의 입력값에 따라
// 적절한 데코레이터를 반환하도록 수정 필요
abstract class PainterDecoratorObtainable {
  PainterDecorator get painterDecorator;
}

class SOMapPainter implements PainterDecorator {
  PainterDecorator? decorator;
  SOMap soMap;
  ImageAccessible imageAccessor;

  SOMapPainter({required this.soMap, required this.imageAccessor, this.decorator});

  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.stroke;

    for(MapEntry<String, SOList> entry in soMap.entries) {
      String imgName = entry.key;
      UI.Image uiImg = imageAccessor.uiImg(imgName);

      for(var so in entry.value) {
        canvas.drawImage(uiImg, so.offset, paint);
      }
    }

    decorator?.paint(canvas, size);
  }
}

class PossibleAreaPainter implements PainterDecorator {
  PainterDecorator? decorator;
  StageViewModelOnRunning _viewModel;

  PossibleAreaPainter({required StageViewModelOnRunning stageViewModelOnRunning, this.decorator}) : _viewModel = stageViewModelOnRunning;

  void paint(Canvas canvas, Size size) {


    decorator?.paint(canvas, size);
  }
}

