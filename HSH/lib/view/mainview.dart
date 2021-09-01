import 'dart:async';
import 'package:dragtest_version_0/presenter/dragpresenter.dart';
import 'package:flutter/material.dart';

var sc = StreamController.broadcast();

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, required this.DragController})
      : super(key: key);

  final String title;
  final DragWidgetPresenter DragController;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          color: Colors.yellow,
          child: DragTarget(
            builder: (context, candidateData, rejectedData) {
              return Stack(
                children: [dragwidget()],
              );
            },
            onAcceptWithDetails: (detail) {
              double x = detail.offset.dx;
              double y = detail.offset.dy - 56;

              String operator = x.toString() + ':' + y.toString();

              widget.DragController.set_movement(operator);
              setState(() {});
            },
          ),
        ));
  }

  Widget dragwidget() {
    return Positioned(
        left: widget.DragController.call_left(),
        top: widget.DragController.call_top(),
        child: Draggable(
          child: FlutterLogo(
            size: 50,
          ),
          feedback: FlutterLogo(
            size: 50,
          ),
          data: 'hello',
        ));
  }
}
/*
OnStackWidget Test = new OnStackWidget(new DragWidgetPresenter());

class OnStackWidget extends StatefulWidget {
  late final DragWidgetPresenter DragController;

  OnStackWidget(this.DragController);

  @override
  OnStackWidgetState createState() => OnStackWidgetState();
}

class OnStackWidgetState extends State<OnStackWidget> {
  @override
  var broadcastStream = sc.stream;

  @override
  void initState() {
    if (this.mounted) {
      broadcastStream.listen((data) => movement(data));
    }
  }

  void movement(String data) {
    if (this.mounted) {
      print("GO");
      setState(() {
        widget.DragController.set_movement(data);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: widget.DragController.call_left(),
        top: widget.DragController.call_top(),
        child: Draggable(
          child: FlutterLogo(
            size: 50,
          ),
          feedback: FlutterLogo(
            size: 50,
          ),
        ));
  }
}
*/