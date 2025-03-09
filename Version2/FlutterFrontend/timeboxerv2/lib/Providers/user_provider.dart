import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:timeboxerv2/Models/api_models.dart';

// THis class will be responsible to storing and holding 
class UserDioClient {

  static final UserDioClient _instance = UserDioClient._internal();
  factory UserDioClient() => _instance;
  UserDioClient._internal() : _storage = const FlutterSecureStorage();

  final Dio _dio = Dio();
  FlutterSecureStorage _storage;

  Dio get dio => _dio;


  // ONLY USED FOR TESTING!!!!!!!
  void overrideStorage(FlutterSecureStorage newStorage) {
    _storage = newStorage;
  }


  Future<void> initialize(String token) async {
    // Ensure to write the token into secure storage
    await _storage.write(key: 'jwt_token', value: token);

    // Attach the interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get token from secure storage
          String? token = await _storage.read(key: 'jwt_token');
          
          if (token == null) {
            throw Exception('JWT Token is null in secure storage!');
          }
          
          // Set all the necessary headers
          options.headers['Authorization'] = token;
          options.headers['Content-Type'] = 'application/json';
          options.headers['ACCEPT'] = 'application/json';

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Global error handling for any DioError (network issues, etc.)
          if (e.response?.statusCode == 401) {
            Exception("Unauthorized! Redirect to login.");
            // Optionally refresh token logic here
          }
          else if (e.response?.statusCode == 404) {
            Exception("Not Found! Redirect to login.");
          }
          return handler.next(e);
        },
      ),
    );
    dio.options.baseUrl = 'http://127.0.0.1:3000/'; // REPLACE THIS IN THE FUTURE!!!!
  }

  void logout() async {
    await _storage.delete(key: 'jwt_token');
  }

}





class UserProvider {

  final Map<String, Map<String, ApiModel>> userData = {};

  final UserDioClient _dioClient = UserDioClient();


  UserProvider() {
    // Immediately load models after initialization.
    loadModels();
  }


  Future<bool> logout() async {
    try {
      final response = await UserDioClient().dio.delete('logout');
      if (response.statusCode == 200){
        UserDioClient().logout();
        return true;
      }

      return false;
    }
    catch (e){
      throw Exception('User Provider: Error during sign out; $e');
    }
  }

  // This method will populate the user_data with api model objects to be held by this object
  Future<int> loadModels() async {
    // First, I need to get a list of all ressources available in my backed. For now I will hard code it.
    List<String> resources = ["tags", "subjects", "tasks", "workblocks"]; // REPLACE THIS IN THE FUTURE!!!!
    Dio dio = UserDioClient().dio;
    // Next, we will loop through and create model objects using this approach
    for (String resource in resources) {
      try {
        // Run index request for current resource
        final Response response = await dio.get(resource);
        final Map<String, dynamic> data = response.data;
        final items = data['data'];
        for (var item in items) {
          // Retrieve the id, resource name, and attributes.
          final String id = item['id'].toString();
          final String resourceName = item['type'];
          final Map<String, dynamic> attributes =
            Map<String, dynamic>.from(item['attributes']);

          // Create the model. Here, GenericApiModel is a concrete implementation of ApiModel.
          final model = ApiModel(
            data: attributes,
            resource: resourceName,
            id: id,
          );

          // Insert the model into our normalized userData map.
          userData.putIfAbsent(resource, () => {});
          userData[resource]![id] = model;
        }
      } 
      catch (e) {
        return 500;
      }
    }
    return 200;
  }


  Future<ApiModel?> getModel(String resourceName, String objectId) async {
    '''
    Input:
      String resourceName: Name of the resource, no need for plural!
      String objectId: The id of the object to be retrieved
    Output:
      Future<ApiModel>: The model object that was retrieved
    ''';
    ApiModel? foundModel = userData[resourceName]?[objectId];
    if (foundModel != null) {
      return foundModel;
    }
    else {
      // If the model is not currently loaded, check to see if it exists in the backend
      try {
        Dio dio = UserDioClient().dio;
        final Response response = await dio.get(
          "${resourceName}s/$objectId",
        );
        // Get the data
        Map<String, dynamic> modelData = response.data['data'];
        // Create a new model
        ApiModel newModel = ApiModel(id: objectId, data: modelData['attributes'], resource: modelData['type']);
        // Insert the model into userData map.
        userData.putIfAbsent(resourceName, () => {});
        userData[resourceName]![objectId] = newModel;
        // Return the new model
        return newModel;
      }
      catch (e) {
        return null;
      }
    }
  }

  List<Map<String, String>> getFormList(String resourceName) {
    '''
    Input:
      String resourceName: The name of the resource to get the form list for
    Output:
      Future<List<Map<String, String>>>: A list of maps containing the id and name of the resource
    ''';
    List<Map<String, String>> formList = [];
    String nameKey;
    if (resourceName == "tags") {
      nameKey = 'tag_name';
    }
    else {
      nameKey = 'name';
    }
    getAllModels(resourceName)?.forEach((_, value) {
      formList.add({ 'id': value.id, nameKey: value.data[nameKey] });
    });
    return formList;
  }


  Future<int> createModel(String resourceName, Map<String, dynamic> attributes) async {
  '''
  Input: 
    String resourceName: Should be the simple resource name, no need for pluralirization
    Map<String, dynamic> attributes: The attributes of the model to be created (should already be in the correct form)
  Output:
    Future<ApiModel>: The newly created model (saved to the backend hopefully)
  ''';
    try {
      Dio dio = _dioClient.dio;
      Response response;
      response = await dio.post(
        "${resourceName}s",
        data: { resourceName: attributes },
      );
      // Get the data
      Map<String, dynamic> modelData = response.data['data'];
      // Create a new model
      ApiModel newModel = ApiModel(id: modelData['id'], data: modelData['attributes'], resource: modelData['type']);
      // Insert the model into userData map.
      userData.putIfAbsent("${resourceName}s", () => {});
      userData["${resourceName}s"]![modelData['id']] = newModel;
      // Return the new model
      return 201;
    }
    catch (e) {
      return 500;
    }
  }

  Future<int> saveModel(ApiModel model) async {
    '''
    Input:
      ApiModel model: The model to be saved
    Output:
      Future<ApiModel>: The model that was saved
    => This method should just save the model if dirty!
    ''';
    if (model.dirty == false) {
      return 200;
    }
    try {
      Dio dio = _dioClient.dio;
      await dio.patch(
        '${model.resource}s',
        data: { model.resource: { model.getJsonBody() }},
      );

      // Update the model to no longer be dirty
      model.dirty = false;
      return 200;
    }
    catch (e) {
      return 500;
    }
  }



  Future<int> deleteModel(String resourceName, String objectId) async {
    '''
    Input: 
      String id: Id of entry in database
      String resourceName: Non-plural type of entry
    Output:
      Future<int>: The response code from the server
    ''';
    Map<String, dynamic> deleteParams = { resourceName: { 'id': objectId } };
    try {
      Dio dio = _dioClient.dio;
      await dio.delete(
        '${resourceName}s',
        data: deleteParams
      );

      // If we reach this point, no error was raised by the dio client!
      userData['${resourceName}s']!.remove(objectId);
      return 200;
    }
    catch (e) {
      return 500;
    }
  }

  Map<String, ApiModel>? getAllModels(String resource) {
    '''
    Input: 
      resourceName (String): Plural name of the resource
    Output:
      Map<String, ApiModel>: A map of all the models for the given resource
    => If no ressource exists there, then it will return null!
    ''';
    return userData[resource];
  }
}