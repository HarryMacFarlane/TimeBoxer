
/// API model representing a backend resource.
class ApiModel {
  /// The raw data (including nested maps) from/to the backend.
  Map<String, dynamic> data;

  /// The resource name used to build the endpoint URL.
  String resource;
  /// The unique identifier. If null or empty, the model is new.
  String id;

  bool dirty = false;

  ApiModel({
    required this.data,
    required this.resource,
    required this.id,
  });

  Map<String, dynamic> getJsonBody() {
    Map<String, dynamic> dataWid = Map.from(data);
    dataWid['id'] = id; 
    Map<String, dynamic> wrappedData = { resource: dataWid };
    return wrappedData;
  }

  void modify(Map<String, dynamic> newData) {
    data.forEach((key, _) {
      if (newData.containsKey(key)) {
        data[key] = newData[key];
      }
    });
    dirty = true;
  }
}
