class UserInfo {
  final String uid;
  final String name;

  UserInfo(String uid, String name)
      : this.uid = uid,
        this.name = name;

  get getName => this.name;
  get getUID => this.uid;
}
