import 'package:flutter/material.dart';
import 'package:lejoje/JsonModels/note_model.dart';
import 'package:lejoje/SQLite/sqlite.dart';

class CreateNote extends StatefulWidget {
  const CreateNote({Key? key}) : super(key: key);

  @override
  State<CreateNote> createState() => _CreateNoteState();
}

class _CreateNoteState extends State<CreateNote> {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final phoneNumber = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final db = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Child"),
        actions: [
          IconButton(
            onPressed: () {
              _saveNote();
            },
            icon: const Icon(Icons.check),
          )
        ],
      ),
      body: Center(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
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
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                      label: Text("First Name"),
                    ),
                  ),
                   const SizedBox(height: 10),
                  TextFormField(
                    controller: lastName,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Last name is required";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                      label: Text("Last Name"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: phoneNumber,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Phone number is required";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                      label: Text("Phone Number"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      _saveNote();
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("Save"),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // background
                      onPrimary: Colors.white, // foreground/text
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveNote() {
    if (formKey.currentState!.validate()) {
      db.createNote(
        NoteModel(
          firstName: firstName.text,
          lastName: lastName.text,
          phoneNumber: phoneNumber.text,
          createdAt: DateTime.now().toIso8601String(),
        ),
      ).whenComplete(() {
        Navigator.of(context).pop(true);
      });
    }
  }
}
