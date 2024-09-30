class ServiceLocator {
  final Map<Type, dynamic Function()> _factories = {};

  void register(Type type, dynamic Function() factory) {
    _factories[type] = factory;
  }

  T get<T>() {
    final factory = _factories[T];
    if (factory == null) {
      throw Exception('Dependency $T not registered');
    }
    return factory() as T;
  }
}