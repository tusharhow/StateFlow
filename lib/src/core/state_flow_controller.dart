import '../state/state_value.dart';

abstract class StateFlowController {
  final Map<String, StateValue> _states = {};

  StateValue<T> take<T>(T initialValue) {
    final key = '${runtimeType}_${_states.length}';
    return _states.putIfAbsent(key, () => StateValue<T>(key, initialValue))
        as StateValue<T>;
  }

  void onInit() {}

  void dispose() {
    onDispose();
    for (var state in _states.values) {
      state.dispose();
    }
    _states.clear();
  }

  void onDispose() {}

  Map<String, StateValue> get states => _states;
}
