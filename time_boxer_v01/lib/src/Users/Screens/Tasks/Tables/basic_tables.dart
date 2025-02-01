import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_boxer_v01/src/Providers/model_provider.dart';
import '../../../../Providers/model_objects.dart';
import '../pop_creator.dart';

class TableWidget extends StatelessWidget {
  final List<ModelObject> models;
  final List<String> fields;

  const TableWidget({
    Key? key,
    required this.models,
    required this.fields,
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
              (model) => DataRow(cells: [ ...fields.map((name) => DataCell(Text(model.toMap()[name]))), // Make sure to modify this in future to be able to handle not text fields in future!
                DataCell(Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await showDialog(context: context, builder: (context) => AlertDialog(content: MapInputDialog(initialData: model.toMap(), onSubmit: model.update,)));
                      },
                      child: const Text('Edit'),
                    ),
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
