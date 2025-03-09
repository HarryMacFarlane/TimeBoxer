import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_provider.dart';

class MasterProvider {
  // Fields
  static const String _baseUrl = "http://127.0.0.1:3000"; // SWITCH TO USE DOTENV TO SET THE URL!
  
  static final Map<String, String> _headers = {'Content-Type': 'application/json','ACCEPT': 'application/json'};

  
  static Future<UserProvider> login(String email, String password, String passwordConfirmation) async {
    final url = Uri.parse("$_baseUrl/login");
    final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({'user': {'email': email, 'password': password, 'password_confirmation': passwordConfirmation}}),
    );
    if (response.statusCode == 200) {
        // Get the token out of the header
        String token = response.headers['authorization']!;
        // Initialize the dio client and use it to load models
        return await initializeUserProvider(token);
    }
    else {
      throw Exception('Master Provider: Did not receive 200 status code upon login!');
    }
  }

  static Future<UserProvider> signUp(String email, String password, String passwordConfirmation) async {
      final url = Uri.parse("$_baseUrl/signup");
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({'user': {'email': email, 'password': password, 'password_confirmation': passwordConfirmation } }),
      );

      if (response.statusCode == 201) {
        // Get the token out of the header
        String token = response.headers['authorization']!;
        // Initialize the dio client and use it to load models
        return await initializeUserProvider(token);
      }
      else {
        throw Exception('Did not receive status code 201 during sign up!');
      }
  }

  static Future<UserProvider> initializeUserProvider(String token) async {
    await UserDioClient().initialize(token);

    UserProvider userProvider = UserProvider();


    // ADD SOME FORM OF RESPONSE CODE VERIFICATION HERE (potentially force the login again?)
    await userProvider.loadModels();

    return userProvider;
  }

}