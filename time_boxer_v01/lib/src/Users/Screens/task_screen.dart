import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_boxer_v01/src/Providers/master_provider.dart';
import 'package:time_boxer_v01/src/Providers/model_holder_provider.dart';
import 'package:time_boxer_v01/src/Providers/model_provider.dart';
import 'package:time_boxer_v01/src/Users/Screens/Tasks/subjectView.dart';
import 'package:time_boxer_v01/src/Users/Screens/Tasks/tagView.dart';
import 'package:time_boxer_v01/src/Users/Screens/Tasks/taskView.dart';

class TaskScreen extends StatelessWidget {
  final String userID = FirebaseAuth.instance.currentUser!.uid;
  
  TaskScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ModelProviderHolder>.value(
      value: MasterProvider.getHolder(userID),
      child:
          Consumer<ModelProviderHolder>(
            builder: (context, holder, child) {
              return DefaultTabController(
                length: 3,
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text('Sessions'),
                    bottom: const TabBar(
                      tabs: [
                        Tab(text: 'Tasks'),
                        Tab(text: 'Tags'),
                        Tab(text: 'Subjects'),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      TaskView(userID: userID, taskProvider: holder.forScreen('tasks'), subjectProvider: holder.forScreen('subjects'), tagProvider: Provider.of<ModelProviderHolder>(context).forScreen('tags')),
                      TagView(userID: userID, tagProvider: holder.forScreen('tags'),),
                      SubjectView(userID: userID,subjectProvider: holder.forScreen('subjects'))
                    ],
                  ),
                ),
          );
        }
      )
    );
  }
}

