class ServiceLocator {
  final Map<Type, dynamic Function()> _factories = {};

  void register<T>(T Function() factory, {Type? type}) {
    _factories[type ?? T] = factory;
  }

  T get<T>() {
    return _getByType<T>(T);
  }

  T getByType<T>(Type type) {
    return _getByType<T>(type);
  }

  T _getByType<T>(Type type) {
    final factory = _factories[type];
    if (factory == null) {
      throw Exception(
          'Dependency ${type.toString()} not registered. Registered types: ${_factories.keys}');
    }
    return factory() as T;
  }

  bool isRegistered<T>() {
    return _factories.containsKey(T);
  }
}

final globalServiceLocator = ServiceLocator();

T listen<T>([Type? type]) {
  type ??= T;
  return globalServiceLocator.getByType<T>(type);
}
