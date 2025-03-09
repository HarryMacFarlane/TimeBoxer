import 'package:flutter_test/flutter_test.dart';
import 'package:timeboxerv2/Providers/user_provider.dart';
import 'package:timeboxerv2/Providers/master_provider.dart';
import 'package:timeboxerv2/Models/api_models.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // This returns the default client that performs real network calls.
    return super.createHttpClient(context);
  }
}

// Create a fake class to only be used instead of the actual secure storage
class FakeSecureStorage extends FlutterSecureStorage {

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

  group('User Provider (Sign Outs): ', () {
    late UserProvider basicUser;
    late FlutterSecureStorage storage;

    setUpAll(() async {
      // Allows http req to reach the real backend server
      HttpOverrides.global = MyHttpOverrides();

      storage = FakeSecureStorage.storage;

      // Overrides secure storage to ensure that I don't get any error
      UserDioClient().overrideStorage(storage); 
    });

    // Ensure a login has been executed before any test    
    setUp(() async {
    // Sign in with the test user to make sure it exists, and we have an up to date 
      basicUser = await MasterProvider.login('test@example.com', 'password123', 'password123');
      await Future.delayed(Duration(seconds: 1));
    });

    test('Test User can successfully sign out', () async {
      // Check that the token in the fake storage is actually there
      await expectLater(await storage.read(key: 'jwt_token'), isNotNull);
      
      // Ensure that a user can logout
      expect(await basicUser.logout(), true);

      // Check that we successfully erase the token upon sign out
      await expectLater(await storage.read(key: 'jwt_token'), isNull);
    });

  });

  group("User Provider (Model Loading): ", () {
    late UserProvider basicUser;
    late FlutterSecureStorage storage;

    setUpAll(() async {
      // Allows http req to reach the real backend server
      HttpOverrides.global = MyHttpOverrides();

      storage = FakeSecureStorage.storage;

      // Overrides secure storage to ensure that I don't get any error
      UserDioClient().overrideStorage(storage); 
    });

    // Ensure a login has been executed before any test    
    setUp(() async {
    // Sign in with the test user to make sure it exists, and we have an up to date 
      basicUser = await MasterProvider.login('test@example.com', 'password123', 'password123');
      await Future.delayed(Duration(seconds: 1));
    });

    test("Check model objects are being correctly loaded", () {
      expect(basicUser.getAllModels('subjects'), isA<Map<String, ApiModel>>());
    });

  });

  group("User Provider (Model Manipulation): ", () {
    late UserProvider basicUser;
    late FlutterSecureStorage storage;

    setUpAll(() async {
      // Allows http req to reach the real backend server
      HttpOverrides.global = MyHttpOverrides();

      storage = FakeSecureStorage.storage;

      // Overrides secure storage to ensure that I don't get any error
      UserDioClient().overrideStorage(storage); 
    });

    // Ensure a login has been executed before any test    
    setUp(() async {
    // Sign in with the test user to make sure it exists, and we have an up to date 
      basicUser = await MasterProvider.login('test@example.com', 'password123', 'password123');
      await Future.delayed(Duration(seconds: 1));
    });

    test("Create a model object", () async {
      // Create the attributes for the new model object
      Map<String, dynamic> newAttributes = {'name': 'User Provider Model Test 1', 'description': 'Test description'};

      expectLater(basicUser.createModel('subject', newAttributes), completion(equals(201)));
    });

    test("Update a model object", () async {
      // Since these tests are using a test database, I know that there will be an object with an id of 1
      ApiModel? model = await basicUser.getModel('subject', '1');

      // Modify the model object with its associated data
      model!.modify({'name': 'User Provider Model Test 2', 'description': 'Test description'});

      // Ensure normal functioning with the response code
      expectLater(basicUser.saveModel(model), completion(equals(200)));
    });

    test("Delete a model object", () async {
      // Since these tests are using a test database, I know that there will be an object with an id of 1
      expectLater(basicUser.getModel('subject', '1'), completion(isA<ApiModel>()));

      // Delete the model in the database
      await basicUser.deleteModel('subject', '1');

      // Ensure the change has been extended to the database!
      expectLater(basicUser.getModel('subject', '1'), completion(equals(null)));
    });
  });
}