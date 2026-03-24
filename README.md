## Single value cubit

Just a simple cubit with a state setter.
Helpful with inputs, scrolls and single flags scenarios.

## Enum state

`SingleValueCubit<T>` works with any type, including enums. Use it for things like selected tabs, filters, sort order, or theme mode:

```dart
enum SortOrder { ascending, descending }

class SortOrderCubit extends SingleValueCubit<SortOrder> {
  SortOrderCubit() : super(SortOrder.ascending);
}

// inside a widget
BlocBuilder<SortOrderCubit, SortOrder>(
  builder: (context, order) {
    return IconButton(
      icon: Icon(
        order == SortOrder.ascending ? Icons.arrow_upward : Icons.arrow_downward,
      ),
      onPressed: () => context.read<SortOrderCubit>().set(
        order == SortOrder.ascending ? SortOrder.descending : SortOrder.ascending,
      ),
    );
  },
)
```

## StringInputCubit

`StringInputCubit` is a convenience subclass of `SingleValueCubit<String>` initialized with an empty string. Use it as a base class whenever the state is a text input starting from `''`:

```dart
class SearchQueryCubit extends StringInputCubit {}
```

## Bool Extension

`SingleValueBoolCubitExtension` adds a `toggle()` method to any `SingleValueCubit<bool>`, flipping the current state:

```dart
class PasswordVisibilityCubit extends SingleValueCubit<bool> {
  PasswordVisibilityCubit() : super(true);
}

// inside a widget
onPressed: context.read<PasswordVisibilityCubit>().toggle,
```

## String Extension

`SingleValueStringCubitExtension` adds an `erase()` method to any `SingleValueCubit<String>`, resetting the state to `''`:

```dart
class SearchQueryCubit extends SingleValueCubit<String> {
  SearchQueryCubit() : super('');
}

// inside a widget
onPressed: context.read<SearchQueryCubit>().erase,
```

## TextCubitBinder Example

The `TextCubitBinder` widget provides two-way binding between a `SingleValueCubit<String>` and a `TextEditingController`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:single_value_cubit/single_value_cubit.dart';

class LoginInputCubit extends SingleValueCubit<String> {
  LoginInputCubit() : super('');
}

class MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginInputCubit(),
      child: Builder(
        builder: (context) {
          return TextCubitBinder(
            cubit: context.read<LoginInputCubit>(),
            builder: (context, controller) {
              return TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Login',
                  hintText: 'Enter your login',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

The binding works both ways:
- Changes in the `TextField` automatically update the cubit state
- Changes to the cubit (e.g., `context.read<LoginInputCubit>().set('john_doe')`) automatically update the text field
