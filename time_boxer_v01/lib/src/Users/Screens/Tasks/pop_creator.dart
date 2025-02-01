import 'package:flutter/material.dart';

class MapInputDialog extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Future<void> Function(Map<String, dynamic>) onSubmit;

  const MapInputDialog({
    Key? key,
    required this.initialData,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _MapInputDialogState createState() => _MapInputDialogState();
}

class _MapInputDialogState extends State<MapInputDialog> {
  late Map<String, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = {
      for (var key in widget.initialData.keys)
        key: TextEditingController(text: widget.initialData[key]?.toString() ?? ''),
    };
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() async {
    final Map<String, dynamic> result = {
      for (var key in controllers.keys) key: controllers[key]!.text,
    };
    await widget.onSubmit(result);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Data'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: controllers.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: entry.value,
                decoration: InputDecoration(labelText: entry.key),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}