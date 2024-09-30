import 'state_flow.dart';

class StateValue<T> {
  final String key;
  T _value;
  Object? _error;
  bool _isLoading = false;

  StateValue(this.key, T initialValue) : _value = initialValue {
    StateFlow().set(key, this);
  }

  T get value => _value;
  Object? get error => _error;
  bool get isLoading => _isLoading;

  set value(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      _error = null;
      _isLoading = false;
      StateFlow().notifyListeners(key);
    }
  }

  void setError(Object error) {
    _error = error;
    _isLoading = false;
    StateFlow().notifyListeners(key);
  }

  void setLoading() {
    _isLoading = true;
    _error = null;
    StateFlow().notifyListeners(key);
  }

  void dispose() {
    StateFlow().removeListener(key, _update);
  }

  void _update() {
    StateFlow().notifyListeners(key);
  }
}

StateValue<T> take<T>(T initialValue) {
  return StateValue<T>('state_${DateTime.now().millisecondsSinceEpoch}', initialValue);
}
