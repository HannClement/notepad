import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:notepad/detailNote.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('notesBox');
  runApp(const MainApp());
}

class Note {
  final String title;
  final String subtitle;
  final DateTime createdNote;
  DateTime updatedNote;

  Note({
    required this.title,
    required this.subtitle,
    required this.createdNote,
    required this.updatedNote,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'createdNote': createdNote.toIso8601String(),
      'updatedNote': updatedNote.toIso8601String(),
    };
  }
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive Notepad',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController subtitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: const Text("Create PIN", textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Accept"),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notepad',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30.0,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: ValueListenableBuilder(
          valueListenable: Hive.box('notesBox').listenable(),
          builder: (context, Box<dynamic> notesBox, _) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                  child: TextField(
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      hintText: "Search for Notes",
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => const SizedBox(height: 8.0),
                    itemCount: notesBox.length,
                    itemBuilder: (context, index) {
                      final noteMap = notesBox.getAt(index) as Map<dynamic, dynamic>?;

                      if (noteMap == null) {
                        return const SizedBox();
                      }

                      final noteKey = notesBox.keyAt(index) as int;
                      final titleNote = noteMap['title'] as String? ?? '';
                      final subtitleNote = noteMap['subtitle'] as String? ?? '';
                      final dataStringCreatedNote = noteMap['createdNote'] as String?;
                      final dataStringUpdatedNote = noteMap['updatedNote'] as String?;
                      final createdNote = dataStringCreatedNote != null ? DateTime.parse(dataStringCreatedNote) : DateTime.now();
                      final updatedNote = dataStringUpdatedNote != null ? DateTime.parse(dataStringUpdatedNote) : DateTime.now();

                      String formattedDate = updatedNote != null
                          ? DateFormat.yMd().add_Hms().format(updatedNote)
                          : DateFormat.yMd().add_Hms().format(createdNote);

                      String dateTime = updatedNote != null
                          ? 'Updated: $formattedDate'
                          : 'Created: $formattedDate';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailNote(
                                noteKey: noteKey,
                                titleNote: titleNote,
                                subtitleNote: subtitleNote,
                                createdNote: createdNote,
                                updatedNote: updatedNote,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 32.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  title: Text(
                                    titleNote,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(dateTime),
                                ),
                              ),
                              const SizedBox(width: 10),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: 'details',
                                    child: ListTile(
                                      leading: Icon(Icons.info),
                                      title: Text('Details'),
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: ListTile(
                                      leading: Icon(Icons.delete),
                                      title: Text('Delete'),
                                    ),
                                  ),
                                ],
                                onSelected: (String value) {
                                  if (value == 'delete') {
                                    setState(() {
                                      notesBox.deleteAt(index);
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.settings_outlined),
            label: 'Settings',
            shape: const CircleBorder(),
            onTap: () {
              
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.add_card_outlined),
            label: 'Add',
            shape: const CircleBorder(),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Add New Note'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 8.0),
                      TextField(
                        controller: subtitleController,
                        decoration: const InputDecoration(
                          labelText: 'Subtitle',
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        final title = titleController.text.trim();
                        final subtitle = subtitleController.text.trim();
                        if (title.isNotEmpty && subtitle.isNotEmpty) {
                          final createdNote = DateTime.now();
                          final updatedNote = DateTime.now();
                          final newNote = {
                            'title': title,
                            'subtitle': subtitle,
                            'createdNote': createdNote.toIso8601String(),
                            'updatedNote': updatedNote.toIso8601String(),
                          };
                          Hive.box('notesBox').add(newNote);
                          titleController.clear();
                          subtitleController.clear();
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
