import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stage4viscuit/skatchbook/skatchBook.dart';
import 'package:stage4viscuit/userInfo/userInfo.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage(this.userInfo, {Key? key}) : super(key: key);
  final UserInfo userInfo;
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("profilePage ${widget.userInfo.getUID}"),
      ),
      body: Column(
        children: [
          Container(
            // 프로젝트 생성하는 버튼
            child: TextButton(
              child: Text("make project"),
              onPressed: () {
                ProjectBasicInfo projectBasicInfo =
                    new ProjectBasicInfo(widget.userInfo);
                FirebaseFirestore.instance
                    .collection("Projects")
                    .add(projectBasicInfo.toMap())
                    .catchError((e) {
                  print(
                      "error occured on create new project in profilePage errorcode : \n $e");
                }).then((res) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SkatchBook(projectBasicInfo)));
                });
              },
            ),
          ),
          Row(
            children: [
              // 내가 만든 프로젝트 보여주는 리스트
              // TODO: 리스트 만드는 작업 중입니당
              // Container(
              //   child: FutureBuilder(
              //       future: FirebaseFirestore.instance
              //           .collection("test_user")
              //           .doc(widget.userInfo.uid)
              //           .get(),
              //       builder: (context, snapshot) {
              //         return ListView.builder(itemBuilder: itemBuilder)
              //       }),
              // ),
              // 다른 사람들이 만든 프로젝트를 보여주는 리스트
              Container(
                child: Text("ohters project"),
              )
            ],
          )
        ],
      ),
    );
  }
}

class ProjectBasicInfo {
  final String authorName;
  final String authorUID;
  final Timestamp startDate;
  final Timestamp updateDate;

  ProjectBasicInfo(UserInfo userInfo)
      : this.authorUID = userInfo.getUID,
        this.authorName = userInfo.getName,
        this.startDate = Timestamp.fromDate(new DateTime.now()),
        this.updateDate = Timestamp.fromDate(new DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      "authorName": this.authorName,
      "authorUID": this.authorUID,
      "startDate": this.startDate,
      "updateDate": this.updateDate
    };
  }
}
