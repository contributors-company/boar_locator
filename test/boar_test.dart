import 'package:boar_locator/boar_locator.dart';
import 'package:test/test.dart';

class ApiService {
  ApiService(this.baseUrl);
  final String baseUrl;
}

class DatabaseService {
  bool initialized = false;

  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 2), () => {});
    initialized = true;
  }
}

void main() {
  late BoarLocator locator;

  // Инициализация перед каждым тестом
  setUp(() {
    locator = BoarLocator(); // Создаем новый экземпляр перед каждым тестом
  });

  // Тест на регистрацию и получение синхронного сервиса
  test('should register and retrieve a synchronous service', () {
    final apiService = ApiService('https://api.example.com');

    locator.register(apiService); // Регистрируем сервис

    final retrievedService = locator.get<ApiService>(); // Получаем сервис
    expect(retrievedService.baseUrl, equals('https://api.example.com'));
  });

  // Тест на регистрацию и получение асинхронного сервиса
  test('should register and retrieve an asynchronous service', () async {
    locator.registerAsync<DatabaseService>(() async {
      final dbService = DatabaseService();
      await dbService.initialize();
      return dbService;
    });

    final dbService = await locator.getAsync<DatabaseService>();
    expect(dbService, isNotNull);
  });

  // Тест на получение несуществующего синхронного сервиса (ошибка)
  test('should throw exception when synchronous service is not registered', () {
    expect(() => locator.get<ApiService>(), throwsException);
  });

  // Тест на получение несуществующего асинхронного сервиса (ошибка)
  test('should throw exception when asynchronous service is not registered',
      () async {
    expect(() => locator.getAsync<DatabaseService>(), throwsException);
  });

  // Тест на корректную работу maybeGet (возвращает null, если сервис не зарегистрирован)
  test(
      'should return null if synchronous service is not registered using maybeGet',
      () {
    final apiService = locator.maybeGet<ApiService>();
    expect(apiService, isNull);
  });

  // Тест на корректную работу maybeGetAsync (возвращает null, если сервис не зарегистрирован)
  test(
      'should return null if asynchronous service is not registered using maybeGetAsync',
      () async {
    final dbService = await locator.maybeGetAsync<DatabaseService>();
    expect(dbService, isNull);
  });

  // Тест на удаление сервиса
  test('should unregister a service', () {
    final apiService = ApiService('https://api.example.com');
    locator
      ..register(apiService)
      ..unregister<ApiService>(); // Удаляем сервис

    expect(() => locator.get<ApiService>(),
        throwsException); // После удаления не должно быть доступно
  });
}
