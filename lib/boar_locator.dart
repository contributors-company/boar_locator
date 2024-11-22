/// The `boar` library provides a lightweight service locator for managing
/// both synchronous and asynchronous objects. It simplifies dependency
/// management in applications by offering an easy-to-use API.
library boar_locator;

/// The `BoarLocator` class provides instance methods for registering,
/// unregistering, and retrieving synchronous and asynchronous services.
class BoarLocator {
  // Maps to store synchronous and asynchronous services
  final Map<Type, Object> _services = {};
  final Map<Type, Future<Object> Function()> _asyncServices = {};

  /// Registers a synchronous service.
  ///
  /// Example:
  /// ```dart
  /// class ApiService {
  ///   final String baseUrl;
  ///   ApiService(this.baseUrl);
  /// }
  ///
  /// void main() {
  ///   final locator = BoarLocator();
  ///   locator.register(ApiService("https://api.example.com"));
  ///   final apiService = locator.get<ApiService>();
  ///   print(apiService.baseUrl); // Output: https://api.example.com
  /// }
  /// ```
  void register<T extends Object>(T object) {
    _services[T] = object;
  }

  /// Unregisters a service by its type.
  ///
  /// Example:
  /// ```dart
  /// final locator = BoarLocator();
  /// locator.unregister<ApiService>();
  /// ```
  void unregister<T extends Object>() {
    _services.remove(T);
    _asyncServices.remove(T);
  }

  /// Registers an asynchronous service initializer.
  ///
  /// Example:
  /// ```dart
  /// class DatabaseService {
  ///   Future<void> initialize() async {
  ///     await Future.delayed(Duration(seconds: 2));
  ///   }
  /// }
  ///
  /// void main() async {
  ///   final locator = BoarLocator();
  ///   locator.registerAsync<DatabaseService>(() async {
  ///     final dbService = DatabaseService();
  ///     await dbService.initialize();
  ///     return dbService;
  ///   });
  ///
  ///   final dbService = await locator.getAsync<DatabaseService>();
  ///   print("DatabaseService initialized");
  /// }
  /// ```
  void registerAsync<T extends Object>(Future<T> Function() init) {
    _asyncServices[T] = init;
  }

  /// Retrieves a registered synchronous service.
  ///
  /// Throws an exception if the service is not registered.
  ///
  /// Example:
  /// ```dart
  /// final locator = BoarLocator();
  /// final apiService = locator.get<ApiService>();
  /// print(apiService.baseUrl);
  /// ```
  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T is not registered');
    }
    return service as T;
  }

  /// Retrieves a registered synchronous service, or `null` if it is not registered.
  ///
  /// Example:
  /// ```dart
  /// final locator = BoarLocator();
  /// final apiService = locator.maybeGet<ApiService>();
  /// if (apiService != null) {
  ///   print(apiService.baseUrl);
  /// }
  /// ```
  T? maybeGet<T>() => _services[T] as T?;

  /// Retrieves a registered asynchronous service.
  ///
  /// Throws an exception if the service is not registered.
  ///
  /// Example:
  /// ```dart
  /// final locator = BoarLocator();
  /// final dbService = await locator.getAsync<DatabaseService>();
  /// ```
  Future<T> getAsync<T>() async {
    final instance = await _getOrCreateAsync<T>(throwIfNotFound: true);
    return instance!;
  }

  /// Retrieves a registered asynchronous service, or `null` if it is not registered.
  ///
  /// Example:
  /// ```dart
  /// final locator = BoarLocator();
  /// final dbService = await locator.maybeGetAsync<DatabaseService>();
  /// if (dbService != null) {
  ///   print("DatabaseService is ready");
  /// }
  /// ```
  Future<T?> maybeGetAsync<T>() async =>
      _getOrCreateAsync<T>(throwIfNotFound: false);

  /// Helper method to handle asynchronous service initialization.
  ///
  /// If `throwIfNotFound` is true, throws an exception when the service is not registered.
  Future<T?> _getOrCreateAsync<T>({required bool throwIfNotFound}) async {
    // If the service is already registered synchronously
    if (_services.containsKey(T)) {
      return Future.value(_services[T] as T);
    }

    // If the service is registered asynchronously
    final asyncService = _asyncServices[T];
    if (asyncService == null) {
      if (throwIfNotFound) {
        throw Exception('Async service of type $T is not registered');
      }
      return null;
    }

    // Initialize the service and cache it
    final instance = await asyncService();
    _services[T] = instance;
    return instance as T;
  }
}
