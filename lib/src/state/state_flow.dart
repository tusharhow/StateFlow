import 'dart:collection';
import 'package:flutter/material.dart';
import '../navigation/state_flow_navigation.dart';

class StateFlow {
  static final StateFlow _instance = StateFlow._internal();
  factory StateFlow() => _instance;

  StateFlow._internal();

  final Map<String, dynamic> _state = {};
  final Map<String, LinkedHashSet<VoidCallback>> _listeners = {};

  T? get<T>(String key) => _state[key] as T?;

  void set<T>(String key, T value) {
    _state[key] = value;
    notifyListeners(key);
  }

  void addListener(String key, VoidCallback listener) {
    _listeners
        .putIfAbsent(key, () => LinkedHashSet<VoidCallback>())
        .add(listener);
  }

  void removeListener(String key, VoidCallback listener) {
    _listeners[key]?.remove(listener);
    if (_listeners[key]?.isEmpty ?? false) {
      _listeners.remove(key);
    }
  }

  void notifyListeners(String key) {
    _listeners[key]?.toList().forEach((listener) => listener());
  }

  void dispose() {
    _listeners.clear();
    _state.clear();
  }

 
  // Navigation methods
  static Future<T?> to<T extends Object?>(dynamic route, {Object? arguments}) =>
      StateFlowNavigation.to<T>(route, arguments: arguments);

  static void back<T extends Object?>([T? result]) =>
      StateFlowNavigation.back(result);

  static Future<T?> off<T extends Object?>(dynamic route, {Object? arguments}) =>
      StateFlowNavigation.off<T>(route, arguments: arguments);

  static Future<T?> offAll<T extends Object?>(dynamic route, {Object? arguments}) =>
      StateFlowNavigation.offAll<T>(route, arguments: arguments);

  static bool canPop() => StateFlowNavigation.canPop();

  static Future<bool> maybePop<T extends Object?>([T? result]) =>
      StateFlowNavigation.maybePop(result);

  static String? currentRoute() => StateFlowNavigation.currentRoute();

  static List<String> getHistory() => StateFlowNavigation.getHistory();

  // Exposong navigatorKey through StateFlow
  static GlobalKey<NavigatorState> get navigatorKey => StateFlowNavigation.navigatorKey;

  // Exposing onGenerateRoute through StateFlow
  static Route<dynamic> onGenerateRoute(RouteSettings settings) =>
      StateFlowNavigation.onGenerateRoute(settings);
}
