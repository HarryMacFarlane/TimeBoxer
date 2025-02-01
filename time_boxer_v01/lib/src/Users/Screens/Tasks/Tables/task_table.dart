import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_boxer_v01/src/Providers/model_provider.dart';
import '../../../../Providers/model_objects.dart';
import '../pop_creator.dart';


class TaskTableWidget extends StatelessWidget {
  final List<ModelObject> models;
  final List<String> fields;
  final String Function(String newTask) subjectGetter;
  final String Function(String tagID) tagGetter;

  const TaskTableWidget({
    Key? key,
    required this.models,
    required this.fields,
    required this.subjectGetter,
    required this.tagGetter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (models.isEmpty) return Text('No data found');
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: 
        
      DataTable(
        columns:
          [
            ...fields.map((name) => DataColumn(label: Text(name))),
            const DataColumn(label: Text('Actions')),
          ],
        rows: models
            .map(
              (model) => DataRow(cells: [ ...fields.map((name){
                Map<String, dynamic> modelMap = model.toMap();
                // THis line is kind of messed up, as I need to make sure to make the JS array into a list here, could be fixed with dedicated model objs and overrides
                if (name == 'Tags') {return DataCell(Text(modelMap[name].map((tag) {tagGetter(tag);}).join(', ')));} // Returns the tags as string (comma seperated)
                else if (name == 'Subject') {return DataCell(Text(subjectGetter(modelMap[name])));}
                return DataCell(Text(modelMap[name].toString()));
              }
              
              
              ), // Make sure to modify this in future to be able to handle not text fields in future!
                DataCell(Row(
                  children: [
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => 
                        Provider.of<ModelProvider>(context, listen: false).deleteModel(model)
                      ,
                      child: const Text('Delete'),
                    ),
                  ],
                )),
              ]),
            )
            .toList(),
      ),
    );
  }
}