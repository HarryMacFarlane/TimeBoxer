import '../Backend/helpers/database_connector.dart';
import 'package:flutter/material.dart';

class ObjectFactory{

  static ModelObject create(String type) {
    // For now the type does no matter, but when I implement different models it will be more useful
    return DocumentModel();
  }
}





abstract interface class ModelObject {
  // Should store fields name in a list and values in a map
  List<String> field_names = []; // Should not hold docID, only actual field names

  Map<String, dynamic> _properties = {};

  VoidCallback? onUpdate; // Callback to notify provider

  late String docID;
  
  Future<void> update(Map<String,dynamic> data) async {}

  void delete();

  Map<String, dynamic> toMap();

  void setData(Map<String, dynamic> data, String accessPath);

  ModelObject();

}

class DocumentModel implements ModelObject{
  @override
  late Map<String, dynamic> _properties;

  @override
  late List<String> field_names;

  @override
  late VoidCallback? onUpdate;

  late String accessPath; 

  @override
  late String docID;

  @override
  void setData(Map<String, dynamic> data, String paccessPath) {
    Map<String, dynamic> properties = Map.of(data);
    docID = properties.remove('docID');
    _properties = properties;
    accessPath = paccessPath;
  }

  @override
  void delete(){
    FirestoreConnector.delete(accessPath);
  }

  @override
  Map<String, dynamic> toMap() {
    return _properties;
  }

  @override
  Future<void> update(Map<String, dynamic> data) async {

    // POTENTIALLY ADD LOGIC HERE TO ONLY SET THE FIELDS THAT NEED TO BE SET!!!!!!

    // Update the database with the new data
    await FirestoreConnector.update(accessPath, data);

    // Set properties to new data (this would also need to be rewritten)
    _properties = data;

    // Notify the provider that 
    onUpdate!.call();
  }
  
}
