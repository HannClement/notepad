import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:notepad/detailNote.dart';
import 'package:notepad/insertNote.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('notesBox');
  runApp(const MainApp());
}

class Note {
  String title;
  String description;
  String imageUrl;
  final DateTime createdNote;
  DateTime? updatedNote;

  Note({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.createdNote,
    this.updatedNote,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'createdNote': createdNote.toIso8601String(),
      'updatedNote': updatedNote?.toIso8601String(),
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
      body: ValueListenableBuilder(
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
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(height: 8.0),
                  itemCount: notesBox.length,
                  itemBuilder: (context, index) {
                    final noteMap = notesBox.getAt(index) as Map<dynamic, dynamic>?;

                    if (noteMap == null) {
                      return const SizedBox();
                    }

                    final noteKey = notesBox.keyAt(index) as int;
                    final titleNote = noteMap['title'] as String? ?? '';
                    final descriptionNote = noteMap['description'] as String? ?? '';
                    // final imageUrlNote = noteMap['imageUrl'] as String? ?? 'https://binus.ac.id/binusian-journey/wp-content/uploads/2023/01/Apa-itu-team-work.jpg';
                    final dataStringCreatedNote = noteMap['createdNote'] as String?;
                    final dataStringUpdatedNote = noteMap['updatedNote'] as String?;
                    final createdNote = dataStringCreatedNote != null ? DateTime.parse(dataStringCreatedNote) : DateTime.now();
                    final updatedNote = dataStringUpdatedNote != null ? DateTime.parse(dataStringUpdatedNote) : null;

                    String dateTime;
                    if (updatedNote != null) {
                      dateTime = 'Updated: ${DateFormat.yMd().add_Hms().format(updatedNote)}';
                    } else {
                      dateTime = 'Created: ${DateFormat.yMd().add_Hms().format(createdNote)}';
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailNote(
                              noteKey: noteKey,
                              titleNote: titleNote,
                              descriptionNote: descriptionNote,
                              // imageUrlNote: imageUrlNote,
                              createdNote: createdNote,
                              updatedNote: updatedNote,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [Colors.black54, Colors.transparent],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    stops: [0.0, 0.7],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    dateTime,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                right: 52,
                                child: IconButton(
                                  icon: const Icon(Icons.info, color: Colors.white),
                                  onPressed: () {
                                    
                                  },
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.white),
                                  onPressed: () {
                                    notesBox.deleteAt(index);
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      titleNote,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage('https://www.nespresso.com/ecom/medias/sys_master/public/13264482598942/supercharge-your-wfh-routine-body-image-4168x1797-1.jpg'),
                                          radius: 12,
                                        ),
                                        SizedBox(width: 4),
                                        CircleAvatar(
                                          backgroundImage: NetworkImage('https://www.nespresso.com/ecom/medias/sys_master/public/13264482598942/supercharge-your-wfh-routine-body-image-4168x1797-1.jpg'),
                                          radius: 12,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '+1',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DataNote(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
