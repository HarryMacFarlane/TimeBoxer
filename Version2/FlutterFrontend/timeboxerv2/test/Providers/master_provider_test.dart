import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeboxerv2/Providers/user_provider.dart';
import 'package:timeboxerv2/Providers/master_provider.dart';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // This returns the default client that performs real network calls.
    return super.createHttpClient(context);
  }
}

// Create a fake class to only be used instead of the actual secure storage
class FakeSecureStorage extends FlutterSecureStorage{
  static final FlutterSecureStorage _instance = FakeSecureStorage._internal();
  FakeSecureStorage._internal();

  static FlutterSecureStorage get storage => _instance;

  final Map<String, String?> _storage = {};

  @override
  Future<void> write({AndroidOptions? aOptions, IOSOptions? iOptions, required String key, LinuxOptions? lOptions, MacOsOptions? mOptions, required String? value, WindowsOptions? wOptions, WebOptions? webOptions}) async {
    _storage[key] = value;
  }

  @override
  Future<String?> read({AndroidOptions? aOptions, IOSOptions? iOptions, required String key, LinuxOptions? lOptions, MacOsOptions? mOptions, WindowsOptions? wOptions, WebOptions? webOptions}) async {
    return _storage[key];
  }

  @override
  Future<void> delete({AndroidOptions? aOptions, IOSOptions? iOptions, required String key, LinuxOptions? lOptions, MacOsOptions? mOptions, WindowsOptions? wOptions, WebOptions? webOptions}) async {
    _storage.remove(key);
  }
}

void main() {

  // I have created a test user in my database using the following credentials: email: 'test@example.com', password: 'password123'

  TestWidgetsFlutterBinding.ensureInitialized();

  group('MasterProvider Registering:', () {

    setUpAll(() {

      // Allows http req to reach the real backend server
      HttpOverrides.global = MyHttpOverrides();

      // Overrides secure storage to ensure that I don't get any error
      UserDioClient().overrideStorage(FakeSecureStorage.storage);
    });

    test('Should register a new user', () async {
      // Checks that the user doesn't already exist
      expectLater(MasterProvider.login('john@example.com', 'password123', 'password123'), throwsA(anything));

      await Future.delayed(Duration(seconds: 1));

      expectLater(
        MasterProvider.signUp('john@example.com', 'password123', 'password123'),
        isNotNull,
      );
    });

    test('Handles incorrect signUp', () async {
      // Checks that if the registering call doesn't work that an error is returned!
      expectLater(
        MasterProvider.signUp('john@example.com', 'password12', 'password123'),
        throwsA(anything),
      );
    });

  });

  group('MasterProvider Sign-Ins:',() {
    
    setUpAll(() {
      // Allow real http requests
      HttpOverrides.global = MyHttpOverrides();

      // Overrides secure storage to ensure that I don't get any error
      UserDioClient().overrideStorage(FakeSecureStorage.storage);
    });

    // Test correct sign-ins
    test('Logs in the test user', () {
      expectLater(MasterProvider.login('test@example.com', 'password123', 'password123'), isNotNull);
    });

    test('Raises error during incorrect login', () async {
      // Try login with a user that does not exist
      expectLater(
        MasterProvider.login('test@example.ca', 'password123', 'password123'),
        throwsA(anything)
      );
    });
  });
}