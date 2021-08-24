import '../view_model/view_model_interface.dart';

typedef VoidCallback = void Function();

abstract class View {
  void refresh({required ViewModel viewModel});
  void afterBuild(_);
  // View의 initState에서 presenter가 해당 View의 참조를 가지는 순간이 아닌
  // 첫번째 build가 완료되어야 대응되는 ViewAccessible이 완료된다.
  // 이는 ScrollController(정확히는 ScrollPosition)와 같이
  // 빌드된 위젯에 attach되어야 사용될 수 있는 객체를 presenter 내에서
  // 사용할 수 있기 때문이다.
  bool isFirstBuildDone = false;
}

/*
// 화면에서 제거되거나 삽입될 수 있는 View
abstract class DetachableView extends View {

}

 */