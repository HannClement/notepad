import 'package:flutter/material.dart';

class DetailNote extends StatefulWidget {
  final int noteKey;
  String titleNote;
  String descriptionNote;
  String imageUrlNote;
  final DateTime createdNote;
  DateTime? updatedNote;
  String? otherCollaboratorNote;

  DetailNote({
    Key? key, required this.noteKey, required this.titleNote, required this.descriptionNote, required this.imageUrlNote, 
    required this.createdNote, this.updatedNote, this.otherCollaboratorNote
  }) : super(key: key);

  @override
  _DetailNoteState createState() => _DetailNoteState();
}

class _DetailNoteState extends State<DetailNote> {

  void modalCollaborator() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Other Collaborator",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.0),
                Text(
                widget.otherCollaboratorNote?.isNotEmpty == true ? widget.otherCollaboratorNote! : "No other collaborators",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Okay", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16.0)),
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
                icon : Icon(Icons.edit),
                onPressed: () {

                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.0),
            Text(
              widget.titleNote,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              widget.descriptionNote,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
