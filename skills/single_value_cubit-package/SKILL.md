---
name: single_value_cubit-package
description: "Use this skill when the user wants to use the single_value_cubit package, wire simple Flutter state with a Cubit, bind text fields to cubits, toggle boolean state with toggle(), clear string state with erase(), increment or decrement integer state with increment()/decrement(), use StringInputCubit for text inputs, use IntValueCubit for integer counters or quantities, observe a Bloc/Cubit stream with the current value emitted immediately via observe(), or use SingleValueBoolCubitExtension/SingleValueStringCubitExtension/SingleValueIntCubitExtension. Trigger this whenever the task involves lightweight single-value state such as inputs, flags, counters, quantities, scroll positions, filters, or replacing ad hoc ValueNotifier or basic Cubit boilerplate with single_value_cubit. MUST trigger for any question about StringInputCubit, IntValueCubit, SingleValueCubit, single value cubit."
---

# Single Value Cubit

Use this skill to implement simple, single-purpose Flutter state with the `single_value_cubit` package.

The package is intentionally small. Prefer it when the state is one value and the behavior is simple. If the user needs validation state, async loading, multiple fields with cross-field rules, or a richer domain model, use a regular `Cubit` or `Bloc` instead.

Assume the cubit is usually obtained through the app's existing dependency injection and `BuildContext` access patterns. If the project uses `injectable`, prefer examples that preserve `@injectable` registration and resolve cubits through the generated container. `SingleValueCubit` types should still be treated as real cubits: place them in a separate file under the relevant `feature/cubit` directory rather than declaring them inline in page files. Do not default to examples that instantiate cubits inline inside pages unless the user explicitly asks for a minimal standalone sample.

## What the package provides

- `SingleValueCubit<T>`: a `Cubit<T>` with a `set(T value)` method.
- `SingleValueBoolCubitExtension.toggle()`: flips a `SingleValueCubit<bool>`.
- `SingleValueStringCubitExtension.erase()`: clears a `SingleValueCubit<String>` to an empty string.
- `SingleValueIntCubitExtension.increment()` / `.decrement()`: steps a `SingleValueCubit<int>` up or down by 1.
- `BlocExtensions.observe()`: emits the current `state` immediately, then future stream updates.
- `StringInputCubit`: a `SingleValueCubit<String>` initialized with `''`.
- `IntValueCubit`: a `SingleValueCubit<int>` initialized with `0`.
- `TextCubitBinder`: two-way binding between a `SingleValueCubit<String>` and a `TextEditingController`.
- `GenericTextCubitBinder<T>`: two-way binding for arbitrary state types where only part of the state is a text field. Requires `getInputCallback` to extract the text and `updateValue` to merge edits back into the state.

## Workflow

Follow this sequence when helping with `single_value_cubit` tasks.

1. Identify whether the state really is a single value.
2. Choose the smallest fitting API from the package.
3. Keep the cubit focused on state storage and trivial state transitions.
4. Bind UI directly only when it improves clarity, especially for text fields.
5. Avoid introducing custom abstractions unless the user actually needs them.
6. Prefer realistic usage examples that read cubits from `context.read<T>()`, `BlocBuilder`, `BlocSelector`, or an existing injection boundary.
7. If the app uses `injectable`, preserve that setup instead of replacing it with ad hoc local construction.
8. Keep each cubit in its own file under the feature's `bloc` or `cubit` folder, even when the implementation is only a thin `SingleValueCubit<T>` subclass.

## Choose the right type

Use these defaults:

- For booleans, enums, offsets, IDs, filters, selected tabs, and other one-value state: use `SingleValueCubit<T>`.
- For text input with an empty default: use `StringInputCubit`.
- For integer counters or quantities starting from 0: use `IntValueCubit`.
- For a text field that must stay synchronized with cubit state in both directions when the full state is a `String`: use `TextCubitBinder`.
- For a text field bound to a cubit whose state is a composite type (e.g., a model with a name field): use `GenericTextCubitBinder<T>` with `getInputCallback` and `updateValue`.
- For reacting to the current value plus future changes from a `BlocBase`: use `observe()`.

Avoid this package when:

- The state has multiple related fields.
- Transitions depend on business rules beyond a simple set, toggle, or erase.
- The user needs status objects like loading, success, and error.
- Validation or submission logic would make the cubit more than a thin state holder.

## Core patterns

For copy-pasteable examples, read `references/examples.md` and prefer the variant that matches the user's widget tree and injection style. Default to the `injectable`-style examples when the project uses generated DI.

When generating project code, assume a feature-based architecture. The codebase structure may vary, but generally assume one of these patterns:
- `lib/feature/presentation/bloc/` or `lib/feature/presentation/cubit/`;
- `lib/presentation/feature/bloc/` or `lib/presentation/feature/cubit/`.

### Generic single value state

Use `SingleValueCubit<T>` when the user needs a tiny cubit with a setter.
Prefer dedicated types for readability - subclass without adding unnecessary logic:

```dart
class SelectedTabCubit extends SingleValueCubit<int> {
  SelectedTabCubit() : super(0);
}
```

### Boolean toggles — `SingleValueBoolCubitExtension`

`SingleValueBoolCubitExtension` is automatically available on any `SingleValueCubit<bool>`. Prefer the built-in `toggle()` extension instead of hand-writing a toggle method.

Show it in realistic usage, for example by calling `context.read<PasswordVisibilityCubit>().toggle` from a button `onPressed` handler. Point out that `toggle` can be passed by reference (no parentheses) directly as a callback.

### String clearing — `SingleValueStringCubitExtension`

`SingleValueStringCubitExtension` is automatically available on any `SingleValueCubit<String>`. Prefer `erase()` when the user wants reset-to-empty behavior.

Show it in realistic usage, for example by calling `context.read<SearchQueryCubit>().erase` from a clear/reset action. Like `toggle`, `erase` can be passed by reference as a callback.

### Integer stepping — `SingleValueIntCubitExtension`

`SingleValueIntCubitExtension` is automatically available on any `SingleValueCubit<int>`. Prefer the built-in `increment()` and `decrement()` over hand-writing step methods.

Show them in realistic usage, for example wiring stepper buttons (`+` / `-`) to `context.read<QuantityCubit>().increment` and `context.read<QuantityCubit>().decrement`. Both can be passed by reference directly as `onPressed` callbacks.

### `IntValueCubit` — integer counter with zero default

`IntValueCubit` is a convenience subclass of `SingleValueCubit<int>` that starts with `0`. Use it directly or subclass it when the initial value is always zero:

```dart
class CartItemCountCubit extends IntValueCubit {}
```

For counters with a non-zero starting value, subclass `SingleValueCubit<int>` directly.

### `StringInputCubit` — text input with empty default

`StringInputCubit` is a convenience subclass of `SingleValueCubit<String>` that starts with `''`. Use it directly or subclass it when the initial state is always an empty string:

```dart
class SearchQueryCubit extends StringInputCubit {}
```

Do not define a `StringInputCubit` subclass that only adds a constructor if the parent already supplies the empty-string default — the naked subclass is enough.

### Observe current state and future updates

Use `observe()` when a consumer needs behavior similar to a `BehaviorSubject`, meaning it should receive the current state immediately instead of waiting for the next emission.

Prefer examples where the bloc or cubit comes from an existing provider or injected dependency, not from local one-off construction.

### Text input binding

Use `TextCubitBinder` when the UI needs a `TextEditingController` that stays synchronized with a `SingleValueCubit<String>`.

```dart
class LoginInputCubit extends StringInputCubit {}

class LoginField extends StatelessWidget {
  const LoginField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextCubitBinder(
      cubit: context.read<LoginInputCubit>(),
      builder: (context, controller) {
        return TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Login'),
        );
      },
    );
  }
}
```

Explain the binding clearly when relevant:

- User typing updates the cubit.
- Cubit updates also update the text controller.
- The widget avoids feedback loops by temporarily removing the listener before setting controller text.

## Implementation rules

When generating or editing code that uses this package, follow these rules:

- Keep cubit classes tiny. A named subclass is desired for semantics, but do not add boilerplate without a reason.
- Use `set(...)` for direct replacement of state.
- Use `toggle()` and `erase()` where they match the use case.
- Inject cubits with the app's existing `BlocProvider` or dependency pattern instead of inventing a new one.
- If the codebase uses `injectable`, keep the existing `@injectable` or related annotations on migrated cubits and resolve them through the established container.
- Put each cubit class in its own file under the relevant `feature/cubit` directory, even if the class body is only a constructor.
- Prefer examples that access cubits through `context.read`, `context.watch`, `BlocBuilder`, `BlocSelector`, or constructor-injected dependencies.
- Avoid examples like `final emailCubit = StringInputCubit();` unless the user explicitly asks for the smallest runnable demo.
- Preserve the surrounding codebase's `flutter_bloc` conventions.
- Prefer explicit types.

## Common requests and responses

### Replace a trivial Cubit class

If the user has a cubit that only stores one value and exposes a single setter, replace it with `SingleValueCubit<T>` or a thin subclass.

Before:

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void setCount(int value) => emit(value);
}
```

After:

```dart
class CounterCubit extends SingleValueCubit<int> {
  CounterCubit() : super(0);
}
```

If the project uses `injectable`, preserve registration during the migration. Read `references/examples.md` for an annotated migration example.

### Add local UI state

For state like password visibility, selected index, or current filter, prefer a `SingleValueCubit<T>` over a larger state object.

Present it as UI-facing state that is still provided through the existing dependency graph, not as random local variables inside widgets.

### Build a text input cubit

If the initial value is empty and the cubit is only for text, default to `StringInputCubit`.

### React to the current bloc value immediately

If the user wants stream-like observation but also needs the current state on subscription, use `observe()` instead of raw `stream`.

## Migration guidance

When migrating from a trivial `Cubit<T>` to `SingleValueCubit<T>`, preserve the surrounding architecture.

- Keep the same class name unless the user wants a rename.
- Keep `@injectable` and any existing DI scope annotations.
- Keep the same provider boundary and retrieval style.
- Keep the cubit in its own file under `feature/cubit` rather than moving it into a page file.
- Collapse one-off setter methods into `set(...)` only if that does not hurt readability at call sites.
- If external code already calls a semantic wrapper like `setQuery`, keep that wrapper only when it carries meaning or protects API stability.
- Do not migrate cubits that already contain validation, derived state, or side effects.

For migration code samples, use the annotated examples in `references/examples.md`.

## Review checklist

Before finishing, verify these points:

- The chosen state is actually a single value.
- The generic type matches the UI or domain need.
- Any text field binding uses `SingleValueCubit<String>`.
- Code does not reimplement functionality already provided by `toggle()`, `erase()`, or `observe()`.
- Existing `injectable` registration or provider wiring remains intact after any migration.
- Each cubit class still lives in a dedicated file under the feature's `bloc` or `cubit` directory.
- The solution does not force `single_value_cubit` into places where a richer state model is the better design.

## Output expectations

When answering with this skill, produce code that is directly usable in a Flutter app and explain only the package-specific decisions that matter:

- why `SingleValueCubit<T>` is enough,
- why a specific helper like `StringInputCubit` or `TextCubitBinder` is appropriate,
- and where the package should not be used.

If examples are needed, prefer realistic app code over toy snippets. Favor `BlocProvider` setup, `context.read<T>()`, and widget integration patterns that match production Flutter code.

If the repo uses `injectable`, reflect that directly in the examples instead of falling back to manual cubit construction.

When showing file organization, place each cubit in its own file inside the feature's `bloc` or `cubit` directory, and place feature pages directly in the feature folder.