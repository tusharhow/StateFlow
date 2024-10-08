import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:js' as js;

// Public facade class
class StateFlowNavigation {
  static Future<T?> to<T extends Object?>(dynamic route, {Object? arguments}) =>
      _FlowNavigator.to<T>(route, arguments: arguments);

  static void back<T extends Object?>([T? result]) =>
      _FlowNavigator.back(result);

  static Future<T?> off<T extends Object?>(dynamic route,
          {Object? arguments}) =>
      _FlowNavigator.off<T>(route, arguments: arguments);

  static Future<T?> offAll<T extends Object?>(dynamic route,
          {Object? arguments}) =>
      _FlowNavigator.offAll<T>(route, arguments: arguments);

  static void popUntil(RoutePredicate predicate) =>
      _FlowNavigator.popUntil(predicate);

  static bool canPop() => _FlowNavigator.canPop();

  static Future<bool> maybePop<T extends Object?>([T? result]) =>
      _FlowNavigator.maybePop(result);

  static String? currentRoute() => _FlowNavigator.currentRoute();

  static List<String> getHistory() => _FlowNavigator.getHistory();

  static void clearHistory() => _FlowNavigator.clearHistory();

  static final GlobalKey<NavigatorState> navigatorKey =
      _FlowNavigator.navigatorKey;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) =>
      _FlowNavigator.onGenerateRoute(settings);
}

// Private implementation class
class _FlowNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final List<String> _history = [];

  static bool _isInitialized = false;

  static const int _maxHistorySize = 100;

  static void _initializeWebRouting() {
    if (kIsWeb && !_isInitialized) {
      _setupPathBasedRouting();
      _isInitialized = true;
    }
  }

  static void _setupPathBasedRouting() {
    js.context.callMethod('eval', [
      '''
      (function() {
        function removeHash() {
          var uri = window.location.toString();
          if (uri.indexOf("#") > 0) {
            var clean_uri = uri.substring(0, uri.indexOf("#"));
            window.history.replaceState({}, document.title, clean_uri);
          }
        }

        var pushState = history.pushState;
        history.pushState = function() {
          var result = pushState.apply(this, arguments);
          removeHash();
          return result;
        };

        var replaceState = history.replaceState;
        history.replaceState = function() {
          var result = replaceState.apply(this, arguments);
          removeHash();
          return result;
        };

        window.addEventListener('hashchange', removeHash);
        window.addEventListener('load', removeHash);

        window.addEventListener('popstate', function(event) {
          if (event.state !== null) {
            // Handle browser back/forward navigation
            // You may want to update your app's state here
          }
        });
      })();
    '''
    ]);
  }

  static void _updateBrowserUrl(String path) {
    if (kIsWeb) {
      js.context.callMethod('eval', [
        '''
        history.pushState(null, '', '$path');
      '''
      ]);
    }
  }

  static NavigatorState get _navigator {
    _initializeWebRouting();
    final state = navigatorKey.currentState;
    if (state == null) {
      throw StateError(
          'Navigator is not available. Make sure you have set up MaterialApp with FlowNavigator.navigatorKey');
    }
    return state;
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    _addToHistory(settings.name ?? settings.toString());

    return MaterialPageRoute(
      settings: settings,
      builder: (context) => _notFoundScreen(settings.name),
    );
  }

  static Widget _notFoundScreen(String? routeName) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Not Found')),
      body: Center(
        child: Text('No route defined for ${routeName ?? "unknown route"}'),
      ),
    );
  }

  static void _addToHistory(String routeName) {
    _history.add(routeName);
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
    }
  }

  static Future<T?> to<T extends Object?>(dynamic route,
      {Object? arguments}) async {
    _initializeWebRouting();
    try {
      if (route is String) {
        return await _handleStringRoute<T>(route, arguments);
      } else if (route is Widget) {
        return await _handleWidgetRoute<T>(route);
      } else {
        throw ArgumentError('Route must be either a String or a Widget');
      }
    } catch (e) {
      _handleNavigationError(e);
      rethrow;
    }
  }

  static Future<T?> _handleStringRoute<T>(
      String route, Object? arguments) async {
    final path = route.startsWith('/') ? route : '/$route';
    _updateBrowserUrl(path);
    final result = await _navigator.pushNamed(path, arguments: arguments);
    _addToHistory(path);
    return result as T?;
  }

  static Future<T?> _handleWidgetRoute<T>(Widget route) async {
    final routeName = '/${route.runtimeType.toString()}';
    _updateBrowserUrl(routeName);
    final result = await _navigator.push<T>(MaterialPageRoute(
        builder: (_) => route, settings: RouteSettings(name: routeName)));
    _addToHistory(routeName);
    return result;
  }

  static void _handleNavigationError(dynamic error) {
    // Log the error or perform any necessary error handling
    print('Navigation error: $error');
  }

  static Future<T?> off<T extends Object?>(dynamic route,
      {Object? arguments}) async {
    _initializeWebRouting();
    if (route is String) {
      final path = route.startsWith('/') ? route : '/$route';
      _updateBrowserUrl(path);
      final result =
          await _navigator.pushReplacementNamed(path, arguments: arguments);
      if (_history.isNotEmpty) {
        _history.removeLast();
      }
      _addToHistory(path);
      return result as T?;
    } else if (route is Widget) {
      final routeName = '/${route.runtimeType.toString()}';
      _updateBrowserUrl(routeName);
      final result = await _navigator.pushReplacement<T, dynamic>(
          MaterialPageRoute(
              builder: (_) => route, settings: RouteSettings(name: routeName)));
      if (_history.isNotEmpty) {
        _history.removeLast();
      }
      _addToHistory(routeName);
      return result;
    } else {
      throw ArgumentError('Route must be either a String or a Widget');
    }
  }

  static Future<T?> offAll<T extends Object?>(dynamic route,
      {Object? arguments}) async {
    _initializeWebRouting();
    if (route is String) {
      final path = route.startsWith('/') ? route : '/$route';
      _updateBrowserUrl(path);
      final result = await _navigator
          .pushNamedAndRemoveUntil(path, (r) => false, arguments: arguments);
      _history.clear();
      _addToHistory(path);
      return result as T?;
    } else if (route is Widget) {
      final routeName = '/${route.runtimeType.toString()}';
      _updateBrowserUrl(routeName);
      final result = await _navigator.pushAndRemoveUntil<T>(
          MaterialPageRoute(
              builder: (_) => route, settings: RouteSettings(name: routeName)),
          (r) => false);
      _history.clear();
      _addToHistory(routeName);
      return result;
    } else {
      throw ArgumentError('Route must be either a String or a Widget');
    }
  }

  static void back<T extends Object?>([T? result]) {
    if (_navigator.canPop()) {
      if (_history.length > 1) {
        // Remove the current route from history
        _history.removeLast();
        // Get the previous route
        String previousRoute = _history.last;
        // Update the URL immediately
        _updateBrowserUrl(previousRoute);
      } else {
        // If we're at the root, ensure we update to '/'
        _updateBrowserUrl('/');
      }
      // Perform the actual navigation
      _navigator.pop(result);
    }
  }

  static void popUntil(RoutePredicate predicate) {
    _navigator.popUntil((route) {
      final shouldStop = predicate(route);
      if (!shouldStop && _history.isNotEmpty) {
        _history.removeLast();
      }
      return shouldStop;
    });
  }

  static bool canPop() {
    return _navigator.canPop();
  }

  static Future<bool> maybePop<T extends Object?>([T? result]) {
    return _navigator.maybePop(result);
  }

  static String? currentRoute() {
    return _history.isNotEmpty ? _history.last : null;
  }

  static List<String> getHistory() {
    return List.from(_history);
  }

  static void clearHistory() {
    _history.clear();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
