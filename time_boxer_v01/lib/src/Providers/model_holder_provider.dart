import 'package:flutter/material.dart';
import 'package:time_boxer_v01/src/Backend/helpers/database_connector.dart';

import 'model_provider.dart';
import 'package:provider/provider.dart';


class ModelProviderHolder extends ChangeNotifier {

  String userID;

  List<String?> access_path;

  final Map<String, ModelProvider> _models = {};

  ModelProviderHolder(
    {required this.userID, required this.access_path}
  );

  // This logic ensures all providers for all collection have been initialized and put into 
  Future<void> load_providers() async {
    // Instead of storing the modelproviders with collection_name keys, lets use access paths directly
    await FirestoreConnector.loadProviders(userID);
  }

  ModelProvider _getProvider(String collection){
    return _models.putIfAbsent(collection, () => ModelProvider(collection_name: collection));
  }
  
  // This is used for full collections, so last thing in list should be the collection name
  void load_data(List<Map<String, dynamic>> data_list, String accessPath){
    
    // Get collection
    List<String> accessPathList = accessPath.split('/');

    String? collection = accessPathList.last;
    
    // Get the correct provider (or create it)
    ModelProvider new_provider = _getProvider(collection);
    
    new_provider.loadModels(data_list, accessPath);
  }

  // When database needs to be synced with current stores (not necessary for now)
  Future<void> sync() {
    throw Exception();
  }

  ModelProvider forScreen(String collection){
    
    ModelProvider? screenProvider = _models[collection];
    
    assert(screenProvider != null);

    return screenProvider!; // Safe bang with assert
  }
}