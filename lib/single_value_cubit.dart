library single_value_cubit;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

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

/// let you quickly change bool single value cubits
extension SingleValueBoolCubitExtension on SingleValueCubit<bool> {
  /// toggles the current state of a cubit
  void toggle() {
    set(!state);
  }
}

/// let you quickly change String single value cubits
extension SingleValueStringCubitExtension on SingleValueCubit<String> {
  /// clears the current state of a cubit
  void erase() {
    set('');
  }
}

/// Bloc extensions
extension BlocExtensions<T> on BlocBase<T> {
  /// let you observe the state of a bloc or cubit
  /// with immediate emission of current state
  /// works similar to [BehaviorSubject] observation
  Stream<T> observe() => stream.startWith(state);
}

/// Single value cubit designed to work with text inputs
class StringInputCubit extends SingleValueCubit<String> {
  /// Creates a StringInputCubit with an initial empty string.
  StringInputCubit() : super('');
}

/// A widget that binds a [SingleValueCubit<String>]
/// to a [TextEditingController]. Two way binding
class TextCubitBinder extends StatefulWidget {
  /// Creates a [TextCubitBinder] that binds a [SingleValueCubit<String>]
  const TextCubitBinder({
    required this.builder,
    required this.cubit,
    super.key,
  });

  /// Cubit that will be bind to the text input.
  final SingleValueCubit<String> cubit;

  /// Builder function that gives [TextEditingController] bound to the cubit.
  final Widget Function(BuildContext context, TextEditingController controller)
      builder;

  @override
  State<TextCubitBinder> createState() => _TextCubitBinderState();
}

class _TextCubitBinderState extends State<TextCubitBinder> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    final value = widget.cubit.state;
    if (value != _controller.text) _controller.text = value;

    _controller.addListener(() => widget.cubit.set(_controller.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SingleValueCubit<String>, String>(
      bloc: widget.cubit,
      listener: (_, state) {
        if (state != _controller.text) {
          _controller.text = state;
        }
      },
      builder: (ctx, state) => widget.builder(ctx, _controller),
    );
  }
}
