import 'package:flutter/material.dart';
import 'package:state_flow/state_flow.dart';

class StateValues {
  final List<dynamic> _values;
  const StateValues(this._values);
}

class StateValueBuilder<T> extends StatelessWidget {
  final dynamic value;
  final Widget Function(T) builder;

  const StateValueBuilder({
    super.key,
    required this.value,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (value is StateValue<T>) {
      return StateFlowBuilder(
        listenTo: [value.key],
        builder: (context) => builder(value.value as T),
      );
    } else if (value is T) {
      return builder(value);
    } else {
      throw ArgumentError('Value must be of type StateValue<T> or T');
    }
  }
}

// Helper function to create StateValues
StateValues $([
  dynamic a,
  dynamic b,
  dynamic c,
  dynamic d,
  dynamic e,
  dynamic f,
  dynamic g,
  dynamic h,
  dynamic i,
  dynamic j,
]) {
  return StateValues([a, b, c, d, e, f, g, h, i, j]
      .where((element) => element != null)
      .toList());
}

class WidgetStateValueBuilder<T> extends StatelessWidget {
  final StateValue<T> state;
  final Widget Function(T) dataBuilder;
  final Widget Function(Object) errorBuilder;
  final Widget Function() loadingBuilder;

  const WidgetStateValueBuilder({
    super.key,
    required this.state,
    required this.dataBuilder,
    required this.errorBuilder,
    required this.loadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StateFlowBuilder(
      listenTo: [state.key],
      builder: (context) {
        if (state.isLoading) {
          return loadingBuilder();
        } else if (state.error != null) {
          return errorBuilder(state.error!);
        } else {
          return dataBuilder(state.value);
        }
      },
    );
  }
}
