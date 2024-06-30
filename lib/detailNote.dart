import 'package:flutter/material.dart';
import 'package:notepad/editNote.dart';

class DetailNote extends StatefulWidget {
  final int noteKey;
  final String titleNote;
  final String descriptionNote;
  final String imageUrlNote;
  final DateTime? updatedNote;
  final String? otherCollaboratorNote;

  const DetailNote({super.key, 
    required this.noteKey,
    required this.titleNote,
    required this.descriptionNote,
    required this.imageUrlNote,
    this.updatedNote,
    this.otherCollaboratorNote,
  });

  @override
  _DetailNoteState createState() => _DetailNoteState();
}

class _DetailNoteState extends State<DetailNote> {
  late String title;
  late String description;
  late String imageUrl;
  late DateTime? updatedNote;
  late String? otherCollaborator;

  @override
  void initState() {
    super.initState();
    title = widget.titleNote;
    description = widget.descriptionNote;
    imageUrl = widget.imageUrlNote;
    updatedNote = widget.updatedNote;
    otherCollaborator = widget.otherCollaboratorNote;
  }

  void modalCollaborator() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Other Collaborator",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8.0),
              Text(
                otherCollaborator != null && otherCollaborator!.isNotEmpty
                    ? '$otherCollaborator'
                    : "No other collaborators",
                style: const TextStyle(
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
              child: const Text(
                "Okay",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
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
          'Detail Note',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.add_moderator_outlined),
                onPressed: () {
                  modalCollaborator();
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNote(
                        noteKey: widget.noteKey,
                        titleNote: title,
                        descriptionNote: description,
                        imageUrlNote: imageUrl,
                        updatedNote: updatedNote,
                        otherCollaboratorNote: otherCollaborator,
                      ),
                    ),
                  );
                  if (result != null && result is Map<String, dynamic>) {
                    setState(() {
                      title = result['titleNote'];
                      description = result['descriptionNote'];
                      imageUrl = result['imageUrlNote'];
                      updatedNote = result['updatedNote'] != null
                          ? DateTime.parse(result['updatedNote'])
                          : updatedNote;
                      otherCollaborator = result['otherCollaboratorNote'];
                    });
                    Navigator.pop(context, result);
                  }
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
            const SizedBox(height: 8.0),
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              description,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
