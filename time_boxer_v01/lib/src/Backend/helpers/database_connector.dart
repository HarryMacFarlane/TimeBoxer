import 'package:time_boxer_v01/src/Providers/master_provider.dart';

import 'search.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract interface class DatabaseConnector {

  // Tell which database connector to use specifically
  static void initConnector(DatabaseConnector connector){}

  // Custom Connect Logic
  Future<void> connect();

  //Custom Close Logic
  Future<void> close();

  // Custom Query Logic
  Future<List<Map<String, dynamic>?>> executeQuery(SearchParameters params);

  Future<bool> update(List<String> access_path, Map<String, dynamic> data);

  Future<String> save(List<String> access_path, Map<String, dynamic> data); // Saves doc and returns the id

}

class FirestoreConnector {
  static FirebaseFirestore? _firestore = FirebaseFirestore.instance;

  static final FirestoreConnector _instance = FirestoreConnector._();

  FirestoreConnector._();

  static Future<bool> userCheck(String userID) async {
    DocumentSnapshot userSnap =  await _firestore!.collection('users').doc(userID).get();
    return userSnap.exists;
    
  }

  static Future<void> createUser(String userID, Map<String, dynamic> userData) async {
    await _firestore!.collection('users').doc(userID).set(
      userData
    );
  }
  
  static Future<void> connect() async {
    throw Exception('NOT CURRENTLY NEEDED');
  }

  static Future<void> close() async {
    throw Exception('NOT CURRENTLY NEEDED');
  }

  static Future<List<Map<String, dynamic>?>> executeQuery(SearchParameters params) async {
    // Implement a loop to create more .where() on the query!
    throw Exception('IMPLEMENT SPECIFIC QUERYING!'); 
  }

  static Future<String> save(String accessPath, Map<String, dynamic> data) async {


    CollectionReference? colRef = await _getCollection(accessPath);

    assert (colRef != null); // If its still null, I fucked up somewhere

    DocumentReference docRef = await colRef!.add(data);

    String docID = docRef.id;

    return docID;
  }

  // Helper for finding correct storage location
  static Future<DocumentReference> _getUserDocument(String userID) async {
    DocumentReference userDoc = _firestore!.collection('users').doc(userID); // BANG USED!!!!!!
    return userDoc;
  }

  static Future<CollectionReference?> _getCollection(String accessPath) async {
    
    // Now we step through the access path and stop at the last collection;
    CollectionReference? colRef = _firestore!.collection(accessPath);

    return colRef;
  }

  static Future<DocumentReference?> _getDocument(String accessPath) async {
    DocumentReference docRef = _firestore!.doc(accessPath);
    return docRef;
  }

  static Future<void> loadProviders(String userID) async {

    // I need to add some logic here to make sure that when providers are set, each model object keeps its individual access path
    List<String> paths = await _getAccessPaths(userID);

    for (final path in paths) {

      List<Map<String, dynamic>> data_list = await load(path);
  
      MasterProvider.setProviders(userID, data_list, path);
      
    }
  }

  static Future<List<Map<String,dynamic>>> load(String accessPath, {int? max}) async {
    try {
    // First we get the correct collection, and then we can access what is needed
    CollectionReference? colRef = await _getCollection(accessPath);

    // SHould be impossible as path was taken directly from collection
    assert(colRef != null);

    QuerySnapshot query = await colRef!.get(); // Safe bang used with assert

    List<QueryDocumentSnapshot> doc_list = query.docs;

    List<Map<String, dynamic>> data_list = [];

    for (final doc in doc_list)
    {
      Map<String, dynamic> data_map = doc.data() as Map<String, dynamic>;
      data_map['docID'] = doc.id;
      data_list.add(data_map);
    }

    return data_list;
    }

    catch (e)
    {
      throw Exception('Could not load objects!');
    }
  }

  static Future<List<String>> _getAccessPaths(String userID) async {
    DocumentReference userDoc = await _getUserDocument(userID);
    DocumentSnapshot userData = await userDoc.get();

    // These paths should only lead up to a collection, not a document
    List<String> paths = List.from(userData.get('access_paths'));

    return paths;
  }

  static Future<bool> update(String accessPath, Map<String, dynamic> data) async {
    DocumentReference? docRef = await _getDocument(accessPath);
    try {
      docRef!.set(data);
    }
    catch (e){
      throw Exception('Could not save data for: $accessPath');
    }
    return true;
  }

  static Future<bool> delete(String accessPath) async {
    DocumentReference? docRef = await _getDocument(accessPath);

    assert(docRef != null); // This should never happen as how did the object even have that path?

    try {
      await docRef!.delete();
    }
    catch (e){
      throw Exception('Could not delete document here: $accessPath');

      // Put a return false, and if I ever implement db runners, use them to restart or check this...
    }
    return true;
  }

}