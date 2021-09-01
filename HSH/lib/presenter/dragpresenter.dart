class DragWidgetPresenter {
  DragWidgetPresenter();

  double left = 1;
  double top = 1;

  double call_left() {
    return left;
  }

  double call_top() {
    return top;
  }

  void set_movement(String data) {
    left = double.parse(data.split(':')[0]);
    top = double.parse(data.split(':')[1]);
  }
}
