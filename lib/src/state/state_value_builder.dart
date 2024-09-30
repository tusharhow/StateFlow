import 'package:flutter/material.dart';
import '../state/state_value.dart';
import 'state_flow_builder.dart';

class StateValueBuilder<T> extends StatelessWidget {
  final StateValue<T> value;
  final Widget Function(BuildContext, T?) builder;
  final Widget Function(BuildContext, Object)? errorBuilder;
  final Widget Function(BuildContext)? loadingBuilder;

  const StateValueBuilder({
    super.key,
    required this.value,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StateFlowBuilder(
      listenTo: [value.key],
      builder: (context) {
        if (value.isLoading && loadingBuilder != null) {
          return loadingBuilder!(context);
        } else if (value.error != null && errorBuilder != null) {
          return errorBuilder!(context, value.error!);
        } else {
          return builder(context, value.value);
        }
      },
    );
  }
}

class WidgetStateValueBuilder extends StatelessWidget {
  final StateValue state;
  final Widget Function(BuildContext, dynamic) builder;
  final Widget Function(BuildContext, Object)? errorBuilder;
  final Widget Function(BuildContext)? loadingBuilder;

  const WidgetStateValueBuilder({
    super.key,
    required this.state,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StateFlowBuilder(
      listenTo: [state.key],
      builder: (context) {
        if (state.isLoading && loadingBuilder != null) {
          return loadingBuilder!(context);
        } else if (state.error != null && errorBuilder != null) {
          return errorBuilder!(context, state.error!);
        } else {
          return builder(context, state.value);
        }
      },
    );
  }
}