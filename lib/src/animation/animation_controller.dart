import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';

class AnimationController extends Animation<double>
    with
        AnimationEagerListenerMixin,
        AnimationLocalListenersMixin,
        AnimationLocalStatusListenersMixin {
  AnimationController({
    double? value,
    this.duration,
    this.reverseDuration,
    this.debugLabel,
    this.lowerBound = 0.0,
    this.upperBound = 1.0,
    this.animationBehavior = AnimationBehavior.normal,
    required TickerProvider vsync,
  }) : _ticker = vsync.createTicker(_tickProxy) {
    _internalSetValue(value ?? lowerBound);
  }

  late Ticker _ticker;  // Changed from 'late final' to 'late'
  final Duration? duration;
  final Duration? reverseDuration;
  final String? debugLabel;
  final double lowerBound;
  final double upperBound;
  final AnimationBehavior animationBehavior;

  AnimationStatus _status = AnimationStatus.dismissed;
  double _value = 0.0;
  bool _isAnimating = false;
  Duration _lastElapsed = Duration.zero;

  late final double _delta = upperBound - lowerBound;

  @override
  double get value => _value;

  @override
  AnimationStatus get status => _status;

  static void _tickProxy(Duration elapsed) {
    // This method will be replaced in _tick
  }

  void _tick(Duration elapsed) {
    print('Tick: $elapsed');
    _lastElapsed = elapsed;
    final Duration? animationDuration = _status == AnimationStatus.forward ? duration : reverseDuration ?? duration;
    if (animationDuration == null) {
      _isAnimating = false;
      stop();
      return;
    }

    double t = elapsed.inMilliseconds / animationDuration.inMilliseconds;
    
    if (t >= 1.0) {
      _isAnimating = false;
      if (_status == AnimationStatus.forward) {
        _internalSetValue(upperBound);
      } else {
        _internalSetValue(lowerBound);
      }
      stop();
    } else {
      double newValue = _status == AnimationStatus.forward
          ? lowerBound + _delta * t
          : upperBound - _delta * t;
      _internalSetValue(newValue);
    }
  }

  void _internalSetValue(double newValue) {
    _value = clampDouble(newValue, lowerBound, upperBound);
    notifyListeners();
    _checkStatusChanged();
  }

  void _checkStatusChanged() {
    final newStatus = _value == lowerBound
        ? AnimationStatus.dismissed
        : _value == upperBound
            ? AnimationStatus.completed
            : _status == AnimationStatus.forward
                ? AnimationStatus.forward
                : AnimationStatus.reverse;
    
    if (newStatus != _status) {
      _status = newStatus;
      notifyStatusListeners(_status);
    }
  }

  void _initTicker() {
    if (_ticker is! _AnimationControllerTicker) {
      final oldTicker = _ticker;
      _ticker = _AnimationControllerTicker(this, _tick, debugLabel: debugLabel);
      oldTicker.dispose();
    }
  }

  void forward({double? from}) {
    _initTicker();
    print('Forward called'); // Add this debug print
    if (_isAnimating) {
      stop();
    }
    if (from != null) {
      _internalSetValue(from);
    }
    _status = AnimationStatus.forward;
    _isAnimating = true;
    _lastElapsed = Duration.zero;
    _ticker.start();
  }

  void reverse({double? from}) {
    _initTicker();
    print('Reverse called'); // Add this debug print
    if (_isAnimating) {
      stop();
    }
    if (from != null) {
      _internalSetValue(from);
    }
    _status = AnimationStatus.reverse;
    _isAnimating = true;
    _lastElapsed = Duration.zero;
    _ticker.start();
  }

  void stop({bool canceled = true}) {
    _ticker.stop(canceled: canceled);
    _isAnimating = false;
    _lastElapsed = Duration.zero;
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  String toString() {
    return '${objectRuntimeType(this, 'AnimationController')}(${toStringDetails()})';
  }

  String toStringDetails() {
    final buffer = StringBuffer()
      ..write('value: ${value.toStringAsFixed(3)}')
      ..write(', status: $status')
      ..write(', isAnimating: $_isAnimating')
      ..write(', duration: $duration')
      ..write(', reverseDuration: $reverseDuration')
      ..write(', lowerBound: $lowerBound')
      ..write(', upperBound: $upperBound');
    if (debugLabel != null) {
      buffer.write(', debugLabel: $debugLabel');
    }
    return buffer.toString();
  }
}

class _AnimationControllerTicker extends Ticker {
  _AnimationControllerTicker(this.controller, TickerCallback tick, {String? debugLabel})
      : super(tick, debugLabel: debugLabel);

  final AnimationController controller;

  @override
  void dispose() {
    controller._ticker = _DisposedTicker();
    super.dispose();
  }
}

class _DisposedTicker extends Ticker {
  _DisposedTicker() : super((_) {}, debugLabel: 'disposed ticker');

  @override
  void dispose() {
    print('Disposed ticker being disposed. Stack trace:');
    try {
      throw Exception('Dummy exception for stack trace');
    } catch (e, stackTrace) {
      print(stackTrace);
    }
    super.dispose();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    print('Method called on disposed ticker: ${invocation.memberName}');
    print('Arguments: ${invocation.positionalArguments}');
    print('Named arguments: ${invocation.namedArguments}');
    return super.noSuchMethod(invocation);
  }
}

AnimationController takeAnimationController({
  TickerProvider? vsync,
  Duration? duration,
}) {
  return AnimationController(
    vsync: vsync ?? _SingleUseTickerProvider(),
    duration: duration ?? const Duration(milliseconds: 300),
  );
}

class _SingleUseTickerProvider implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick, debugLabel: 'created by takeAnimationController');
  }
}
