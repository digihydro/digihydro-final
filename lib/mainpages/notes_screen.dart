import 'dart:convert';
import 'dart:io';
import 'package:digihydro/enums/enums.dart';
import 'package:digihydro/model/snapshot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:jiffy/jiffy.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:digihydro/create/create_note.dart';
import 'package:digihydro/drawer_screen.dart';
import 'history_screen.dart';


class notesPage extends StatefulWidget {
  @override
  displayNote createState() => displayNote();
}

class displayNote extends State<notesPage> {
  final DatabaseReference refDevice = FirebaseDatabase.instance.ref('Devices');
  final DatabaseReference destinationReference = FirebaseDatabase.instance.ref().child('noteStats');
  final FirebaseAuth auth = FirebaseAuth.instance;
  late String currentUserID;
  late String imageUrl;
  final DatabaseReference ref = FirebaseDatabase.instance.ref('Notes');
  var k;

  Future<void> FetchData() async {
    refDevice.once().then((event) {
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? sourceData = snapshot.value as Map<dynamic, dynamic>?;

      destinationReference.set(sourceData);

    }).catchError((error) {
      // Handle any errors that occur during the read operation
    });
  }

  TextEditingController title = TextEditingController();
  TextEditingController userDate = TextEditingController();
  TextEditingController userNote = TextEditingController();

  String imageUrl2 = '';
  File? _imageFile;

  Future<void> _pickImage() async {
    ImagePicker imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        imageUrl2 = '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      currentUserID = currentUser.uid;
    }
  }

  Future<void> upd() async {
    DatabaseReference ref1 = FirebaseDatabase.instance.ref("Notes/$k");

    await ref1.update({
      "title": title.text,
      "date": userDate.text,
      "userNote": userNote.text,
      "imageUrl": imageUrl2,
    });
    title.clear();
    userDate.clear();
    userNote.clear();
    imageUrl2 = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 201, 237, 220),
      drawer: drawerPage(),
      appBar: AppBar(
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 40.00,
        ),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(0, 5, 15, 0),
            child: Align(
              child: Image.asset(
                'images/logo_white.png',
                scale: 8,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            child: Row(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                        child: Icon(
                          Icons.sticky_note_2_outlined,
                          size: 50,
                          color: Colors.green,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 10, 5, 10),
                        child: Text(
                          'My Notes',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  child: Icon(
                    Icons.account_circle,
                    size: 50,
                    color: Colors.grey[500],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "What's on your mind?",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => createNote(
                            isEdit: false,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FirebaseAnimatedList(
              query: ref.orderByChild('userId').equalTo(currentUserID),
              itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {
                var snapshot_list = jsonDecode(snapshot.child('snapshot').value.toString());
                String imageUrl = snapshot.child('imageUrl').value.toString();
                Map note = snapshot.value as Map;
                note['key'] = snapshot.key;
                return Wrap(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    snapshot.child('title').value.toString() != ""
                                        ? snapshot.child('title').value.toString()
                                        : "[No Subject]",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    snapshot.child('date').value.toString(),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.grey,
                            thickness: 1,
                          ),
                          SizedBox(height: 10),
                          Builder(
                            builder: (context) {
                              if (imageUrl != "") {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    color: Colors.red,
                                    margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                                    child: Image.network(
                                      imageUrl,
                                      height: 300,
                                    ),
                                  ),
                                );
                              }
                              return SizedBox();
                            },
                          ),
                          SizedBox(height: 10),
                          Column(
                            children: [
                              Text(
                                snapshot.child('currentData').value
                                    .toString()
                                    .replaceAll(RegExp("{|}"), "")
                                    .replaceAll(RegExp(","), '\n')
                                    .replaceAll(RegExp("0420:"), ''),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Builder(
                            builder: (context) {
                              if (snapshot_list != null) {
                                return Container(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: snapshot_list?.length,
                                    itemBuilder: (context, i) {
                                      return InkWell(
                                        onTap: () async {
                                          var range = snapshot_list?[i]["range"];
                                          Range _range = Range(
                                            start_date: Jiffy.parse(range[0], pattern: "MM-dd-yyyy")
                                                .format(pattern: "MM-dd-yyyy 00:00")
                                                .toString(),
                                            end_date: Jiffy.parse(range[1], pattern: "MM-dd-yyyy")
                                                .format(pattern: "MM-dd-yyyy 23:59")
                                                .toString(),
                                          );
                                          Filter filter = Filter.custom1;
                                          if (range[0] == range[1]) {
                                            filter = Filter.custom0;
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => historyPage(
                                                filter: filter,
                                                title: snapshot_list?[i]["title"],
                                                snapshot: _range,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  height: 25,
                                                  alignment: Alignment.centerLeft,
                                                  child: Text(
                                                    snapshot_list?[i]["title"] ?? "",
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.centerRight,
                                                  child: Icon(
                                                    Icons.arrow_forward,
                                                    size: 25,
                                                    color: Colors.black.withOpacity(0.15),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                          SizedBox(height: 10),
                          Column(
                            children: [
                              if (snapshot.child('userNote').value.toString() != "")
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    snapshot.child('userNote').value.toString(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Confirmation"),
                                        content: Text("Are you sure you want to delete this item?"),
                                        actions: [
                                          TextButton(
                                            child: Text("DELETE"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              ref.child(snapshot.key!).remove();
                                            },
                                          ),
                                          TextButton(
                                            child: Text("Cancel"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              SizedBox(
                                width: 1,
                              ),
                              GestureDetector(
                                child: Icon(
                                  Icons.edit,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => createNote(
                                        isEdit: true,
                                        snapshot: snapshot,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
