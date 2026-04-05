import 'package:flutter_bloc/flutter_bloc.dart';

class TabNavigationCubit extends Cubit<int> {
  TabNavigationCubit() : super(0);

  void setTab(int index) => emit(index);

  void navigateByPayload(String payload) {
    switch (payload) {
      case 'home':
        emit(0);
        break;
      case 'transactions':
        emit(1);
        break;
      case 'goals':
        emit(2);
        break;
      case 'insights':
        emit(3);
        break;
      case 'profile':
        emit(4);
        break;
    }
  }
}
