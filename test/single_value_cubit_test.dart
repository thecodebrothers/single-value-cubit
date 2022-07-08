import 'package:flutter_test/flutter_test.dart';

import 'package:single_value_cubit/single_value_cubit.dart';

void main() {
  test('default value is emited initialy', () {
    const defaultValue = 'test';
    final cubit = SingleValueCubit(defaultValue);

    expect(cubit.state, defaultValue);
  });

  test('emits new value after set', () {
    const defaultValue = 'test';
    const emitValue = 'newValue';
    final cubit = SingleValueCubit(defaultValue)..set(emitValue);

    expect(cubit.state, emitValue);
  });
}
