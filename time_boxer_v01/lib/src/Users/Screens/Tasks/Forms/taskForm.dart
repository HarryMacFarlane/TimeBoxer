import 'package:flutter/material.dart';
import 'package:time_boxer_v01/src/Providers/model_objects.dart';

class TaskFormWidget extends StatefulWidget {
  final List<ModelObject> subjects;
  final List<ModelObject> tags;
  final Future<void> Function(Map<String, dynamic> newTask) onSubmit;

  const TaskFormWidget({
    Key? key,
    required this.subjects,
    required this.tags,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _TaskFormWidgetState createState() => _TaskFormWidgetState();
}

class _TaskFormWidgetState extends State<TaskFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _expectedCompletionTimeController = TextEditingController();

  ModelObject? _selectedSubject;
  final List<ModelObject> _selectedTags = [];

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    _expectedCompletionTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create a new task'),
      content: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _taskNameController,
                decoration: const InputDecoration(labelText: 'Task Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task name';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<ModelObject>(
                decoration: const InputDecoration(labelText: 'Subject'),
                value: _selectedSubject,
                items: widget.subjects.map((subject) {
                  return DropdownMenuItem<ModelObject>(
                    value: subject,
                    child: Text(subject.toMap()['Name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubject = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a subject';
                  }
                  return null;
                },
              ),
              Wrap(
                spacing: 8.0,
                children: widget.tags.map((tag) {
                  Map<String, dynamic> tagMap = tag.toMap();
                  return FilterChip(
                    label: Text(tagMap['Tag']),
                    selected: _selectedTags.contains(tag),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _expectedCompletionTimeController,
                decoration: const InputDecoration(labelText: 'Expected Completion Time (in hours)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an expected completion time';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
    actions: [
      ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    Map<String, dynamic> newTask = {
                      'Name': _taskNameController.text,
                      'Subject': _selectedSubject!.docID,
                      'Tags': _selectedTags.map((tag) => tag.docID).toList(),
                      'Completion Time': int.parse(_expectedCompletionTimeController.text),
                      'Description': _descriptionController.text,
                      'Completed': false,
                    };

                    await widget.onSubmit(newTask);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Submit'),
              ),
    ],
    );
  }
}
