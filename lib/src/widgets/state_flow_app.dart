import 'package:flutter/material.dart';
import '../core/service_locator.dart';
import '../core/state_flow_controller.dart';

class StateFlowApp extends StatelessWidget {
  final Widget child;
  final List<StateFlowController Function()> controllers;
  final ServiceLocator serviceLocator;

  StateFlowApp({
    super.key,
    required this.child,
    required this.controllers,
    ServiceLocator? serviceLocator,
  }) : serviceLocator = serviceLocator ?? ServiceLocator() {
    _setupDependencies();
  }

  void _setupDependencies() {
    for (final factory in controllers) {
      _registerController(factory);
    }
  }

  void _registerController(StateFlowController Function() factory) {
    final controller = factory();
    serviceLocator.register(controller.runtimeType, () {
      controller.onInit();
      return controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _StateFlowInheritedWidget(
      serviceLocator: serviceLocator,
      child: child,
    );
  }
}

class _StateFlowInheritedWidget extends InheritedWidget {
  final ServiceLocator serviceLocator;

  const _StateFlowInheritedWidget({
    super.key,
    required this.serviceLocator,
    required Widget child,
  }) : super(child: child);

  static _StateFlowInheritedWidget of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<_StateFlowInheritedWidget>();
    assert(result != null, 'No StateFlowInheritedWidget found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(_StateFlowInheritedWidget old) =>
      serviceLocator != old.serviceLocator;
}

extension StateFlowContextExtension on BuildContext {
  T listen<T>() {
    return _StateFlowInheritedWidget.of(this).serviceLocator.get<T>();
  }
}
