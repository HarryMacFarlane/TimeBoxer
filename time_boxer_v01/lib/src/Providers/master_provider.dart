import 'package:flutter/widgets.dart';
import 'model_holder_provider.dart';
import '../Backend/helpers/database_connector.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MasterProvider {
  static final Map<String, ModelProviderHolder> _providers = {};

  static Future<void> createHolder(String userID) async {

    bool userCheck = await FirestoreConnector.userCheck(userID);

    if (!userCheck)
    {
      User currentUser = FirebaseAuth.instance.currentUser!;
      Map<String, dynamic> userData = {
        'created_at': DateTime.now(),
        'email': currentUser.email,
        'last_sign_in': DateTime.now(),
        'name': currentUser.displayName,
        'access_paths': ['users/$userID/subjects', 'users/$userID/tags', 'users/$userID/tasks', 'users/$userID/sessions']
      };

      await FirestoreConnector.createUser(userID, userData);
      
    }

    // Holder load logic
    ModelProviderHolder holder = _getHolderProvider(userID);
    await holder.load_providers();
    debugPrint("Initialized ModelProviderHolder for $userID");
  }

  static ModelProviderHolder _getHolderProvider(String userID) {
    return _providers.putIfAbsent(userID, () => ModelProviderHolder(userID: userID, access_path: ['users', userID]));
  }

  static void setProviders(String userID, List<Map<String, dynamic>> data_list, String accessPath){
    ModelProviderHolder holder = _getHolderProvider(userID);
    holder.load_data(data_list, accessPath);
  }

  static ModelProviderHolder getHolder(String userID){
    ModelProviderHolder? holder = _providers[userID];

    assert(holder != null);

    return holder!;
  }

}