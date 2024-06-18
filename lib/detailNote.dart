import 'package:flutter/material.dart';

class DetailNote extends StatefulWidget {
  const DetailNote({Key? key}) : super(key: key);

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
