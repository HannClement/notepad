import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:validators/validators.dart' as validator;

class DataNote extends StatefulWidget {
  const DataNote({Key? key}) : super(key: key);

  @override
  _DataNoteState createState() => _DataNoteState();
}

class _DataNoteState extends State<DataNote> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController emailCollaboratorController = TextEditingController();

  void modalCollaborator() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Add Other Collaborator",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLines: 7,
                minLines: 1,
                controller: emailCollaboratorController,
                decoration: InputDecoration(
                  labelText: "Collaborator Email (Optional)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16.0)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Add", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16.0)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Note',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.add_moderator_outlined),
                onPressed: () {
                  modalCollaborator();
                },
              ),
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  final String title = titleController.text;
                  final String description = descriptionController.text;
                  String imageUrl = imageUrlController.text;
                  final String otherCollaborator = emailCollaboratorController.text;

                  if (title.isNotEmpty && description.isNotEmpty) {
                    if (imageUrl.isEmpty || !validator.isURL(imageUrl)) {
                      imageUrl = "https://www.nespresso.com/ecom/medias/sys_master/public/13264484958238/supercharge-your-wfh-routine-body-image-4168x1797-2.jpg";
                    }

                    final newNote = {
                      'title': title,
                      'description': description,
                      'imageUrl': imageUrl,
                      'createdNote': DateTime.now().toIso8601String(),
                      'otherCollaborator': otherCollaborator,
                    };
                    final notesBox = Hive.box('notesBox');
                    notesBox.add(newNote);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
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
