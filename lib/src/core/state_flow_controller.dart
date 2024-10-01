import '../state/state_value.dart';

abstract class StateFlowController {
  final Map<String, StateValue> _states = {};

  StateValue<T> take<T>(T initialValue) {
    final key = '${runtimeType}_${_states.length}';
    final stateValue = StateValue<T>(key, initialValue);
    _states[key] = stateValue;
    return stateValue;
  }

  void onInit() {}

  Map<String, StateValue> get states => _states;
}
