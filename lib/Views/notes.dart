import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lejoje/JsonModels/note_model.dart';
import 'package:lejoje/SQLite/sqlite.dart';
import 'package:lejoje/Views/create_note.dart';

class Notes extends StatefulWidget {
  const Notes({Key? key}) : super(key: key);

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  late DatabaseHelper handler;
  late Future<List<NoteModel>> notes;
  final db = DatabaseHelper();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final phoneNumber = TextEditingController();
  final keyword = TextEditingController();

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    notes = handler.getChildren();
    handler.initDB().whenComplete(() {
      setState(() {
        notes = getAllNotes();
      });
    });
  }

  Future<List<NoteModel>> getAllNotes() {
    return handler.getChildren();
  }

  Future<List<NoteModel>> searchNote() {
    return handler.searchChildren(keyword.text);
  }

  Future<void> _refresh() async {
    setState(() {
      notes = getAllNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Children"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNote()),
          ).then((value) {
            if (value != null && value as bool) {
              _refresh();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextFormField(
              controller: keyword,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    notes = searchNote();
                  });
                } else {
                  setState(() {
                    notes = getAllNotes();
                  });
                }
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                icon: Icon(Icons.search),
                hintText: "Search",
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<NoteModel>>(
              future: notes,
              builder: (BuildContext context,
                  AsyncSnapshot<List<NoteModel>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No data"));
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else {
                  final items = snapshot.data!;
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        subtitle: Text(
                          DateFormat("yMd").format(
                            DateTime.parse(items[index].createdAt),
                          ),
                        ),
                        title: Text(
                          "${items[index].firstName}  ${items[index].lastName}  ${items[index].phoneNumber}",
                        ),
                        trailing: Checkbox(
                          value: items[index].visited,
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                items[index].visited = newValue;
                              });

                              db
                                  .updateVisitedStatus(
                                    items[index].userId!,
                                    newValue,
                                  )
                                  .then((_) {
                                    _refresh();
                                  })
                                  .catchError((error) {
                                    print('Error updating visited status: $error');
                                  });
                            }
                          },
                        ),
                        onTap: () {
                          setState(() {
                            firstName.text = items[index].firstName;
                            lastName.text = items[index].lastName;
                            phoneNumber.text = items[index].phoneNumber;
                          });
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                actions: [
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          db
                                              .updateChild(
                                                firstName.text,
                                                lastName.text,
                                                phoneNumber.text,
                                                items[index].userId,
                                              )
                                              .whenComplete(() {
                                                _refresh();
                                                Navigator.pop(context);
                                              });
                                        },
                                        child: const Text("Update"),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text("Confirm Deletion"),
                                                content: const Text("Are you sure you want to delete this child?"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text("Cancel"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      db.deleteChild(items[index].userId!).then((_) {
                                                        _refresh();
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
                                                            content: Text('Child deleted successfully'),
                                                          ),
                                                        );
                                                      }).catchError((error) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text('Failed to delete child: $error'),
                                                            backgroundColor: Colors.red,
                                                          ),
                                                        );
                                                      });
                                                    },
                                                    child: const Text("Delete"),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                    ],
                                  ),
                                ],
                                title: const Text("Update child"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      controller: firstName,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "First name is required";
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                        label: Text("First name"),
                                      ),
                                    ),
                                    TextFormField(
                                      controller: lastName,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "Last name is required";
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                        label: Text("Last name"),
                                      ),
                                    ),
                                    TextFormField(
                                      controller: phoneNumber,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "Phone number is required";
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                        label: Text("Phone number"),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
