# Example Patterns

Use these examples when the user wants concrete `single_value_cubit` code. Prefer these over toy snippets that manually allocate cubits inside widget bodies.

These examples assume the app uses `injectable` for registration and `BlocProvider` for widget-tree access. Adapt the provider boundary to the local app structure, but keep the DI style consistent.

Keep each cubit in its own file under the feature's `bloc` or `cubit` directory.

## Generic single value cubit with injectable

### Cubit file:
```dart
import 'package:injectable/injectable.dart';
import 'package:single_value_cubit/single_value_cubit.dart';

@injectable
class SelectedTabCubit extends SingleValueCubit<int> {
  SelectedTabCubit() : super(0);
}
```

### Widget file:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/injection/injection.dart';
import 'package:my_app/**/cubit/selected_tab_cubit.dart';

class TabsPage extends StatelessWidget {
  const TabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SelectedTabCubit>(),
      child: BlocBuilder<SelectedTabCubit, int>(
        builder: (context, selectedTab) {
          return NavigationBar(
            selectedIndex: selectedTab,
            onDestinationSelected: context.read<SelectedTabCubit>().set,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
            ],
          );
        },
      ),
    );
  }
}
```

## Boolean toggle in a widget action

### Cubit file:
```dart
import 'package:injectable/injectable.dart';
import 'package:single_value_cubit/single_value_cubit.dart';

@injectable
class PasswordVisibilityCubit extends SingleValueCubit<bool> {
  PasswordVisibilityCubit() : super(true);
}
```

### Widget file:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/**/cubit/password_visibility_cubit.dart';

class PasswordField extends StatelessWidget {
  const PasswordField({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PasswordVisibilityCubit, bool>(
      builder: (context, obscured) {
        return TextField(
          obscureText: obscured,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: context.read<PasswordVisibilityCubit>().toggle,
              icon: Icon(
                obscured ? Icons.visibility : Icons.visibility_off,
              ),
            ),
          ),
        );
      },
    );
  }
}
```

## String input binding with TextCubitBinder

### Cubit file:
```dart
import 'package:injectable/injectable.dart';
import 'package:single_value_cubit/single_value_cubit.dart';

@injectable
class EmailInputCubit extends StringInputCubit {}
```

### Widget file:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmailField extends StatelessWidget {
  const EmailField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextCubitBinder(
      cubit: context.read<EmailInputCubit>(),
      builder: (context, controller) {
        return TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
          ),
        );
      },
    );
  }
}
```

## Clear text state from a UI action

```dart
IconButton(
  onPressed: context.read<EmailInputCubit>().erase,
  icon: const Icon(Icons.clear),
)
```

## Observe current state immediately

Use this when an existing cubit needs `state` first and then later updates.

```dart
import 'dart:async';

late final StreamSubscription<int> subscription;

@override
void initState() {
  super.initState();
  final counterCubit = context.read<CounterCubit>();
  subscription = counterCubit.observe().listen((value) {
    debugPrint('Counter value: $value');
  });
}

@override
void dispose() {
  subscription.cancel();
  super.dispose();
}
```

## Migrate a trivial Cubit to SingleValueCubit

Use this pattern when the old cubit only wraps one value and a setter.

Before:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class SearchQueryCubit extends Cubit<String> {
  SearchQueryCubit() : super('');

  void set(String value) => emit(value);
}
```

After:

```dart
import 'package:injectable/injectable.dart';
import 'package:single_value_cubit/single_value_cubit.dart';

@injectable
class SearchQueryCubit extends SingleValueCubit<String> {
  SearchQueryCubit() : super('');

  void setQuery(String value) => set(value);
}
```

If no callers need `setQuery`, simplify further:

```dart
import 'package:injectable/injectable.dart';
import 'package:single_value_cubit/single_value_cubit.dart';

@injectable
class SearchQueryCubit extends StringInputCubit {}
```

Keep the provider wiring the same:

```dart
BlocProvider(
  create: (_) => getIt<SearchQueryCubit>(),
  child: const SearchView(),
)
```

## Guidance

- Prefer a thin subclass when a name improves readability in the widget tree.
- If the project uses `injectable`, keep the annotation and resolve the cubit from the generated container.
- Keep every `SingleValueCubit` subclass in a dedicated file under `feature/bloc` or `feature/cubit`, not inside the widget file that consumes it.
- Prefer `context.read<T>()` for event handlers and one-time access.
- Prefer `BlocBuilder` or `BlocSelector` for rebuilds driven by cubit state.
- Only show direct cubit instantiation if the user explicitly asks for a minimal standalone example or for test code.