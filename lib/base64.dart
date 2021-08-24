import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as UI;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "base64",
      home: Scaffold(
        body: Center(
          child: Container(
            margin: EdgeInsets.all(20),
            child: PaintView(PaintPresenter()),
          ),
        ),
      ),
    );
  }
}

class PaintView extends StatefulWidget {
  final PaintPresenter presenter;

  PaintView(this.presenter);
  PaintViewState createState() => PaintViewState();
}

class PaintViewState extends State<PaintView> implements View {
  late PaintViewModel _viewModel;

  void initState() {
    super.initState();
    widget.presenter.paintView = this;
  }

  void refresh({viewModel}) {
    setState(() {
      _viewModel = viewModel as PaintViewModel;
    });
  }

  Widget build(BuildContext context) {
    return RepaintBoundary(
        child: CustomPaint(
          size: Size(600, 450),
          painter: MyPainter(_viewModel),
        )
    );
  }
}

abstract class View {
  void refresh({viewModel});
}

class PaintPresenter {
  final PaintViewModel paintViewModel = PaintViewModel();
  late final View _paintView;

  set paintView(View paintView) {
    _paintView = paintView;
    _paintView.refresh(viewModel: paintViewModel);

    Future<void>.delayed(Duration(seconds: 5)).then((_) {
      paintImage();
    });
  }

  void paintImage() async {
    UI.Image image = await paintViewModel.loadImage();
    paintViewModel.isImageLoaded = true;
    paintViewModel.image = image;
    _paintView.refresh(viewModel: paintViewModel);
    print("그리기 끝");
  }
}

class PaintViewModel {
  bool isImageLoaded = false;
  late UI.Image image;

  Future<UI.Image> loadImage() {
    Uint8List byteImg = Base64Decoder().convert(
      "eJwVyo0JQjEQA+D0LNSKOIi4g6u4iOBCbyK3UGz7en89+QghkBsel/f9BcCA9IzeIlfJvbTjKK1+zu30rb/aY+1ZDkJIDo+7wl2MTU2U5U9YWafvPhCo50GTmBSWAF8cnzjm"
      //"iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAACxMAAAsTAQCanBgAAAYwaVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8P3hwYWNrZXQgYmVnaW49Iu+7vyIgaWQ9Ilc1TTBNcENlaGlIenJlU3pOVGN6a2M5ZCI/PiA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2JlOm5zOm1ldGEvIiB4OnhtcHRrPSJBZG9iZSBYTVAgQ29yZSA2LjAtYzAwMiA3OS4xNjQ0NjAsIDIwMjAvMDUvMTItMTY6MDQ6MTcgICAgICAgICI+IDxyZGY6UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+IDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiIHhtbG5zOnhtcD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLyIgeG1sbnM6ZGM9Imh0dHA6Ly9wdXJsLm9yZy9kYy9lbGVtZW50cy8xLjEvIiB4bWxuczpwaG90b3Nob3A9Imh0dHA6Ly9ucy5hZG9iZS5jb20vcGhvdG9zaG9wLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bXA6Q3JlYXRvclRvb2w9IkFkb2JlIFBob3Rvc2hvcCAyMS4yIChXaW5kb3dzKSIgeG1wOkNyZWF0ZURhdGU9IjIwMjAtMDctMTZUMjI6MjE6MzArMDk6MDAiIHhtcDpNb2RpZnlEYXRlPSIyMDIwLTA3LTE2VDIyOjE5OjI4KzA5OjAwIiB4bXA6TWV0YWRhdGFEYXRlPSIyMDIwLTA3LTE2VDIyOjE5OjI4KzA5OjAwIiBkYzpmb3JtYXQ9ImltYWdlL3BuZyIgcGhvdG9zaG9wOkNvbG9yTW9kZT0iMyIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDowNDJkZjhhOC1hZTU5LTAwNGUtOWRkNy0zMmExZTNhYzM5NTEiIHhtcE1NOkRvY3VtZW50SUQ9ImFkb2JlOmRvY2lkOnBob3Rvc2hvcDoxMDY1ZmYxOC1jMTc4LTc5NDUtOTI1MS01YTQ5MGIzOGU0YzgiIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpjN2NhZWIwMi00NmFhLTcyNDYtYjBmZS03NWY0OWNkY2EyMzYiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOmM3Y2FlYjAyLTQ2YWEtNzI0Ni1iMGZlLTc1ZjQ5Y2RjYTIzNiIgc3RFdnQ6d2hlbj0iMjAyMC0wNy0xNlQyMjoyMTozMCswOTowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDIxLjIgKFdpbmRvd3MpIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjb252ZXJ0ZWQiIHN0RXZ0OnBhcmFtZXRlcnM9ImZyb20gYXBwbGljYXRpb24vdm5kLmFkb2JlLnBob3Rvc2hvcCB0byBpbWFnZS9wbmciLz4gPHJkZjpsaSBzdEV2dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjA0MmRmOGE4LWFlNTktMDA0ZS05ZGQ3LTMyYTFlM2FjMzk1MSIgc3RFdnQ6d2hlbj0iMjAyMC0wNy0xNlQyMjoxOToyOCswOTowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDIxLjIgKFdpbmRvd3MpIiBzdEV2dDpjaGFuZ2VkPSIvIi8+IDwvcmRmOlNlcT4gPC94bXBNTTpIaXN0b3J5PiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PiJnMvQAAAWRSURBVGhD7ZjLS1VfFMeXmmbmAx+Vpk5KTRENIaXSZiI0UnCkg4KGObAGTf0PHIgIgqDhRISGBYqNGugkKlNERJKwfPTw0cNXlr/7Wb+z5dzjvecer1b39+N+YLPP2fueffZ3rbXX3ufG7PmQ/wGxVv2fJyok0ogKiTSiQiKNqJBIIyok0jjUWevDhw8yPDws8fHxEhsbKzExMVqDvabdWXiNs/z69Sto+9bWlly/fl2Kiop03FB4FvLixQuZmJiQ+vp62dnZsVr98TiUH4gMxIkTJ2RqakqeP38u9+7ds1qD40nIyMiIWqimpkY2Njas1t9PXFycnDp1Sjo6OqStrc1qDUxIIU+fPtUBy8vLVcyfhlBdX1+XT58+qSGD4brY379/L58/f5bLly/L9va2Duq1mLURqC9YCRRm2JlCqLnh6pHe3l5pbGyU3d1dWVxclB8/fuy/zP5S5wSc985XmHt7O9cJCQly7tw5NZqBsfDI2tqaXLt2zWo9iKtHGBxL9ff364A/f/5UUaZGGIXFb2oKEzE1xd5HMc8xhhmPTMVkTVZ0wjzccPXI4OCgrovbt29bLb+fJ0+eyJUrV1QgGI9Qrl69qm2BcJWJFXC3HXRjQTvGqn8TVyFkK+NSFj5goaWlJb2GhYUFDZ/jSsvhGiSkEIq5NtjjlWuKc4GHC2slHEKGlpkgMYon8ADhRVpmcRpRpMeVlZUjhxhCwjGKZ4+kpqZKdna2nD9/XjY3NzUJfP/+XV/Kb+bn5yU5OVnroxDMI6HEhRTCpMGe3NhTTp48Kenp6brQ6UMYk7CHYDgE8ijp+Nu3b/L161er5SCuQrCCCZ20tDStobq6Wj1E/9mzZ1VUWVmZ7hH5+fnWr8LD6ZGkpCQZHx/XA+TQ0JCMjo5aPf4cEDI9PW1d+bvz9OnT1tW/7aRlDnR2DyDuqOAR896UlBR5/PixZGVlya1bt6Suri5o6PoJ6ezsVBd2dXXJy5cvJTEx0er5cxABhCrr7eHDh1JcXCylpaWa4t+9e6feD4SfEJRfvHhRmpub9UEyk90rx4E5QXNEwfpmDRoQwprg0+HmzZsaqsxhZmZGXr9+LQ0NDdYv/fETgmJzHiosLNTQ8ZLX+c2XL1/0+s2bN1obCzrhKxPIeLyH47kdhCDyxo0bGs6E8NjYmCaYpqYm61cH8RPy4MEDefTokczOzqoLvYgAXm6EUOPJt2/fSm5urrbZMckDK7O+zL0TxLDQnz17pkYpKCiwegJzYJSWlhYdnBNvqG8AO0yMULlw4YJ8/PhRr7H23NycrjuMwz1hw0a6vLysQpzp1oQyIji05uTkSEVFhYpxI6A5OPffvXtXX+x1X+A7YnJyUjOXiXsmxbrDQ/RzzRqhmHTuPLLzDIYkRDntYhi8Eyo6AvvVwmx4XsB7pEtgwkyAZzlM5uXl7adv+pgsk8NITkPRx6QJS/YoPMaxKDMz0/pFYFyFMAmv6wSYPJBpWGMcafCEfS0giDbEAZO1YwzHeymMQ7a6dOmStgfDVQiDmnT5pyAszTohTLu7u6W1tVXv3XD9Quzp6dEddWBgQAfFqsb1PEbhHvebYUy7uabfFKA23jHt5p6MV1VVJWfOnNE2RNy/fz/oJmjHVQifnSxUcjkDsw44uLHrmnsyEvGLOOeEgeGNcJ5hLDIWIWYOnKurq5KRkaH37C0mQ925c0drTyDkMPjS8p4vfe75JqO1z2tWj3f6+vr2x/CJ2PPtXVZP+LiukUD4nlGrkXWovaZnOzxjHwOPHZVDC8HthAf5n5qjw2Fh4oQlhYOp23eGV0L+Zerk1atXmg4RgkU5/zg3tVC0t7dLZWWlGoXPhtraWikpKbF6w+PQQo4LNjkSAkeQ4+CvCTluDr1GIpWokEgjKiSyEPkHMDPodHa/HsEAAAAASUVORK5CYII="
    );
    return decodeImageFromList(byteImg);
  }
}


class MyPainter extends CustomPainter {
  final PaintViewModel _viewModel;

  MyPainter(this._viewModel);

  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(0, 0, 600, 450), paint);

    if(_viewModel.isImageLoaded) {
      canvas.drawImage(_viewModel.image, Offset.zero, paint);
    }
  }

  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}