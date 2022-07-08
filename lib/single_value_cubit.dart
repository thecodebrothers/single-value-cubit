library single_value_cubit;

import 'package:bloc/bloc.dart';

/// Single value cubit - just a simple cubit with set method wich changes
/// the current state. Helpful with simple input, scroll, bool and many other
/// scenarios
class SingleValueCubit<T> extends Cubit<T> {
  /// create a cubit with initial value
  SingleValueCubit(super.initialState);

  /// sets the value of a cubit
  void set(T value) {
    emit(value);
  }
}
