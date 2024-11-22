# Boar: A Lightweight Service Locator for Dart

![Pub Version](https://img.shields.io/pub/v/boar_locator)
![License](https://img.shields.io/github/license/contributors-company/boar_locator)
![Coverage](https://img.shields.io/codecov/c/github/contributors-company/boar_locator)
![Stars](https://img.shields.io/github/stars/contributors-company/boar_locator)

**`Boar`** is a lightweight and simple service locator designed for managing both **synchronous** and **asynchronous** services in Dart applications. It provides a clean API for registering and retrieving services, supporting lazy initialization for asynchronous services and automatic caching after initialization.

## Features

- Register and retrieve **synchronous services**.
- Register and retrieve **asynchronous services** with lazy initialization.
- Automatically cache initialized services.
- Simple, intuitive API for managing dependencies.

---

## Installation

To add `boar` to your project, include the following dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  boar: ^latest_version
```

Then, import the library in your Dart code:

```dart
import 'package:boar/boar.dart';
```

---

## Usage

### 1. Creating a `BoarLocator` Instance

First, create an instance of `BoarLocator`:

```dart
final locator = BoarLocator();
```

### 2. Registering and Retrieving Synchronous Services

You can register and retrieve synchronous services with the instance of `BoarLocator`.

```dart
class ApiService {
  final String baseUrl;
  ApiService(this.baseUrl);
}

void main() {
  final locator = BoarLocator();

  // Registering a synchronous service
  locator.register(ApiService("https://api.example.com"));

  // Retrieving the service
  final apiService = locator.get<ApiService>();
  print(apiService.baseUrl); // Output: https://api.example.com
}
```

#### Unregistering Services

You can unregister a service by its type using `locator.unregister()`.

```dart
locator.unregister<ApiService>();
```

---

### 3. Registering and Retrieving Asynchronous Services

Asynchronous services are registered using an initializer function and are only initialized when requested.

```dart
class DatabaseService {
  Future<void> initialize() async {
    await Future.delayed(Duration(seconds: 2));
  }
}

void main() async {
  final locator = BoarLocator();

  // Registering an asynchronous service
  locator.registerAsync<DatabaseService>(() async {
    final dbService = DatabaseService();
    await dbService.initialize();
    return dbService;
  });

  // Retrieving the asynchronous service
  final dbService = await locator.getAsync<DatabaseService>();
  print("DatabaseService initialized");
}
```

#### Optional Retrieval of Services

To safely retrieve services without throwing errors when they are not registered, use `maybeGet()` or `maybeGetAsync()`.

```dart
void main() async {
  final locator = BoarLocator();

  // Synchronous service retrieval (returns null if not found)
  final apiService = locator.maybeGet<ApiService>();
  if (apiService != null) {
    print(apiService.baseUrl);
  }

  // Asynchronous service retrieval (returns null if not found)
  final dbService = await locator.maybeGetAsync<DatabaseService>();
  if (dbService != null) {
    print("DatabaseService is ready");
  }
}
```

---

## API Reference

### `BoarLocator` Instance Methods

| Method                     | Description                                                                                  |
|----------------------------|----------------------------------------------------------------------------------------------|
| `register<T>(object)`       | Registers a synchronous service of type `T`.                                                 |
| `registerAsync<T>(init)`    | Registers an asynchronous service of type `T` with an initializer function.                 |
| `get<T>()`                  | Retrieves a registered synchronous service of type `T`. Throws an error if not registered.   |
| `maybeGet<T>()`             | Retrieves a registered synchronous service of type `T`, or `null` if not registered.         |
| `getAsync<T>()`             | Retrieves a registered asynchronous service of type `T`. Throws an error if not registered.  |
| `maybeGetAsync<T>()`        | Retrieves a registered asynchronous service of type `T`, or `null` if not registered.        |
| `unregister<T>()`           | Unregisters a service of type `T`.                                                           |

---

## Examples

### Complete Example: Managing Multiple Services

```dart
class ApiService {
  final String baseUrl;
  ApiService(this.baseUrl);
}

class AuthService {
  final String token;
  AuthService(this.token);
}

void main() async {
  final locator = BoarLocator();

  // Register services
  locator.register(ApiService("https://api.example.com"));
  locator.registerAsync<AuthService>(() async {
    await Future.delayed(Duration(seconds: 1));
    return AuthService("secure-token");
  });

  // Retrieve synchronous service
  final apiService = locator.get<ApiService>();
  print(apiService.baseUrl); // Output: https://api.example.com

  // Retrieve asynchronous service
  final authService = await locator.getAsync<AuthService>();
  print(authService.token); // Output: secure-token
}
```

## Codecov

![Codecov](https://codecov.io/gh/contributors-company/boar_locator/graphs/sunburst.svg?token=JWoK0eXo3f)
