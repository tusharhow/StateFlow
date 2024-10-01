import 'package:flutter/foundation.dart';
import 'dart:collection';

class StateFlow {
  static final StateFlow instance = StateFlow._internal();

  factory StateFlow() => instance;

  StateFlow._internal();

  final Map<String, dynamic> _state = {};
  final Map<String, LinkedHashSet<VoidCallback>> _listeners = {};

  T? get<T>(String key) => _state[key] as T?;

  void set<T>(String key, T value) {
    _state[key] = value;
    notifyListeners(key);
  }

  void addListener(String key, VoidCallback listener) {
    _listeners.putIfAbsent(key, () => LinkedHashSet<VoidCallback>()).add(listener);
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
}
