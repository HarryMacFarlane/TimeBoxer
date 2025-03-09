import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeboxerv2/Models/api_models.dart';
import 'package:timeboxerv2/Providers/user_provider.dart';
import 'form.dart';

class TaskScreen extends StatefulWidget {

  const TaskScreen({Key? key}) : super(key: key);

  @override
  _TaskScreenState createState() => _TaskScreenState();

}

class _TaskScreenState extends State<TaskScreen> {
  bool _isLoading = false;

  _TaskScreenState();

  @override
  void initState() {
    super.initState();
  }

  Future<int> _new(Map<String, dynamic> attributes) async {
    // Show progress indicator while awaiting for the completion of the async operation
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return await userProvider.createModel('task', attributes);
  }

  Future<int> _update(String id, Map<String, dynamic> attributes) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    ApiModel? toUpdate = await userProvider.getModel('task', id);
    // ADDD SOME CODE HERE TO ENSURE THAT FOR WHATEVER REASON, THE MODEL IS NOT NULL
    toUpdate!.modify(attributes);
    return userProvider.saveModel(toUpdate);
  }

  Future<int> _delete(String id) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return await userProvider.deleteModel('task', id);
  }

  void _showUpdate(String id, Map<String, dynamic> attributes) async {
    setState(() {
      _isLoading = true;
    });
    // Get the necessary attributes out of the data
    String name = attributes['name'];
    String description = attributes['description'];
    String deadline = attributes['deadline'];
    String expectedCompletion = attributes['expected_completion_time'].toString();
    String priority = attributes['priority_level'].toString();
    String initialSubject = attributes['subject']['id'].toString();
    List<dynamic>? tagMaps = attributes['tags'];
    List<String> initialTags = tagMaps!.map((tag) => tag['id'].toString()).toList();

    final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

    List<Map<String, String>> subjects = userProvider.getFormList('subjects');
    List<Map<String, String>> tags = userProvider.getFormList('tags');

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
            child: TaskForm(
              initialName: name,
              initialDescription: description,
              initialDeadline: deadline,
              initialExpectedCompletion: expectedCompletion,
              initialPriority: priority,
              initialSubject: initialSubject,
              initialTags: initialTags,
              subjects: subjects,
              tags: tags,
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
    final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

    List<Map<String, String>> subjects = userProvider.getFormList('subjects');
    List<Map<String, String>> tags = userProvider.getFormList('tags');

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
          child: 
            TaskForm(
              subjects: subjects,
              tags: tags,
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
          title: Text('Delete Task?'),
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

    Map<String, ApiModel>? tasks = Provider.of<UserProvider>(context).getAllModels('tasks');
    
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
          tasks == null ? 
          Text('No tags found!') :
          ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              ApiModel task = tasks.values.elementAt(index);
              return ExpansionTile(
                title: Text(task.data['name']),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(task.data['description']), // CHANGE THIS TO A MORE SUITABLE WIDGET LATER!
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showUpdate(task.id, task.data),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _showDelete(task.id),
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