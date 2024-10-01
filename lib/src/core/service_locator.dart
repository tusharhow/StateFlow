class ServiceLocator {
  final Map<Type, dynamic Function()> _factories = {};

  void register(Type type, dynamic Function() factory) {
    _factories[type] = factory;
  }

  dynamic get(Type type) {
    final factory = _factories[type];
    if (factory == null) {
      throw Exception('Dependency $type not registered');
    }
    return factory();
  }
}

final globalServiceLocator = ServiceLocator();

dynamic listen(Type type) {
  return globalServiceLocator.get(type);
}
