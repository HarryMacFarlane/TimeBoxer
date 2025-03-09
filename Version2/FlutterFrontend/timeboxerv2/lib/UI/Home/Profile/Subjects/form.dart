import 'package:flutter/material.dart';

class SubjectForm extends StatefulWidget {
  final String? initialName;
  final String? initialDescription;
  final Future<int> Function(Map<String, dynamic>) onSave;

  const SubjectForm({this.initialName, this.initialDescription, required this.onSave, Key? key}) : super(key: key);

  @override
  _SubjectFormState createState() => _SubjectFormState();
}

class _SubjectFormState extends State<SubjectForm> {
  final _formKey = GlobalKey<FormState>(); // Secure form submission
  late TextEditingController _nameController;
  late TextEditingController _descController;
  bool _isSaving = false; // Tracks async state
  bool _hasEditedName = false; // Tracks user edits
  bool _hasEditedDesc = false; // Tracks user edits
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _descController = TextEditingController(text: widget.initialDescription ?? '');

    _nameController.addListener(() => setState(() => _hasEditedName = true));
    _descController.addListener(() => setState(() => _hasEditedDesc = true));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    else if (!(_hasEditedDesc && _hasEditedName)){
      setState(() => _errorMessage = "No changes have been detected, please make changes before saving!");
      return;
    } // Prevent invalid submission
    setState(() => _isSaving = true);

    final Map<String, dynamic> formData = {
      if (_hasEditedName) 'name': _nameController.text.trim(),
      if (_hasEditedDesc) 'description': _descController.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Form(
          key: _formKey, // Secure form handling
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_errorMessage != null) Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) => (value == null || value.trim().isEmpty) ? "Name is required" : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 20),
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
    );
  }
}
