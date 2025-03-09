import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeboxerv2/Models/api_models.dart';
import 'package:timeboxerv2/Providers/user_provider.dart';
import 'form.dart';

// TO-DO: Create the screen for the subject list, and include the modal pop-up for the necessary forms!

class SubjectScreen extends StatefulWidget {

  const SubjectScreen({Key? key}) : super(key: key);

  @override
  _SubjectScreenState createState() => _SubjectScreenState();

}

class _SubjectScreenState extends State<SubjectScreen>{

  bool _isLoading = false;

  _SubjectScreenState();

  @override
  void initState() {
    super.initState();
  }

  Future<int> _new(Map<String, dynamic> attributes) async {
    // Show progress indicator while awaiting for the completion of the async operation
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return await userProvider.createModel('subject', attributes);
  }

  Future<int> _update(String id, Map<String, dynamic> attributes) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    ApiModel? toUpdate = await userProvider.getModel('subject', id);
    // ADDD SOME CODE HERE TO ENSURE THAT FOR WHATEVER REASON, THE MODEL IS NOT NULL
    toUpdate!.modify(attributes);
    return userProvider.saveModel(toUpdate);
  }

  Future<int> _delete(String id) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return await userProvider.deleteModel('subject', id);
  }

  void _showUpdate(String id, Map<String, dynamic> attributes) async {
    setState(() {
      _isLoading = true;
    });
    // Get the necessary attributes out of the data
    String name = attributes['name'];
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
            child: SubjectForm(
              initialName: name,
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
            SubjectForm(
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
          title: Text('Delete Subject?'),
          content: Text("Are you sure you want to delete this subject? This can't be undone!"),
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

    Map<String, ApiModel>? subjects = Provider.of<UserProvider>(context).getAllModels('subjects');
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Subjects'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showNew,
          ),
        ],
      ),
      body:
          subjects == null ? 
          Text('No subjects found!') :
          ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              ApiModel subject = subjects.values.elementAt(index);
              return ExpansionTile(
                title: Text(subject.data['name']),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(subject.data['description']), // CHANGE THIS TO A MORE SUITABLE WIDGET LATER!
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showUpdate(subject.id, subject.data),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _showDelete(subject.id),
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
