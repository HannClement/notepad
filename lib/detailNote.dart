import 'package:flutter/material.dart';

class DetailNote extends StatefulWidget {
  final int noteKey;
  final String titleNote;
  final String subtitleNote;
  final DateTime createdNote;
  final DateTime? updatedNote;

  const DetailNote({Key? key, required this.noteKey, required this.titleNote, required this.subtitleNote, required this.createdNote,  this.updatedNote}) : super(key: key);
  @override
  _DetailNoteState createState() => _DetailNoteState();
}

class _DetailNoteState extends State<DetailNote> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Note'),
      ),
      body: Center(
        child: Text('Detail Note Content'),
      ),
    );
  }
}
