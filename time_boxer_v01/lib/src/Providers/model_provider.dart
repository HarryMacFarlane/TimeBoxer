import 'package:flutter/material.dart';
import 'package:time_boxer_v01/src/Backend/helpers/database_connector.dart';
import 'model_objects.dart';

// Make a provider class that can provide a list of models from a collection
class ModelProvider extends ChangeNotifier {
  
  String collection_name;

  final List<ModelObject> _models = [];

  ModelProvider({required this.collection_name});

  void loadModels(List<Map<String, dynamic>> data_list, String accessPath) {
    
    for (Map<String, dynamic> data in data_list){
      
      ModelObject new_object = ObjectFactory.create(collection_name);

      String docID = data['docID'];

      String fullaccessPath = "$accessPath/$docID";

      new_object.setData(data, fullaccessPath); // This method NEEDS to create the access path for saving in the future

      _models.add(new_object);
      
      new_object.onUpdate = notifyListeners;
    }
    notifyListeners();
    return;
  }

  Future<void> addModel(Map<String, dynamic> dataMap, String accessPath) async {
    
    // Create object
    ModelObject object = ObjectFactory.create(collection_name);

    // Save the data to the database
    String? docID = await FirestoreConnector.save(accessPath, dataMap);

    // Append the access path to include the id number of the document
    accessPath += "/$docID";

    dataMap['docID'] = docID;
    
    // Set the objects data
    object.setData(dataMap, accessPath);

    // Make sure the object can notify the provider on future saves
    object.onUpdate = notifyListeners;

    _models.add(object);

    // Rebuild widgets to include the new object
    notifyListeners();
  }

  Future<void> notify() async {
    notifyListeners();
  } 

  // Rewrite this in future
  List<ModelObject> toDisplay() {
    return _models;
  }

  String getSubjectName(String docID){

    for (ModelObject model in _models){
      if (model.docID.compareTo(docID) == 0) return model.toMap()['Name'];
    }
    throw Exception('Asked provider to return non-existent name for docID');
  }

  String getTag(String docID){
    for (ModelObject model in _models){
      if (model.docID.compareTo(docID) == 0) return model.toMap()['Tag'];
    }
    throw Exception('Asked provider to return non-existent name for docID');
  }

  void deleteModel(ModelObject model){
    model.delete();
    _models.remove(model);
    notifyListeners();
  }

} 