import 'package:flutter/material.dart';
import '../../../Providers/model_provider.dart';
import 'package:provider/provider.dart';
import 'pop_creator.dart';
import 'Tables/basic_tables.dart';


class TagView extends StatelessWidget {
  final String userID;
  final ModelProvider tagProvider;

  const TagView({super.key, required this.userID, required this.tagProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ModelProvider>.value(
      value: tagProvider,
      child: Consumer<ModelProvider>(
        builder: (context, tagProvider, child) =>
          Column(children: [
            ElevatedButton(onPressed:() async {
              await showDialog(context: context, builder: (context) => AlertDialog(content: MapInputDialog(initialData: {'Tag':'', 'Description':''}, onSubmit: (Map<String, dynamic> data) async => await tagProvider.addModel(data, "users/$userID/tags"))));
              await tagProvider.notify();
            }, child: Text('New Tag')),
            Expanded(child: 
              TableWidget(
                models: tagProvider.toDisplay(),
                fields: ['Tag', 'Description'],)),
          ],)
      ),
    );
  }
}
