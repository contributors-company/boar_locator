import 'package:boar_locator/boar_locator.dart';

class ApiService {
  ApiService(this.baseUrl);

  final String baseUrl;
}

class DatabaseService {
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 2), () => {});
  }
}

void main() async {
  final locator = BoarLocator()..register(ApiService('https://api.example.com'))
    ..registerAsync<DatabaseService>(() async {
    final dbService = DatabaseService();
    await dbService.initialize();
    return dbService;
  });

  final apiService = locator.get<ApiService>();

  final dbService = await locator.getAsync<DatabaseService>();

}
