import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:notepad/detailNote.dart';
import 'package:notepad/insertNote.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('notesBox');
  await Hive.openBox('settingsBox');
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
  const MainApp({super.key});

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
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Box<dynamic> notesBox;
  late Box<dynamic> settingsBox;

  @override
  void initState() {
    super.initState();
    notesBox = Hive.box('notesBox');
    settingsBox = Hive.box('settingsBox');

    String? pin = settingsBox.get('pin');
    if (pin == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        modalCreatePin();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        modalLoginPin();
      });
    }
  }

  String enteredPin = '';
  bool isPinVisible = false;

  Widget numButton(int number, void Function(void Function()) setStateDialog) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: TextButton(
        onPressed: () {
          setStateDialog(() {
            if (enteredPin.length < 4) {
              enteredPin += number.toString();
            }
          });
        },
        child: Text(
          number.toString(),
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void modalCreatePin() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16.0),
                    const Center(
                      child: Text(
                        'Create Your PIN',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Container(
                          margin: const EdgeInsets.all(6.0),
                          width: isPinVisible ? 50 : 16,
                          height: isPinVisible ? 50 : 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color: index < enteredPin.length
                                ? isPinVisible
                                    ? Colors.green
                                    : CupertinoColors.activeBlue
                                : CupertinoColors.activeBlue.withOpacity(0.1),
                          ),
                          child: isPinVisible && index < enteredPin.length
                              ? Center(
                                  child: Text(
                                    enteredPin[index],
                                    style: const TextStyle(
                                      fontSize: 17,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        );
                      }),
                    ),
                    const SizedBox(height: 16.0),
                    IconButton(
                      onPressed: () {
                        setStateDialog(() {
                          isPinVisible = !isPinVisible;
                        });
                      },
                      icon: Icon(
                        isPinVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                    SizedBox(height: isPinVisible ? 20.0 : 8.0),
                    for (var i = 0; i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            3,
                            (index) => numButton(1 + 3 * i + index, setStateDialog),
                          ).toList(),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const TextButton(onPressed: null, child: SizedBox()),
                          numButton(0, setStateDialog),
                          TextButton(
                            onPressed: () {
                              setStateDialog(() {
                                if (enteredPin.isNotEmpty) {
                                  enteredPin = enteredPin.substring(0, enteredPin.length - 1);
                                }
                              });
                            },
                            child: const Icon(
                              Icons.backspace,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            setStateDialog(() {
                              enteredPin = '';
                            });
                          },
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (enteredPin.length == 4) {
                              settingsBox.put('pin', enteredPin);
                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void modalLoginPin() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16.0),
                    const Center(
                      child: Text(
                        'Login with PIN',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Container(
                          margin: const EdgeInsets.all(6.0),
                          width: isPinVisible ? 50 : 16,
                          height: isPinVisible ? 50 : 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color: index < enteredPin.length
                                ? isPinVisible
                                    ? Colors.green
                                    : CupertinoColors.activeBlue
                                : CupertinoColors.activeBlue.withOpacity(0.1),
                          ),
                          child: isPinVisible && index < enteredPin.length
                              ? Center(
                                  child: Text(
                                    enteredPin[index],
                                    style: const TextStyle(
                                      fontSize: 17,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        );
                      }),
                    ),
                    const SizedBox(height: 16.0),
                    IconButton(
                      onPressed: () {
                        setStateDialog(() {
                          isPinVisible = !isPinVisible;
                        });
                      },
                      icon: Icon(
                        isPinVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                    SizedBox(height: isPinVisible ? 20.0 : 8.0),
                    for (var i = 0; i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            3,
                            (index) => numButton(1 + 3 * i + index, setStateDialog),
                          ).toList(),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const TextButton(onPressed: null, child: SizedBox()),
                          numButton(0, setStateDialog),
                          TextButton(
                            onPressed: () {
                              setStateDialog(() {
                                if (enteredPin.isNotEmpty) {
                                  enteredPin = enteredPin.substring(0, enteredPin.length - 1);
                                }
                              });
                            },
                            child: const Icon(
                              Icons.backspace,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            setStateDialog(() {
                              enteredPin = '';
                            });
                          },
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (enteredPin.length == 4) {
                              String? storedPin = settingsBox.get('pin');
                              if (enteredPin == storedPin) {
                                Navigator.pop(context);
                              } 
                              else {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text(
                                      'PIN Salah', 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                    ),
                                    content: const Text(
                                      'PIN yang Anda masukkan tidak cocok'
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void modalChangePin() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16.0),
                    const Center(
                      child: Text(
                        'Change Your PIN',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Container(
                          margin: const EdgeInsets.all(6.0),
                          width: isPinVisible ? 50 : 16,
                          height: isPinVisible ? 50 : 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color: index < enteredPin.length
                                ? isPinVisible
                                    ? Colors.green
                                    : CupertinoColors.activeBlue
                                : CupertinoColors.activeBlue.withOpacity(0.1),
                          ),
                          child: isPinVisible && index < enteredPin.length
                              ? Center(
                                  child: Text(
                                    enteredPin[index],
                                    style: const TextStyle(
                                      fontSize: 17,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        );
                      }),
                    ),
                    const SizedBox(height: 16.0),
                    IconButton(
                      onPressed: () {
                        setStateDialog(() {
                          isPinVisible = !isPinVisible;
                        });
                      },
                      icon: Icon(
                        isPinVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                    SizedBox(height: isPinVisible ? 20.0 : 8.0),
                    for (var i = 0; i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            3,
                            (index) => numButton(1 + 3 * i + index, setStateDialog),
                          ).toList(),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const TextButton(onPressed: null, child: SizedBox()),
                          numButton(0, setStateDialog),
                          TextButton(
                            onPressed: () {
                              setStateDialog(() {
                                if (enteredPin.isNotEmpty) {
                                  enteredPin = enteredPin.substring(0, enteredPin.length - 1);
                                }
                              });
                            },
                            child: const Icon(
                              Icons.backspace,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            setStateDialog(() {
                              enteredPin = '';
                            });
                          },
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (enteredPin.length == 4) {
                              settingsBox.put('pin', enteredPin);
                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void modalProperties({required String createdNote, String? updatedNote, required String imageUrl}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Properties",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              const Text(
                "Created Note",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400
                ),  
              ),
              const SizedBox(height: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    createdNote,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),  
                ),
              ),
              if (updatedNote != null) ...[
                const SizedBox(height: 16.0),
                const Text(
                  "Updated Note",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400
                  ),  
                ),
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(
                      updatedNote,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),  
                  ),
                ),
              ],
              const SizedBox(height: 16.0),
              const Text(
                "Image Background URL",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400
                ),  
              ),
              const SizedBox(height: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    imageUrl,
                    style: const TextStyle(
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
              child: const Text("Okay", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16.0)),
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
          'Notepad',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30.0,
            color: Colors.black,
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: notesBox.listenable(),
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

                    final map = noteMap.cast<String, dynamic>();
                    final noteKey = notesBox.keyAt(index) as int;

                    String title = map['title'] != null ? map['title'] as String : 'Default Title';
                    String description = map['description'] != null ? map['description'] as String : 'Default Description';
                    String imageUrl = map['imageUrl'] != null ? map['imageUrl'] as String : 'Default_Image_Url';
                    final DateTime createdNote = map['createdNote'] != null ? DateTime.parse(map['createdNote'] as String) : DateTime.now();
                    DateTime? updatedNote = map['updatedNote'] != null ? DateTime.parse(map['updatedNote'] as String) : null;
                    String? otherCollaborator = map['otherCollaborator'] as String?;

                    String dateTime;
                    if (updatedNote != null) {
                      dateTime = 'Updated: ${DateFormat.yMd().add_Hms().format(updatedNote)}';
                    } else {
                      dateTime = 'Created: ${DateFormat.yMd().add_Hms().format(createdNote)}';
                    }

                    int collaboratorCount = 0;

                    return GestureDetector(
                      onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailNote(
                            noteKey: noteKey,
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
                            notesBox.put(noteKey, {
                              'title': result['titleNote'] ?? title,
                              'description': result['descriptionNote'] ?? description,
                              'imageUrl': result['imageUrlNote'] ?? imageUrl,
                              'createdNote': createdNote.toIso8601String(),
                              'updatedNote': result['updatedNote'] != null
                                  ? DateTime.parse(result['updatedNote'] as String).toIso8601String()
                                  : null,
                              'otherCollaborator': result['otherCollaboratorNote'] ?? otherCollaborator,
                            });
                          });
                        }
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
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  imageUrl,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
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
                                      fontSize: 11,
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
                                    modalProperties(
                                      createdNote: DateFormat.yMd().add_Hms().format(createdNote),
                                      updatedNote: updatedNote != null
                                          ? DateFormat.yMd().add_Hms().format(updatedNote)
                                          : null,
                                      imageUrl: imageUrl,
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      notesBox.deleteAt(index);
                                    });
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
                                      title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const CircleAvatar(
                                          backgroundImage: NetworkImage('https://www.nespresso.com/ecom/medias/sys_master/public/13264482598942/supercharge-your-wfh-routine-body-image-4168x1797-1.jpg'),
                                          radius: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          collaboratorCount > 0 ? '+ more' : '',
                                          style: const TextStyle(
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
            child: const Icon(Icons.settings_outlined),
            label: 'Settings',
            shape: const CircleBorder(),
            onTap: () {
              modalChangePin();
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
                  builder: (context) => const DataNote(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
