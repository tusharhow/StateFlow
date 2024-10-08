import 'package:flutter/widgets.dart';

abstract class StateFlowWidget extends StatelessWidget {
  const StateFlowWidget({super.key});

  @protected
  void onInit(BuildContext? context) {}

  @protected
  void onDispose() {}

  @override
  StatelessElement createElement() => _StateFlowElement(this);

  @override
  Widget build(BuildContext context);
}

class _StateFlowElement extends StatelessElement {
  _StateFlowElement(StateFlowWidget widget) : super(widget);

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    (widget as StateFlowWidget).onInit(this);
  }

  @override
  void unmount() {
    (widget as StateFlowWidget).onDispose();
    super.unmount();
  }
}
