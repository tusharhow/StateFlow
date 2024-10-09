import 'package:flutter/material.dart';
import 'package:state_flow/state_flow.dart';

class StateValues {
  final List<dynamic> _values;
  const StateValues(this._values);
}

class StateValueBuilder extends StatelessWidget {
  final List<dynamic> values;
  final Widget Function(List<dynamic>) builder;

  const StateValueBuilder({
    super.key,
    required this.values,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    List<String> listenToKeys = values
        .whereType<StateValue>()
        .map((stateValue) => stateValue.key)
        .toList();

    return StateFlowBuilder(
      listenTo: listenToKeys,
      builder: (context) {
        List<dynamic> currentValues = values.map((value) {
          return value is StateValue ? value.value : value;
        }).toList();
        return builder(currentValues);
      },
    );
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
