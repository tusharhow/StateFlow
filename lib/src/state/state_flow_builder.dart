import 'package:flutter/material.dart';
import 'state_flow.dart';

class StateFlowBuilder extends StatefulWidget {
  final Widget Function(BuildContext) builder;
  final List<String> listenTo;
  final void Function()? onInit;
  final void Function()? onDispose;

  const StateFlowBuilder({
    super.key,
    required this.builder,
    this.listenTo = const [],
    this.onInit,
    this.onDispose,
  });

  @override
  _StateFlowBuilderState createState() => _StateFlowBuilderState();
}

class _StateFlowBuilderState extends State<StateFlowBuilder> {
  @override
  void initState() {
    super.initState();
    widget.onInit?.call();
    _addListeners();
  }

  @override
  void didUpdateWidget(StateFlowBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.listenTo != oldWidget.listenTo) {
      _removeListeners(oldWidget.listenTo);
      _addListeners();
    }
  }

  @override
  void dispose() {
    _removeListeners(widget.listenTo);
    widget.onDispose?.call();
    super.dispose();
  }

  void _addListeners() {
    for (var key in widget.listenTo) {
      StateFlow().addListener(key, _handleStateChange);
    }
  }

  void _removeListeners(List<String> keys) {
    for (var key in keys) {
      StateFlow().removeListener(key, _handleStateChange);
    }
  }

  void _handleStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
