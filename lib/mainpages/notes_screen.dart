import 'dart:convert';
import 'dart:io';
import 'package:digihydro/enums/enums.dart';
import 'package:digihydro/mainpages/history_screen.dart';
import 'package:digihydro/model/snapshot.dart';
import 'package:digihydro/widgets/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:digihydro/create/create_note.dart';
import 'package:digihydro/drawer_screen.dart';
import 'package:searchbar_animation/searchbar_animation.dart';
import 'package:intl/intl.dart';

class notesPage extends StatefulWidget {
  @override
  displayNote createState() => displayNote();
}

class displayNote extends State<notesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
  TextEditingController search = TextEditingController();

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
      key: _scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      //endFloat, for padding and location
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add,),
        elevation: 2.0,
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
      /*backgroundColor: Color.fromARGB(255, 201, 237, 220),*/
      backgroundColor: Colors.white,
      drawer: drawerPage(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.green,
            pinned: true,
            leading: InkWell(
                onTap: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                child: Icon(Icons.menu, size: 35,)
            ),
            actions: [
              /*Container(
                margin: EdgeInsets.fromLTRB(0, 5, 15, 0),
                child: Align(
                  child: Image.asset(
                    'images/logo_white.png',
                    scale: 8,
                  ),
                ),
              ),*/
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Image.asset(
                      "images/DHIconW.png",
                      fit: BoxFit.fitHeight
                  ),
                ),
              ),
            ],
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              /*background: Container(
                color: Colors.green,
              ),*/
              background: Image.asset(
                  "images/image.png",
                  fit: BoxFit.cover
              ),
              title:  Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child:
                Container(
                  child: Text(
                    'MY NOTES',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              centerTitle: true,
            ),
          ),

          SliverToBoxAdapter(
            child:  Container(
              /*decoration: BoxDecoration(
                color: Colors.white,
              ),*/
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SearchBarAnimation(
                        textEditingController: search,
                        isOriginalAnimation: true,
                        enableKeyboardFocus: false,
                        durationInMilliSeconds:500,
                        trailingWidget: const Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.black,
                        ),
                        secondaryButtonWidget: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.black,
                        ),
                        buttonWidget: const Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.black,
                        ),
                        onChanged: (value) async{
                          setState(() {
                          });
                        },
                      onCollapseComplete: () async{
                        search.clear();
                        setState(() {
                        });
                      },
                    ),
                  ),
                  FirebaseAnimatedList(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 100),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    query: ref.orderByChild('userId').equalTo(currentUserID),
                    itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {

                      if (!search.text.isEmpty) {
                        if(!snapshot.child('title').value.toString().toLowerCase().contains(search.text.toLowerCase())
                            && !snapshot.child('userNote').value.toString().toLowerCase().contains(search.text.toLowerCase())
                            && !snapshot.child('date').value.toString().replaceAll("-", "").contains(search.text.replaceAll("-", ""))) {
                          return SizedBox();
                        }
                      }

                      var snapshot_list = jsonDecode(snapshot
                          .child('snapshot')
                          .value
                          .toString());
                      String imageUrl = snapshot
                          .child('imageUrl')
                          .value
                          .toString();
                      Map note = snapshot.value as Map;
                      note['key'] = snapshot.key;

                      return Wrap(
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
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
                                          snapshot
                                              .child('title')
                                              .value
                                              .toString() != ""
                                              ? snapshot
                                              .child('title')
                                              .value
                                              .toString()
                                              : "[No Subject]",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Theme
                                                .of(context)
                                                .primaryColor,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          snapshot
                                              .child('date')
                                              .value
                                              .toString(),
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Theme
                                                .of(context)
                                                .primaryColor,
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
                                Builder(
                                  builder: (context) {
                                    if (imageUrl != "") {
                                      return Align(
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                          color: Colors.green.shade100,
                                          width: double.infinity,
                                          height: 300,
                                          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                                          child: Image.network(
                                            imageUrl,
                                          ),
                                        ),
                                      );
                                    }
                                    return SizedBox();
                                  },
                                ),
                                Column(
                                  children: [
                                    if (snapshot
                                        .child('userNote')
                                        .value
                                        .toString() != "")
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: new ExpandableTextWidget(
                                            text: snapshot
                                                .child('userNote')
                                                .value
                                                .toString()
                                        ),
                                      ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    if (snapshot
                                        .child('currentData')
                                        .value
                                        .toString() != "")
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                                              child: Text("Current Device Data:",
                                                style: TextStyle(
                                                    color: Theme
                                                        .of(context)
                                                        .primaryColor
                                                ),
                                              ),
                                            ),
                                            Text(
                                              snapshot
                                                  .child('currentData')
                                                  .value
                                                  .toString()
                                                  .replaceAll(" ", "")
                                                  .replaceAll(RegExp("{|}"), "")
                                                  .replaceAll(RegExp(","), '\n')
                                                  .replaceAll(RegExp("0420:"), ''),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                Builder(
                                  builder: (context) {
                                    if (snapshot_list != null && snapshot_list.length != 0) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                                              child: Text("Snapshots:",
                                                style: TextStyle(
                                                    color: Theme
                                                        .of(context)
                                                        .primaryColor
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Column(
                                                children: [
                                                  ListView.builder(
                                                    padding: EdgeInsets.zero,
                                                    shrinkWrap: true,
                                                    physics: ClampingScrollPhysics(),
                                                    itemCount: snapshot_list?.length,
                                                    itemBuilder: (context, i) {
                                                      return InkWell(
                                                        onTap: () async {
                                                          var range = snapshot_list?[i]["range"];
                                                          Range _range = Range(
                                                              start_date: "${range[0]} 00:00",
                                                              end_date: "${range[1]} 23:00");
                                                          Filter filter = range[0] == range[1]
                                                              ? Filter.custom0
                                                              : Filter.custom1;

                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  historyPage(
                                                                    filter: filter,
                                                                    title: 'snapshot_${snapshot_list?[i]["title"]}' ??
                                                                        "",
                                                                    snapshot: _range,
                                                                  ),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          margin: const EdgeInsets.fromLTRB(
                                                              0, 2, 0, 2),
                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors.grey),
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Stack(
                                                              children: [
                                                                Container(
                                                                  height: 25,
                                                                  alignment: Alignment.centerLeft,
                                                                  child: Text(
                                                                    'snapshot_${snapshot_list?[i]["title"]}' ??
                                                                        "",
                                                                  ),
                                                                ),
                                                                Container(
                                                                    alignment: Alignment
                                                                        .centerRight,
                                                                    height: 25,
                                                                    child: Text("view",
                                                                      style: TextStyle(
                                                                          color: Colors.blue),
                                                                    )
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.green,
                                          size: 35,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text("Confirmation"),
                                                content: Text(
                                                    "Are you sure you want to delete this item?"),
                                                actions: [
                                                  TextButton(
                                                    child: Text("DELETE"),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                      ref.child(snapshot.key!).remove();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text("CANCEL"),
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
                                    ),
                                    Container(
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.edit_note_rounded,
                                          color: Colors.green,
                                          size: 35,
                                        ),
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(
                                            builder: (context) =>
                                                createNote(
                                                  isEdit: true,
                                                  snapshot: snapshot,
                                                ),
                                          ),
                                          );
                                        },
                                      ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

