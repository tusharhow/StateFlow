import 'package:flutter/material.dart';
import 'package:state_flow/state_flow.dart';

class StateValueBuilder<T> extends StatelessWidget {
  final StateValue<T> value;
  final Widget Function(T) builder;

  const StateValueBuilder({
    super.key,
    required this.value,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return StateFlowBuilder(
      listenTo: [value.key],
      builder: (context) {
        return builder(value.value);
      },
    );
  }
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
