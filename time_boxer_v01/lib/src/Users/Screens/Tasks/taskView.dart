import 'package:flutter/material.dart';
import 'package:time_boxer_v01/src/Providers/model_objects.dart';
import 'package:time_boxer_v01/src/Users/Screens/Tasks/Forms/taskForm.dart';
import '../../../Providers/model_provider.dart';
import 'package:provider/provider.dart';
import 'Tables/task_table.dart';

class TaskView extends StatelessWidget {
  final String userID;
  final ModelProvider taskProvider;
  final ModelProvider tagProvider;
  final ModelProvider subjectProvider;

  const TaskView({super.key, required this.userID, required this.taskProvider, required this.tagProvider, required this.subjectProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ModelProvider>.value(
      value: taskProvider,
      child: Consumer<ModelProvider>(
        builder: (context, taskProvider, child) =>
          Column(children: [
            ElevatedButton(onPressed:() async {
              await showDialog(context: context, builder: (context) => TaskFormWidget(subjects: subjectProvider.toDisplay(), tags: tagProvider.toDisplay(), onSubmit: (data) async => await taskProvider.addModel(data, 'users/$userID/tasks')));
          
            }, child: Text('New Task')),
            Expanded(child: 
              TaskTableWidget(
                models: taskProvider.toDisplay(),
                fields: ['Name', 'Subject', 'Tags', 'Description', 'Completion Time', 'Completed'],
                subjectGetter: subjectProvider.getSubjectName,
                tagGetter: tagProvider.getTag,
                )),
          ],)
      ),
    );
  }
}