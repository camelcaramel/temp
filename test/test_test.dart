import 'package:test/test.dart';

void main() {
  test("new Future.value() returns the value", () {
    expect(Future.delayed(Duration(seconds: 5), () => 10), completion(10));
  });
}