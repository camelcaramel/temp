import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stage4viscuit/class_file/presenter/MakeClassPresenter.dart';
import 'package:stage4viscuit/class_file/view/JoinClass.dart';
import 'package:stage4viscuit/class_file/view/MakeClass.dart';
import 'package:stage4viscuit/class_file/view/ViewClass.dart';
import 'package:stage4viscuit/projectData/projectData.dart';
import 'package:stage4viscuit/skatchbook/skatchBook.dart';
import 'package:stage4viscuit/userInfo/userInfo.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage(this.uid, {Key? key}) : super(key: key);
  final String uid;
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<ProjectCache> sharedProjects = []; // 공유된 프로젝트 정보들이 담기는 곳
  List<ProjectCache> myProjects = []; // 내가 진행한 프로젝트가 담기는 곳
  late UserData info; // 유저의 데이터를 저장하는 변수
  bool infoReady = false; // 유저의 정보가 준비됬는지 체크하는 변수
  bool isReady = false; // 모든 준비과 완료됬는지 체크하는 변수

  @override
  void initState() {
    // TODO: [디버그 코드] 유저의 uid가 제대로 들어왔는지 확인하는 코드
    print("profile page uid : ${widget.uid}");
    getUserData(); // 유저 데이터 받아와서 UserData info 를 초기화 한다
    //하는 김에 myProjects리스트 업데이트 까지
    initSharedProjectList(); // 공유 되는 프로젝트들의 리스트를 받아온다.
    //지금은 존재하는 모든 프로젝트를 가져온다.
    super.initState();
  }

  Map<String, dynamic> nullSaftyUserData(Map<String, dynamic>? data) {
    // 널값을 체크하고 널이면 에러 뱉는다.
    if (data != null) {
      return data;
    } else {
      throw ("error occured");
    }
  }

  void getUserData() {
    // 유저의 데이터를 받아온다.
    FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.uid.toString())
        .get()
        .then((value) {
      print("hey");
      setState(() {
        info = UserData.fromJson(nullSaftyUserData(value.data()));
        infoReady = true;
      });
      // 유저의 데이터를 다 받았으면 myProjectList를 초기화 한다.
      initProjectList();
    }).onError((error, stackTrace) {
      print("oh no");
      print(error);
    });
  }

  void initSharedProjectList() {
    FirebaseFirestore.instance.collection("ProjectCache").get().then((value) {
      setState(() {
        // firebase에서 불러온 프로젝트 캐시 정보들을 가져와서 프로젝트 리스트에 저장
        for (dynamic data in value.docs) {
          setState(() {
            sharedProjects.add(ProjectCache.fromJson(data));
          });
        }
      });
    });
  }

  void initProjectList() {
    // myProjectList 를 초기화 한다.
    FirebaseFirestore.instance
        .collection("Users")
        .doc(info.uid)
        .get()
        .then((value) {
      List<dynamic> projectList = value.data()?["projectList"];
      for (dynamic s in projectList) {
        FirebaseFirestore.instance
            .collection("ProjectCache")
            .doc(s.toString())
            .get()
            .then((value) {
          setState(() {
            // firebase에서 불러온 프로젝트 캐시 정보들을 가져와서 프로젝트 리스트에 저장
            myProjects.add(ProjectCache.fromJson(value.data()));
          });
        }).catchError((onError) {
          print("debug error \n $onError");
        });
      }
    }).catchError((onError) {
      // firebase 에서 지금 로그인한 유저가 만든 프로젝트를 가져오는 과정의 에러
      print("an error occure when get project list from firebase $onError");
    });
  }

  void makeProjectCache(String puid, ProjectData pdata) {
    // 프로젝트를 생성할 때 프로젝트 캐시 데이터를 함께 생성해서 파이어베이스에 보낸다.
    // 보내는 함수
    FirebaseFirestore.instance
        .collection("ProjectCache")
        .doc(puid)
        .set(new ProjectCache.fromProjectData(pdata.toMap()).toMap());
  }

  void addProjectList(String uid) {
    // 유저의 projectList에 새로운 데이터를 붙여서 다시 파이어베이스로 보낸다.
    FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.uid)
        .get()
        .then((value) {
      if (value.data() == null) {
        throw ("can't get user data from firebase in profile page make new project function");
      } else {
        Map<String, dynamic> data = value.data()! as Map<String, dynamic>;
        List<dynamic> projectList = data["projectList"];
        projectList.add(uid);
        FirebaseFirestore.instance
            .collection("Users")
            .doc(widget.uid)
            .update({"projectList": projectList});
      }
    }).catchError((onError) {
      print("what a errror $onError");
    });
  }

  void makeNewProject() {
    ProjectData projectData = new ProjectData(info);
    // firebase 에 프로젝트 초기화 정보 저장
    FirebaseFirestore.instance
        .collection("Projects")
        .add(projectData.toMap())
        .catchError((e) {
      print(
          "error occured on create new project in profilePage errorcode : \n $e");
    }).then((res) {
      // 설정된 uid를 다시 저장
      res.firestore
          .collection("Projects")
          .doc(res.id)
          .update({"pUID": res.id}).then((value) {
        // 찾아온 uid를 다시 설정하고 프로젝트 실행창(그림판..?)으로 넘김
        projectData.setProjectUID(res.id);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SkatchBook(projectData)));
        makeProjectCache(res.id, projectData);
      }).catchError((error) {
        // 프로젝트 *uid를 추가*하는 과정에서 에러가 발생한 경우에 처리
        print("error occure when create new projects");
      });
      addProjectList(res.id);
    }).catchError((onError) {
      // 프로젝트를 추가하는 과정에서 에러가 발생한 경우에 처리
      print("an error occure when create new project");
    });
  }

  Widget projectListItem(ProjectCache data, Color c) {
    // 리스트의 한 요소가 되는 위젯 생성
    // 각 프로젝트 하나를 보여주는 것이라 할 수 있겠다.
    return Container(
        width: 300,
        height: 300,
        child: TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProjectStub(data.pUID)));
            },
            child: data.thumbnail == "empty"
                ? Container(
                    child: Text(data.pUID),
                    decoration: BoxDecoration(border: Border.all(color: c)),
                  )
                : Image.memory(base64Decode(data.thumbnail))));
  }

  @override
  Widget build(BuildContext context) {
    if (infoReady)
      return Scaffold(
        appBar: AppBar(
          title: Text("profilePage ${info.getUID}"),
        ),
        floatingActionButton: FloatingActionButton(
            // project 만들기 버튼
            onPressed: () {
              makeNewProject();
            },
            child: Icon(Icons.plus_one)),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //새 클래스 제작
                Container(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MakeClass(info)),
                      );
                    },
                    child: Text('Make New Class!'),
                  ),
                ),
                //현재 유저 클래스 확인
                Container(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      /*
                      클래스 확인하는 화면
                      */
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewClass(info)),
                      );
                    },
                    child: Text('Your Class!'),
                  ),
                ),
                Container(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      /*
                      클래스 코드로 참여하는 화면
                      */
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => JoinClass(info)),
                      );
                    },
                    child: Text('Join Class To Code!'),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: 300,
                    child: Text("나의 프로젝트 리스트", textAlign: TextAlign.center)),
                SizedBox(width: 200),
                Container(
                    width: 300,
                    child: Text("공유된 프로젝트 리스트", textAlign: TextAlign.center))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                myProjects.isEmpty
                    ? Container()
                    : Container(
                        // 내가 지금까지 만든 프로젝트 리스트 디스플레이
                        height: 600,
                        width: 300,
                        child: ListView.builder(
                            itemCount: myProjects.length,
                            itemBuilder: (context, index) {
                              return projectListItem(
                                  myProjects[index], Colors.black);
                            }),
                      ),
                SizedBox(
                  width: 200,
                ),
                sharedProjects.isEmpty
                    ? Container()
                    : Container(
                        height: 600,
                        width: 300,
                        child: ListView.builder(
                            itemCount: sharedProjects.length,
                            itemBuilder: (context, index) {
                              return projectListItem(
                                  sharedProjects[index], Colors.red);
                            }),
                      )
              ],
            )
          ],
        ),
      );
    else
      return CircularProgressIndicator();
  }
}
