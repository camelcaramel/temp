import 'dart:async';

void main() {
  print("a");
  Future(() {
    print("before lots of cost operation");
    for(int i = 0; i< 10000000000; i++) i = i;
  }).then((_) => print("1"));
  print("b");
  Future(() {
    return Future.delayed(Duration(seconds: 5));
  }).then((_) => print("3"));
  print("c");
}