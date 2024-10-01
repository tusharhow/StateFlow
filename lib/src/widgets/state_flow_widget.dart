import 'package:flutter/material.dart';

abstract class StateFlowWidget extends StatelessWidget {
  final void Function(BuildContext context)? onInit;
  final VoidCallback? onDispose;

  const StateFlowWidget({
    super.key,
    this.onInit,
    this.onDispose,
  });

  @override
  StatelessElement createElement() => _LifecycleElement(this);

  @override
  Widget build(BuildContext context);
}

class _LifecycleElement extends StatelessElement {
  _LifecycleElement(StateFlowWidget widget) : super(widget);

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    final widget = this.widget as StateFlowWidget;
    if (widget.onInit != null) {
      widget.onInit!(this);
    }
  }

  @override
  void unmount() {
    final widget = this.widget as StateFlowWidget;
    if (widget.onDispose != null) {
      widget.onDispose!();
    }
    super.unmount();
  }
}
