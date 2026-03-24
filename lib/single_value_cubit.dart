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

/// let you quickly change int single value cubits
extension SingleValueIntCubitExtension on SingleValueCubit<int> {
  /// increments the current state by 1
  void increment() {
    set(state + 1);
  }

  /// decrements the current state by 1
  void decrement() {
    set(state - 1);
  }
}

/// Single value cubit designed to work with integer counters and quantities
class IntValueCubit extends SingleValueCubit<int> {
  /// Creates an IntValueCubit with an initial value of 0.
  IntValueCubit() : super(0);
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
  late final void Function() _listener;

  @override
  void initState() {
    super.initState();

    final value = widget.cubit.state;
    if (value != _controller.text) _controller.text = value;

    _listener = () => widget.cubit.set(_controller.text);
    _controller.addListener(_listener);
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
          _controller
            ..removeListener(_listener)
            ..text = state
            ..addListener(_listener);
        }
      },
      builder: (ctx, state) => widget.builder(ctx, _controller),
    );
  }
}

/// A widget that binds a [SingleValueCubit<T>] to a [TextEditingController]
/// for state types that contain a text component alongside other data.
///
/// Unlike [TextCubitBinder], which works only with `SingleValueCubit<String>`,
/// this widget accepts arbitrary state types. Use [getInputCallback] to extract
/// the text portion from the state and [updateValue] to merge edited text back
/// into the state before emitting it.
///
/// If [cubit] is not provided, the nearest [SingleValueCubit<T>] ancestor from
/// the widget tree is used via [BlocProvider].
class GenericTextCubitBinder<T> extends StatefulWidget {
  /// Creates a [GenericTextCubitBinder].
  const GenericTextCubitBinder({
    required this.builder,
    required this.getInputCallback,
    required this.updateValue,
    super.key,
    this.cubit,
  });

  /// Optional cubit to bind to. When omitted, the nearest
  /// [SingleValueCubit<T>] in the widget tree is used.
  final SingleValueCubit<T>? cubit;

  /// Builder function that receives the [TextEditingController] bound to
  /// the cubit's text component.
  final Widget Function(BuildContext context, TextEditingController controller)
      builder;

  /// Extracts the text value from the current cubit state.
  /// Called to initialise the controller and to detect state changes
  /// that require a controller update.
  final String Function(T value) getInputCallback;

  /// Merges the edited [text] back into the current cubit [value], returning
  /// the new state to emit. Called on every controller change.
  final T Function(T value, String text) updateValue;

  @override
  State<GenericTextCubitBinder<T>> createState() =>
      _GenericTextCubitBinderState<T>();
}

class _GenericTextCubitBinderState<T> extends State<GenericTextCubitBinder<T>> {
  late TextEditingController _controller;

  late final void Function() _listener;
  late final SingleValueCubit<T> _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = _getCubit();
    _controller = TextEditingController();

    final value = widget.getInputCallback(_cubit.state);
    if (value != _controller.text) {
      _controller.text = value;
    }
    _listener = () => _cubit.set(
          widget.updateValue(_cubit.state, _controller.text),
        );
    _controller.addListener(_listener);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SingleValueCubit<T>, T>(
      listenWhen: (previous, current) {
        final previousValue = widget.getInputCallback(previous);
        final newValue = widget.getInputCallback(current);

        return previousValue != newValue;
      },
      bloc: _cubit,
      listener: (context, state) {
        final value = widget.getInputCallback(state);
        if (value != _controller.text) {
          _controller
            ..removeListener(_listener)
            ..text = value
            ..addListener(_listener);
        }
      },
      child: Builder(
        builder: (context) => widget.builder(context, _controller),
      ),
    );
  }

  SingleValueCubit<T> _getCubit() {
    return widget.cubit ?? BlocProvider.of<SingleValueCubit<T>>(context);
  }
}
