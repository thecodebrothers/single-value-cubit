## Single value cubit

Just a simple cubit with a state setter.
Helpful with inputs, scrolls and single flags scenarios.

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
