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
  String? otherCollaborator;

  Note({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.createdNote,
    this.updatedNote,
    this.otherCollaborator,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'createdNote': createdNote.toIso8601String(),
      'updatedNote': updatedNote?.toIso8601String(),
      'otherCollaborator': otherCollaborator,
    };
  }
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Hive Notepad',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
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
          content: Text("Create PIN", textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Accept"),
            ),
          ],
        ),
      );
    });
  }

  void modalProperties({required String createdNote, String? updatedNote, required String imageUrl}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Properties",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.0),
              Text(
                "Created Note",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400
                ),  
              ),
              SizedBox(height: 8.0),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 4.0),
                  child: Text(
                    "$createdNote",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),  
                ),
              ),
              if (updatedNote != null) ...[
                SizedBox(height: 16.0),
                Text(
                  "Updated Note : $updatedNote",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400
                  ),  
                ),
                SizedBox(height: 8.0),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: Text(
                      "$updatedNote",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),  
                  ),
                ),
              ],
              SizedBox(height: 16.0),
              Text(
                "Image Background URL",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400
                ),  
              ),
              SizedBox(height: 8.0),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 4.0),
                  child: Text(
                    "$imageUrl",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),  
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
        title: Text(
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
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintText: "Search for Notes",
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) => SizedBox(height: 8.0),
                  itemCount: notesBox.length,
                  itemBuilder: (context, index) {
                    final noteMap = notesBox.getAt(index) as Map<dynamic, dynamic>?;

                    if (noteMap == null) {
                      return SizedBox();
                    }

                    final noteKey = notesBox.keyAt(index) as int;
                    final titleNote = noteMap['title'] as String? ?? '';
                    final descriptionNote = noteMap['description'] as String? ?? '';
                    final imageUrlNote = noteMap['imageUrl'] as String? ?? '';
                    final dataStringCreatedNote = noteMap['createdNote'] as String?;
                    final dataStringUpdatedNote = noteMap['updatedNote'] as String?;
                    final createdNote = dataStringCreatedNote != null ? DateTime.parse(dataStringCreatedNote) : DateTime.now();
                    final updatedNote = dataStringUpdatedNote != null ? DateTime.parse(dataStringUpdatedNote) : null;
                    final otherCollaboratorNote = noteMap['otherCollaborator'] as String? ?? '';

                    int collaboratorCount = 0;

                    if (otherCollaboratorNote != null && otherCollaboratorNote.isNotEmpty) {
                      collaboratorCount = otherCollaboratorNote.split(',').length;
                    }
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
                              imageUrlNote: imageUrlNote,
                              createdNote: createdNote,
                              updatedNote: updatedNote,
                              otherCollaboratorNote: otherCollaboratorNote,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  imageUrlNote,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
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
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    dateTime,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                right: 52,
                                child: IconButton(
                                  icon: Icon(Icons.info, color: Colors.white),
                                  onPressed: () {
                                    modalProperties(createdNote : DateFormat.yMd().add_Hms().format(createdNote),
                                    updatedNote: updatedNote != null ? DateFormat.yMd().add_Hms().format(updatedNote) : null,
                                    imageUrl: imageUrlNote);
                                  },
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.white),
                                  onPressed: () {
                                    notesBox.deleteAt(index);
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(16.0),
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
                                        Text(
                                          collaboratorCount > 0 ? '+ more' : '',
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
                              Positioned(
                                top: 0,
                                left: 20,
                                child: Container(
                                  height: 40.0,
                                  width: 10.0,
                                  color: Colors.red,
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
            child: Icon(Icons.settings_outlined),
            label: 'Settings',
            shape: CircleBorder(),
            onTap: () {
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.add_card_outlined),
            label: 'Add',
            shape: CircleBorder(),
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
