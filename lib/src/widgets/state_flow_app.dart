import 'package:flutter/material.dart';
import '../core/service_locator.dart';
import '../core/state_flow_controller.dart';

class StateFlowApp extends StatelessWidget {
  final List<Function> controllers;
  final Widget child;

  StateFlowApp({
    super.key,
    required this.controllers,
    required this.child,
  }) {
    _registerControllers();
  }

  void _registerControllers() {
    for (var controllerFactory in controllers) {
      final controller = controllerFactory();
      globalServiceLocator.register(() => controller,
          type: controller.runtimeType);
      (controller as StateFlowController).onInit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _StateFlowInheritedWidget(
      serviceLocator: globalServiceLocator,
      child: child,
    );
  }
}

class _StateFlowInheritedWidget extends InheritedWidget {
  final ServiceLocator serviceLocator;

  const _StateFlowInheritedWidget({
    required this.serviceLocator,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(_StateFlowInheritedWidget oldWidget) {
    return serviceLocator != oldWidget.serviceLocator;
  }

  static _StateFlowInheritedWidget of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<_StateFlowInheritedWidget>();
    assert(result != null, 'No _StateFlowInheritedWidget found in context');
    return result!;
  }
}

extension StateFlowContextExtension on BuildContext {
  T listen<T>(Type type) {
    return _StateFlowInheritedWidget.of(this).serviceLocator.get<T>();
  }
}
