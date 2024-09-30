class StateFlowController {
  bool _isInitialized = false;
  bool _isDisposed = false;

  /// Called when the controller is initialized
  void onInit() {
    if (_isInitialized) return;
    _isInitialized = true;
    // Notify listeners or trigger state update
    _notifyStateChange();
  }

  /// Called when the controller is ready to be used
  void onReady() {
    assert(_isInitialized,
        'Controller must be initialized before calling onReady');
    // Perform any ready state actions
    _notifyStateChange();
  }

  /// Called when the controller is being disposed
  void onDispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    // Notify listeners or trigger state update
    _notifyStateChange();
  }

  /// Checks if the controller has been initialized
  bool get isInitialized => _isInitialized;

  /// Checks if the controller has been disposed
  bool get isDisposed => _isDisposed;

  /// Notifies listeners of state changes
  void _notifyStateChange() {}
}
