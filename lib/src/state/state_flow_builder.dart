import 'package:flutter/material.dart';
import '../state/state_flow.dart';

class StateFlowBuilder extends StatelessWidget {
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
  StatelessElement createElement() => _StateFlowBuilderElement(this);

  @override
  Widget build(BuildContext context) => builder(context);
}

class _StateFlowBuilderElement extends StatelessElement {
  _StateFlowBuilderElement(StateFlowBuilder widget) : super(widget);

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    (widget as StateFlowBuilder).onInit?.call();
    _addListeners();
  }

  @override
  void unmount() {
    _removeListeners();
    (widget as StateFlowBuilder).onDispose?.call();
    super.unmount();
  }

  void _addListeners() {
    for (var key in (widget as StateFlowBuilder).listenTo) {
      StateFlow().addListener(key, _update);
    }
  }

  void _removeListeners() {
    for (var key in (widget as StateFlowBuilder).listenTo) {
      StateFlow().removeListener(key, _update);
    }
  }

  void _update() {
    markNeedsBuild();
  }

  @override
  Widget build() {
    return (widget as StateFlowBuilder).builder(this);
  }
}
