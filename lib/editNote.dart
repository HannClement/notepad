import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ChangeNote extends StatefulWidget {
  final int noteKey;
  String titleNote;
  String descriptionNote;
  String imageUrlNote;
  DateTime? updatedNote;
  String? otherCollaboratorNote;

  ChangeNote({
    Key? key,
    required this.noteKey,
    required this.titleNote,
    required this.descriptionNote,
    required this.imageUrlNote,
    this.updatedNote,
    this.otherCollaboratorNote,
  }) : super(key: key);

  @override
  _ChangeNoteState createState() => _ChangeNoteState();
}

class _ChangeNoteState extends State<ChangeNote> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController imageUrlController;
  late TextEditingController emailCollaboratorController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.titleNote);
    descriptionController = TextEditingController(text: widget.descriptionNote);
    imageUrlController = TextEditingController(text: widget.imageUrlNote);
    emailCollaboratorController = TextEditingController(text: widget.otherCollaboratorNote);
  }

  void modalCollaborator() {
  }

  void saveChanges() {
    var notesBox = Hive.box('notesBox');

    notesBox.putAt(
      widget.noteKey,
      {
        'title': titleController.text,
        'description': descriptionController.text,
        'imageUrl': imageUrlController.text,
        'updatedNote': DateTime.now().toIso8601String(),
        'otherCollaborator': emailCollaboratorController.text,
      },
    );

    Navigator.pop(context);
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
            icon: Icon(Icons.add_moderator_outlined),
            onPressed: () {
              modalCollaborator();
            },
          ),
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              saveChanges();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
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
            SizedBox(height: 16.0),
            Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
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
            SizedBox(height: 16.0),
            Text(
              'Image URL',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
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
