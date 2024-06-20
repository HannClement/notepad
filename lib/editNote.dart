import 'package:flutter/material.dart';

class ChangeNote extends StatefulWidget {
  final int noteKey;
  String titleNote;
  String descriptionNote;
  String imageUrlNote;
  final DateTime createdNote;
  DateTime? updatedNote;
  String? otherCollaboratorNote;

  ChangeNote({
    Key? key, required this.noteKey, required this.titleNote, required this.descriptionNote, required this.imageUrlNote, 
    required this.createdNote, this.updatedNote, this.otherCollaboratorNote
  }) : super(key: key);

  @override
  _ChangeNoteState createState() => _ChangeNoteState();
}

class _ChangeNoteState extends State<ChangeNote> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
      ),
    );
  }
}