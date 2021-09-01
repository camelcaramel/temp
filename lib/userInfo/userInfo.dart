import 'package:flutter/foundation.dart';

class UserData {
  final String uid;
  final String name;
  final String userEmail;
  final String category;

  UserData(String uid, String name, String category, String userEmail)
      : this.uid = uid,
        this.name = name,
        this.userEmail = userEmail,
        this.category = category;

  UserData.fromJson(Map<String, dynamic> data)
      : this(data['uid'], data['name'], data['category'], data['email']);

  get getName => this.name;
  get getUID => this.uid;
}
