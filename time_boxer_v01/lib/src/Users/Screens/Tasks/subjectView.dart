import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_boxer_v01/src/Providers/model_provider.dart';
import 'pop_creator.dart';
import 'Tables/basic_tables.dart';

class SubjectView extends StatelessWidget {
  final String userID;
  final ModelProvider subjectProvider;

  SubjectView({super.key, required this.userID, required this.subjectProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ModelProvider>.value(
      value: subjectProvider,
      child: Consumer<ModelProvider>(
        builder: (context, subjectProvider, child) =>
          Column(children: [
            ElevatedButton(onPressed:() async {
              await showDialog(context: context, builder: (context) => AlertDialog(content: MapInputDialog(initialData: {'Name':'', 'Description':''}, onSubmit: (Map<String, dynamic> data) => subjectProvider.addModel(data, "users/$userID/subjects"))));
              await subjectProvider.notify();
            }, child: Text('New Subject')),
            Expanded(child: 
              TableWidget(
                models: subjectProvider.toDisplay(),
                fields: ['Name', 'Description'],)),
          ],)
      ),
    );
  }
}
