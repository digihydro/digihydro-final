// ignore_for_file: unused_import

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:digihydro/enums/enums.dart';
import 'package:digihydro/model/snapshot.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:digihydro/mainpages/notes_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

class createNote extends StatefulWidget {
  createNote({Key? key, required this.isEdit, this.snapshot}) : super(key: key);
  final bool isEdit;
  final snapshot;

  @override
  note createState() => note();
}

class note extends State<createNote> {
  final DatabaseReference refDevice = FirebaseDatabase.instance.ref('Devices');
  final DatabaseReference destinationReference =
      FirebaseDatabase.instance.ref().child('noteStats');
  Map<dynamic, dynamic>? currentData;

  Future<Map<dynamic, dynamic>?> FetchData() async {
    try {
      DatabaseEvent event = await refDevice.once();
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? sourceData =
          snapshot.value as Map<dynamic, dynamic>?;
      destinationReference.set(sourceData);
      currentData = sourceData;
      return sourceData;
    } catch (error) {
      // Handle any errors that occur during the read operation
      return null;
    }
  }

  TextEditingController title = TextEditingController();
  TextEditingController userDate = TextEditingController();
  TextEditingController userNote = TextEditingController();
  TextEditingController start_date = TextEditingController();
  TextEditingController end_date = TextEditingController();

  String imageUrl = '';
  File? _imageFile;

  List<Map<String, dynamic>>? snapshot_list = [];
  var key;

  Future<void> _pickImage() async {
    ImagePicker imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    userDate.text = DateFormat('MM-dd-yyyy').format(DateTime.now());
    FetchData();
    if (widget.isEdit) {
      var snapshot = widget.snapshot;
      var _key = snapshot.key;
      var _snapshot_list =
          jsonDecode(snapshot.child('snapshot').value.toString());
      String _imageUrl = snapshot.child('imageUrl').value.toString();

      setState(() {
        imageUrl = _imageUrl;
        title.text = snapshot.child('title').value.toString();
        userDate.text = snapshot.child('date').value.toString();
        userNote.text = snapshot.child('userNote').value.toString();
        key = _key;

        if (_snapshot_list != null) {
          snapshot_list = new List.from(_snapshot_list);
        }
      });
    }
  }

  final fb = FirebaseDatabase.instance;

  @override
  Widget build(BuildContext context) {
    var focus_node_title = FocusNode();
    var focus_node_content = FocusNode();
    var rng = Random();
    var num = rng.nextInt(10000);

    final FirebaseAuth _auth = FirebaseAuth.instance;
    final ref = fb.ref().child('Notes/$num');
    final update_ref = FirebaseDatabase.instance.ref("Notes/$key");
    final currentUser = _auth.currentUser;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromARGB(255, 201, 237, 220),
      appBar: AppBar(
        title: Container(
          child: Text(
            !widget.isEdit ? "Create Note" : "Update Note",
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
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
                child: ListView(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: TextField(
                        focusNode: focus_node_title,
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
                        readOnly: true,
                        enableInteractiveSelection: true,
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.calendar_today_rounded),
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
                            lastDate: DateTime.now(),
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
                        height: 110,
                        width: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey, width: 1.0)),
                        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                        child: FirebaseAnimatedList(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            query: destinationReference,
                            itemBuilder: (BuildContext context,
                                DataSnapshot snapshot,
                                Animation<double> animation,
                                int index) {
                              return Container(
                                padding: EdgeInsets.all(5),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Current Data Parameters',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          snapshot.value
                                              .toString()
                                              .replaceAll(RegExp("{|}"), "")
                                              .replaceAll(RegExp(","), '\n'),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            })),
                    Container(
                      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: TextField(
                        focusNode: focus_node_content,
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
                    Column(
                      children: [
                        Builder(builder: (context) {
                          if (_imageFile != null) {
                            return Container(
                              margin:
                                  EdgeInsets.only(top: 10, left: 10, right: 10),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.file(
                                      _imageFile!,
                                      height: 300,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: () async {
                                          setState(() {
                                            imageUrl = '';
                                            _imageFile = null;
                                          });
                                        },
                                        child: Icon(
                                          Icons.clear_rounded,
                                          size: 25,
                                          color: Colors.black.withOpacity(0.15),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (imageUrl != "") {
                            return Container(
                              margin:
                                  EdgeInsets.only(top: 10, left: 10, right: 10),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.network(
                                      imageUrl,
                                      height: 300,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: () async {
                                          setState(() {
                                            imageUrl = '';
                                            _imageFile = null;
                                          });
                                        },
                                        child: Icon(
                                          Icons.clear_rounded,
                                          size: 25,
                                          color: Colors.black.withOpacity(0.15),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }),
                      ],
                    ),
                    Container(
                      child: Builder(builder: (context) {
                        if (snapshot_list != null) {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount: snapshot_list?.length,
                            itemBuilder: (context, i) {
                              return Container(
                                  margin: EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 25,
                                          alignment: Alignment.centerLeft,
                                          child:
                                              Text(snapshot_list?[i]["title"]),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: () async {
                                              setState(() {
                                                snapshot_list?.removeAt(i);
                                              });
                                            },
                                            child: Icon(
                                              Icons.clear_rounded,
                                              size: 25,
                                              color: Colors.black
                                                  .withOpacity(0.15),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ));
                            },
                          );
                        } else {
                          return Container();
                        }
                      }),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            child: Icon(
                              Icons.photo_camera,
                              size: 40,
                              color: Colors.black.withOpacity(0.15),
                            ),
                            onTap: _pickImage,
                          ),
                          InkWell(
                            child: Icon(
                              Icons.insert_chart_rounded,
                              size: 40,
                              color: Colors.black.withOpacity(0.15),
                            ),
                            onTap: () async {
                              focus_node_title.unfocus();
                              focus_node_content.unfocus();
                              var result = await showDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (dialog) {
                                    bool isGenerating = false;
                                    bool hasError = false;
                                    String validation = "";
                                    return StatefulBuilder(
                                        builder: (context, setState) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        titlePadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                10, 30, 10, 15),
                                        content: Builder(builder: (context) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Column(
                                                children: [
                                                  Icon(Icons.insert_chart),
                                                  Text(
                                                    "Select snapshot range",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 20, 0, 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                0, 0, 5, 0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Align(
                                                              child: Text(
                                                                "Start date",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                            ),
                                                            TextField(
                                                              controller:
                                                                  start_date,
                                                              readOnly: true,
                                                              enableInteractiveSelection:
                                                                  true,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                              ),
                                                              decoration:
                                                                  InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(),
                                                                isDense: true,
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        10.0),
                                                              ),
                                                              onTap: () async {
                                                                DateTime?
                                                                    pickedDate =
                                                                    await showDatePicker(
                                                                  context:
                                                                      context,
                                                                  initialDate:
                                                                      DateTime
                                                                          .now(),
                                                                  firstDate:
                                                                      DateTime(
                                                                          1900),
                                                                  lastDate:
                                                                      DateTime
                                                                          .now(),
                                                                );

                                                                if (pickedDate !=
                                                                    null) {
                                                                  setState(() {
                                                                    start_date
                                                                        .text = DateFormat(
                                                                            'MM-dd-yyyy')
                                                                        .format(
                                                                            pickedDate);
                                                                  });
                                                                }
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                5, 0, 0, 0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Align(
                                                              child: Text(
                                                                "End date",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                            ),
                                                            TextField(
                                                              controller:
                                                                  end_date,
                                                              readOnly: true,
                                                              enableInteractiveSelection:
                                                                  true,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontSize: 14),
                                                              decoration:
                                                                  InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(),
                                                                isDense: true,
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        10.0),
                                                              ),
                                                              onTap: () async {
                                                                DateTime?
                                                                    pickedDate =
                                                                    await showDatePicker(
                                                                  context:
                                                                      context,
                                                                  initialDate:
                                                                      DateTime
                                                                          .now(),
                                                                  firstDate:
                                                                      DateTime(
                                                                          1900),
                                                                  lastDate:
                                                                      DateTime
                                                                          .now(),
                                                                );

                                                                if (pickedDate !=
                                                                    null) {
                                                                  setState(() {
                                                                    end_date
                                                                        .text = DateFormat(
                                                                            'MM-dd-yyyy')
                                                                        .format(
                                                                            pickedDate);
                                                                  });
                                                                }
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        20, 10, 20, 10),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 40,
                                                  child: ElevatedButton(
                                                    child: Text('Generate'),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          isGenerating
                                                              ? Colors.grey
                                                              : Colors.green,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              25, 10, 25, 10),
                                                      textStyle: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      if (isGenerating) {
                                                        return;
                                                      }

                                                      setState(() {
                                                        isGenerating = true;
                                                        hasError = false;
                                                        validation = "";
                                                      });

                                                      String title =
                                                          '${start_date.text} - ${end_date.text}';
                                                      List<String> range = [
                                                        start_date.text,
                                                        end_date.text
                                                      ];
                                                      Snapshot snapshot =
                                                          Snapshot(
                                                              title: title,
                                                              range: range);

                                                      await Future.delayed(
                                                          const Duration(
                                                              milliseconds:
                                                                  1000));

                                                      setState(() {
                                                        isGenerating = false;
                                                        if (start_date
                                                                .text.isEmpty ||
                                                            end_date
                                                                .text.isEmpty) {
                                                          hasError = true;
                                                          validation =
                                                              "Fields cannot be empty!";
                                                          return;
                                                        } else if (Jiffy.parse(end_date.text.trim(), pattern: "MM-dd-yyyy").dateTime
                                                            .isBefore(Jiffy.parse(start_date.text.trim(), pattern: "MM-dd-yyyy").dateTime)) {
                                                          hasError = true;
                                                          validation =
                                                              "End date is greater then Start date!";
                                                          return;
                                                        } else if (snapshot_list
                                                            .toString()
                                                            .contains(title)) {
                                                          hasError = true;
                                                          validation =
                                                              "Snapshot already added!";
                                                          return;
                                                        } else {
                                                          Navigator.pop(dialog,
                                                              snapshot.asMap());
                                                        }
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: isGenerating,
                                                child: Container(
                                                    height: 30,
                                                    width: 30,
                                                    child:
                                                        CircularProgressIndicator()),
                                              ),
                                              Visibility(
                                                visible: hasError,
                                                child: Container(
                                                  width: double.infinity,
                                                  child: Text(
                                                    validation,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 12),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      );
                                    });
                                  });

                              try {
                                if (result != null) {
                                  setState(() {
                                    snapshot_list?.add(result!);
                                  });
                                }
                              } catch (error) {
                                print(error);
                              }
                            },
                          ),
                        ],
                      ),
                      Container(
                        height: 40,
                        child: ElevatedButton(
                          child: !widget.isEdit ? Text('POST') : Text('UPDATE'),
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
                            if (_imageFile != null) {
                              String id = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString();
                              final imageRoot = FirebaseStorage.instance.ref();
                              final imageRef = imageRoot.child('Images');
                              final imageUpload = imageRef.child(id);
                              try {
                                await imageUpload.putFile(_imageFile!);
                                imageUrl = await imageUpload.getDownloadURL();
                              } catch (error) {}
                            }

                            if (!widget.isEdit) {
                              /*Map<dynamic, dynamic>? fetchedData =
                                  await FetchData();*/
                              await ref.set({
                                "title": title.text,
                                "date": userDate.text,
                                "userId": currentUser?.uid,
                                "userNote": userNote.text,
                                "imageUrl": imageUrl,
                                "currentData": currentData,
                                "snapshot": jsonEncode(snapshot_list),
                              }).asStream();
                            } else {
                              await update_ref.update({
                                "title": title.text,
                                "userNote": userNote.text,
                                "imageUrl": imageUrl,
                                "snapshot": jsonEncode(snapshot_list),
                              });
                            }

                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          //decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        ),
      ),
    );
  }
}
