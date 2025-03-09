import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeboxerv2/Models/api_models.dart';
import 'package:timeboxerv2/Providers/user_provider.dart';
import 'form.dart';


class TagScreen extends StatefulWidget {

  const TagScreen({Key? key}) : super(key: key);

  @override
  _TagScreenState createState() => _TagScreenState();

}

class _TagScreenState extends State<TagScreen>{

  bool _isLoading = false;

  _TagScreenState();

  @override
  void initState() {
    super.initState();
  }

  Future<int> _new(Map<String, dynamic> attributes) async {
    // Show progress indicator while awaiting for the completion of the async operation
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return await userProvider.createModel('tag', attributes);
  }

  Future<int> _update(String id, Map<String, dynamic> attributes) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    ApiModel? toUpdate = await userProvider.getModel('tag', id);
    // ADDD SOME CODE HERE TO ENSURE THAT FOR WHATEVER REASON, THE MODEL IS NOT NULL
    toUpdate!.modify(attributes);
    return userProvider.saveModel(toUpdate);
  }

  Future<int> _delete(String id) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return await userProvider.deleteModel('tag', id);
  }

  void _showUpdate(String id, Map<String, dynamic> attributes) async {
    setState(() {
      _isLoading = true;
    });
    // Get the necessary attributes out of the data
    String tagName = attributes['tag_name'];
    String description = attributes['description'];

    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (context) {
         return FractionallySizedBox(
          heightFactor: 0.9, // 90% of screen height
          child: Padding(
            padding:
              EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
              ),
            child: TagForm(
              initialtagName: tagName,
              initialDescription: description,
              onSave: (Map<String, dynamic> attributes) async {
                return await _update(id, attributes);
              },
            ),
          ),
        );
      },
    );

    setState(() {
      _isLoading = false;
    });
  }

  void _showNew() async {
    setState(() {
      _isLoading = true;
    });
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
        heightFactor: 0.9, // 90% of screen height
        child: Padding(
          padding:
            EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
            ),
          child: 
            TagForm(
              onSave: _new,
            ),
          ),
        );
      });
    setState(() {
      _isLoading = false;
    });
  }

  void _showDelete(String id) async {
    setState(() {
      _isLoading = true;
    });

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Tag?'),
          content: Text("Are you sure you want to delete this tag? This can't be undone!"),
          actions: [
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('DELETE'),
              onPressed: () async {
                await _delete(id);
                if (mounted) {
                  Navigator.pop(context);
                }
              },
            )
          ],
        );
      }
    );
    
    setState(() {
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    Map<String, ApiModel>? tags = Provider.of<UserProvider>(context).getAllModels('tags');
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Tags'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showNew,
          ),
        ],
      ),
      body:
          tags == null ? 
          Text('No tags found!') :
          ListView.builder(
            itemCount: tags.length,
            itemBuilder: (context, index) {
              ApiModel tag = tags.values.elementAt(index);
              return ExpansionTile(
                title: Text(tag.data['tag_name']),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(tag.data['description']), // CHANGE THIS TO A MORE SUITABLE WIDGET LATER!
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showUpdate(tag.id, tag.data),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _showDelete(tag.id),
                      ),
                    ],
                  ),
                ],
              );
            },
          )
    );
  } 
}
