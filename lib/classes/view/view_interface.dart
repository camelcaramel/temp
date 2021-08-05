import '../view_model/view_model_interface.dart';

abstract class View {
  void refresh({required ViewModel viewModel});
}