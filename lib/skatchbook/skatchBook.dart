import 'package:flutter/material.dart';
import 'package:stage4viscuit/projectData/projectData.dart';

class SkatchBook extends StatefulWidget {
  const SkatchBook(this.projectBasicInfo, {Key? key}) : super(key: key);
  final ProjectData projectBasicInfo;
  @override
  _SkatchBookState createState() => _SkatchBookState();
}

class _SkatchBookState extends State<SkatchBook> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("skatch book ${widget.projectBasicInfo}"),
      ),
    );
  }
}
