import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ChangeNote extends StatefulWidget {
  final int noteKey;
  final String titleNote;
  final String descriptionNote;
  final String imageUrlNote;
  final DateTime? updatedNote;
  final String? otherCollaboratorNote;

  const ChangeNote({super.key, 
    required this.noteKey,
    required this.titleNote,
    required this.descriptionNote,
    required this.imageUrlNote,
    this.updatedNote,
    this.otherCollaboratorNote,
  });

  @override
  _ChangeNoteState createState() => _ChangeNoteState();
}

class _ChangeNoteState extends State<ChangeNote> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController imageUrlController;
  late TextEditingController collaboratorController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.titleNote);
    descriptionController = TextEditingController(text: widget.descriptionNote);
    imageUrlController = TextEditingController(text: widget.imageUrlNote);
    collaboratorController = TextEditingController(text: widget.otherCollaboratorNote ?? '');
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
    collaboratorController.dispose();
    super.dispose();
  }

  void updateNoteInHive() {
    final notesBox = Hive.box('notesBox');

    final Map<String, dynamic> updatedData = {
      'titleNote': titleController.text,
      'descriptionNote': descriptionController.text,
      'imageUrlNote': imageUrlController.text,
      'updatedNote': DateTime.now().toIso8601String(),
      'otherCollaboratorNote': collaboratorController.text,
    };

    notesBox.put(widget.noteKey, updatedData);

    Navigator.pop(context, updatedData);
  }

  void modalCollaborator() {
    collaboratorController.text = widget.otherCollaboratorNote ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Edit Collaborator",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLines: 7,
                minLines: 1,
                controller: collaboratorController,
                decoration: const InputDecoration(
                  labelText: "Collaborator Email (Optional)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16.0)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, collaboratorController.text);
              },
              child: const Text("Save", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16.0)),
            ),
          ],
        );
      },
    ).then((result) {
      if (result != null) {
        setState(() {
          collaboratorController.text = result;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Note',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_moderator_outlined),
            onPressed: () {
              modalCollaborator();
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              updateNoteInHive();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Title',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                hintText: 'Enter your title',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: descriptionController,
              maxLines: null,
              minLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                hintText: 'Enter your description',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Image URL',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: imageUrlController,
              maxLines: 5,
              minLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                hintText: 'Enter image URL',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
