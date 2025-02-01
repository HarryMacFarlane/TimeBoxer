
// Implement SearchHub in future
class SearchHub {}




// Since I will be using subcollections, I will need to configure paths through documents to access the data I need.

abstract interface class SearchField{
  String? key;
  dynamic value;
  String? description;

  String generateLogic();
}

class SearchParameters {
  List<SearchField>? fields;
  String collection;
  int? max_return;

  SearchParameters(String collection_name, {List<SearchField>? pfields, int? max_return})
      : collection = collection_name,
        fields = pfields,
        max_return = max_return;
}



// Implement flyweight pattern to create a single instance of searcher for each collection, 
// and then use that instance to search for documents in that collection.

class DocumentSearcher {

  Map<String, String?> accessPath = {'users' : ''}; // Will always be in the following order: [collection, docID, subcollection, docID, ...]

  SearchParameters? searchParams; // BUG HERE, FIX TO ENSURE CONSTRUCTOR!

  DocumentSearcher(String userID, SearchParameters params){
    accessPath['users'] = userID;
    searchParams ??= params;
  }


  String get collection => searchParams!.collection;

  String? get userID => accessPath['users'];

  SearchParameters? get params => searchParams;


  // Set the search parameters for the searcher
  void setSearchParameters(SearchParameters params) => searchParams = params;

  // If there is 
  bool get searchFlag => searchParams == null;

}
