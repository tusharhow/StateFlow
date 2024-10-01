import 'state_flow.dart';

class StateValue<T> {
  final String key;
  T _value;
  Object? _error;
  bool _isLoading = false;
  T? _memoizedValue;
  bool _isMemoizedValueValid = false;

  StateValue._(this.key, T initialValue) : _value = initialValue {
    StateFlow().set(key, this);
  }

  factory StateValue(String key, T initialValue) {
    throw UnsupportedError(
        'Direct instantiation of StateValue is not allowed.\n'
        'Please use the take<T>() function to create StateValue instances.\n'
        'Example usage:\n'
        '  final myIntState = take<int>(0);\n'
        '  final myStringState = take<String>("");\n'
        '  final myCustomObjectState = take<MyCustomObject>(MyCustomObject());\n'
        'For more information, contact the library maintainer.');
  }

  T get value {
    if (!_isMemoizedValueValid) {
      _memoizedValue = _value;
      _isMemoizedValueValid = true;
    }
    return _memoizedValue as T;
  }

  Object? get error => _error;
  bool get isLoading => _isLoading;

  set value(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      _error = null;
      _isLoading = false;
      _isMemoizedValueValid = false;
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

  void stopLoading() {
    _isLoading = false;
    StateFlow().notifyListeners(key);
  }

  void setLoaded(T newValue) {
    _value = newValue;
    _isLoading = false;
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
  return StateValue._(
      'state_${DateTime.now().millisecondsSinceEpoch}', initialValue);
}
