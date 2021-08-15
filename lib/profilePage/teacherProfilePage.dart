import 'package:flutter/material.dart';

class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage(this.uid, {Key? key}) : super(key: key);
  final String uid;
  @override
  _TeacherProfilePageState createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Teacher Profile Page"),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Container(child: Text("create class")),
              Container(
                child: Text("create project"),
              )
            ],
          ),
          Row(
            children: [
              Container(
                child: Text("my project"),
              ),
              Container(
                child: Text("class list"),
              )
            ],
          )
        ],
      ),
    );
  }
}
