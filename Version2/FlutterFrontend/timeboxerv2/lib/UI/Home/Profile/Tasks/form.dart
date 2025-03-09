import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TaskForm extends StatefulWidget {
  final String? initialName;
  final String? initialDescription;
  final String? initialDeadline;
  final String? initialExpectedCompletion;
  final String? initialPriority;
  final String? initialSubject;
  final List<String>? initialTags;
  final List<Map<String, String>> tags;
  final List<Map<String, String>> subjects;
  final Future<int> Function(Map<String, dynamic>) onSave;

  const TaskForm({this.initialName, this.initialDescription, this.initialDeadline, this.initialExpectedCompletion, this.initialPriority, this.initialSubject, this.initialTags, required this.subjects, required this.tags, required this.onSave, Key? key}) : super(key: key);

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>(); // Secure form submission
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _deadlineController;
  late TextEditingController _expectedCompletionController;

  int? _selectedPriority;
  String? _selectedSubject;
  final List<String>? _selectedTags = [];


  bool _isSaving = false; // Tracks async state
  bool _hasEditedName = false; // Tracks user edits
  bool _hasEditedDesc = false; // Tracks user edits
  bool _hasEditedDeadline = false;
  bool _hasEditedExpectedCompletion = false;
  bool _hasEditedPriority = false;
  bool _hasEditedTags = false;
  bool _hasEditedSubject = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _descController = TextEditingController(text: widget.initialDescription ?? '');
    _deadlineController = TextEditingController(text: widget.initialDeadline ?? '');
    _expectedCompletionController = TextEditingController(text: widget.initialExpectedCompletion ?? '');

    _nameController.addListener(() => setState(() => _hasEditedName = true));
    _descController.addListener(() => setState(() => _hasEditedDesc = true));
    _deadlineController.addListener(() => setState(() => _hasEditedDeadline = true));
    _expectedCompletionController.addListener(() => setState(() => _hasEditedExpectedCompletion = true));

    _selectedSubject = widget.initialSubject ?? "";
    _selectedTags?.addAll(widget.initialTags ?? []);
    _selectedPriority = int.tryParse(widget.initialPriority ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _deadlineController.dispose();
    _expectedCompletionController.dispose();
    super.dispose();
  }

  bool _hasBeenEdited() {
    return _hasEditedName || _hasEditedDesc || _hasEditedDeadline || _hasEditedExpectedCompletion || _hasEditedPriority || _hasEditedTags || _hasEditedSubject;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    else if (!(_hasBeenEdited())){
      setState(() => _errorMessage = "No changes have been detected, please make changes before saving!");
      return;
    } // Prevent invalid submission
    setState(() => _isSaving = true);

    final Map<String, dynamic> formData = {
        if (_hasEditedName) 'name': _nameController.text.trim(),
        if (_hasEditedDesc) 'description': _descController.text.trim(),
        if (_hasEditedDeadline) 'deadline': _deadlineController.text.trim(),
        if (_hasEditedExpectedCompletion) 'expected_completion_time': _expectedCompletionController.text.trim(),
        if (_hasEditedPriority) 'priority_level': _selectedPriority,
        if (_hasEditedSubject) 'subject_id': _selectedSubject,
        if (_hasEditedTags) 'tag_ids': _selectedTags,
    };

    int responseCode = await widget.onSave(formData); // Await async operation
    if (mounted && responseCode < 300) {
      Navigator.pop(context);
    }
    else {
      setState(() {
        _errorMessage = "Error saving data: $responseCode";
        _isSaving = false;
      });
    }
  }

  Future<bool> _confirmExit() async {
    if (!_hasEditedDesc || !_hasEditedName) return true; // No changes, exit freely

    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Discard Changes?"),
        content: const Text("You have unsaved changes. Are you sure you want to exit?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Discard")),
        ],
      ),
    ) ?? false;
  }

  Future<void> _selectDeadline(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _deadlineController.text = "${picked.toLocal()}".split(' ')[0];
        _hasEditedDeadline = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Form(
          key: _formKey, // Secure form handling
          child: 
          SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_errorMessage != null) Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Task Name", border: OutlineInputBorder(),),
                validator: (value) => (value == null || value.trim().isEmpty) ? "Task name is required" : null,
              ),
              // Description
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder(),),
              ),
              // Deadline
              TextFormField(
                controller: _deadlineController,
                readOnly: true,
                onTap: () => _selectDeadline(context),
                decoration: InputDecoration(
                  labelText: "Select Deadline",
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
              ),
              // Expected Completion
              TextFormField(
                controller: _expectedCompletionController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: "Expected Completion",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a number";
                  }
                  final intValue = int.tryParse(value);
                  if (intValue == null) {
                    return "Invalid number";
                  }
                  return null;
                },
              ),
              // Priority
              DropdownButtonFormField<int>(
                value: _selectedPriority,
                decoration: InputDecoration(
                  labelText: "Priority"
                ),
                items: [
                  DropdownMenuItem<int>(
                    value: 1,
                    child: Text("Low"),
                  ),
                  DropdownMenuItem<int>(
                    value: 2,
                    child: Text("Medium"),
                  ),
                  DropdownMenuItem<int>(
                    value: 3,
                    child: Text("High"),
                  ),
                ],
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedPriority = newValue;
                    _hasEditedPriority = true;
                  });
                },   
              ),
              // Subject Selection
              DropdownButtonFormField<String>(
                value: (_selectedSubject == null)
                  ? (widget.subjects.first['id']) // Default to first item if null
                  : null, // Ensure value is null if list is empty,
                decoration: InputDecoration(
                  labelText: "Select Subject",
                  border: OutlineInputBorder(),
                ),
                items: widget.subjects.map((item) {
                  return DropdownMenuItem<String>(
                    value: item['id'],
                    child: Text(item["name"]!),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null && newValue != _selectedSubject) {
                    setState(() {
                      _selectedSubject = newValue;
                      _hasEditedSubject = true;
                    });
                  }
                },
              ),
              // Tag Selection
              Row(
                children: widget.tags.map((tag) {
                  return CheckboxListTile(
                    title: Text(tag['tag_name']!),
                    value: _selectedTags?.contains(tag['id']),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedTags?.add(tag['id']!);
                          _hasEditedTags = true;
                        }
                        else {
                          _selectedTags?.remove(tag['id']);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () async {
                      if (await _confirmExit()) Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("Save Changes"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    ),
    );
  }
}
