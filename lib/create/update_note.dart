import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:digihydro/mainpages/notes_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class updateNote extends StatefulWidget {
  const updateNote({Key? key, required this.noteKey}) : super(key: key);

  final String noteKey;

  @override
  _updateNote createState() => _updateNote();
}

class _updateNote extends State<updateNote> {
  TextEditingController title = TextEditingController();
  TextEditingController userDate = TextEditingController();
  TextEditingController userNote = TextEditingController();

  late DatabaseReference fb;
  void initState() {
    super.initState();
    fb = FirebaseDatabase.instance.ref().child('Notes');
  }

  void getNotesData() async {
    DataSnapshot snapshot = await fb.child(widget.noteKey).get();
    Map note = snapshot.value as Map;

    title.text = note['title'];
    userDate.text = note['date'];
    userNote.text = note['userNote'];
  }

  @override
  Widget build(BuildContext context) {
    var rng = Random();
    var num = rng.nextInt(10000);

    final FirebaseAuth _auth = FirebaseAuth.instance;

    final currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 201, 237, 220),
      appBar: AppBar(
        title: Container(
          child: Text(
            "Create Note",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ),
      body: Form(
        child: Container(
          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: ListView(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 20, top: 10),
                    child: Text(
                      "Add Notes",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 50, left: 10, right: 10),
                child: TextField(
                  controller: title,
                  decoration: InputDecoration(
                    hintText: 'Title:',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: const EdgeInsets.all(10.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                child: TextField(
                  controller: userDate,
                  decoration: InputDecoration(
                    icon: Icon(Icons.calendar_today_rounded),
                    labelText: 'Date Today:',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: const EdgeInsets.all(10.0),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(3000),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        userDate.text =
                            DateFormat('MM-dd-yyyy').format(pickedDate);
                      });
                    }
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                child: TextField(
                  controller: userNote,
                  keyboardType: TextInputType.multiline,
                  maxLines: 10,
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 15,
                  ),
                  decoration: new InputDecoration(
                    hintText: "Write your note...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.fromLTRB(200, 25, 30, 0),
                  child: ElevatedButton(
                    child: Text('UPDATE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
                      textStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      Map<String, String> note = {
                        'title': title.text,
                        'date': userDate.text,
                        'userNote': userNote.text,
                      };
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => notesPage()));
                    },
                  )
                  /*child: RaisedButton(
                  padding: EdgeInsets.fromLTRB(25, 10, 25, 10), //
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)), //
                  color: Colors.redAccent, //
                  child: Text(
                    "POST", //
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {},
                ),*/
                  )
            ],
          ),
          //decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        ),
      ),
    );
  }
}
