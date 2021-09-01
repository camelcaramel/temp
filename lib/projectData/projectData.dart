import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stage4viscuit/userInfo/userInfo.dart';

class ProjectData {
  final String authorName;
  final String authorUID;
  String pUID = "empty";
  Timestamp startDate;
  Timestamp updateDate;
  String data;

  ProjectData(UserData userInfo)
      : this.authorUID = userInfo.getUID,
        this.authorName = userInfo.getName,
        this.startDate = Timestamp.fromDate(new DateTime.now()),
        data = "empty proejct",
        this.updateDate = Timestamp.fromDate(new DateTime.now());

  void setProjectUID(String uid) {
    this.pUID = uid;
  }

  Map<String, dynamic> toMap() {
    return {
      "authorName": this.authorName,
      "authorUID": this.authorUID,
      "startDate": this.startDate,
      "updateDate": this.updateDate,
      "pUID": this.pUID,
      "data": this.data,
    };
  }
}

class ProjectCache {
  final String authorName;
  final String authorUID;
  final String pUID;
  String thumbnail;

  ProjectCache.fromJson(dynamic doc)
      : this(
            doc["authorName"], doc["authorUID"], doc["thumbnail"], doc["pUID"]);

  ProjectCache.fromProjectData(Map<String, dynamic> data)
      : this(data["authorName"], data["authorUID"], "empty", data["pUID"]);

  ProjectCache(
      String authorName, String authorUID, String thumbnail, String pUID)
      : this.authorName = authorName,
        this.authorUID = authorUID,
        this.pUID = pUID,
        this.thumbnail = thumbnail;

  Map<String, dynamic> toMap() {
    return {
      "authorName": this.authorName,
      "authorUID": this.authorUID,
      "pUID": this.pUID,
      "thumbnail": this.thumbnail,
    };
  }

  set setThumbnail(String thumbnail) {
    this.thumbnail = thumbnail;
  }
}

class ProjectStub extends StatefulWidget {
  const ProjectStub(this.pUID, {Key? key}) : super(key: key);
  final String pUID;
  @override
  _ProjectStubState createState() => _ProjectStubState();
}

class _ProjectStubState extends State<ProjectStub> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(widget.pUID),
    );
  }
}
