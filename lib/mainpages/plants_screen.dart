import 'package:digihydro/mainpages/compare_screen.dart';
import 'package:digihydro/model/snapshot.dart';
import 'package:digihydro/utils/compare_data.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:digihydro/create/add_plant.dart';
import 'package:digihydro/drawer_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

import '../create/update_plant.dart';

class plantPage extends StatefulWidget {
  @override
  plant createState() => plant();
}

class plant extends State<plantPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final auth = FirebaseAuth.instance;
  late String currentUserID;
  final ref = FirebaseDatabase.instance.ref('Plants');
  final List<Batch> batch_list = [];

  String filter = "all";
  List<Map> filters = CompareData().filters;
  TextEditingController date = TextEditingController();

  @override
  void initState() {
    //init();
    super.initState();
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      currentUserID = currentUser.uid;
    }
    setFilter(filters[0], "all");
  }

  void setFilter(Map button, String _filter) {
    batch_list.clear();
    filter = _filter;
    setState(() {
      for (var element in filters) {
        element['active'] = false;
      }
      button['active'] = true;
    });
  }

  /*
  init() async {
    String deviceToken = await getDeviceToken();
    print("%%%%%%%%%%%%%% DEVICE TOKEN %%%%%%%%%%%%%%%%");
    print(deviceToken);
    print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");

    //notif on click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      String? title = remoteMessage.notification!.title;
      String? desc = remoteMessage.notification!.body;

      //for in app
      Alert(
        context: context,
        type: AlertType.error,
        title: title,
        desc: desc,
        buttons: [
          DialogButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          )
        ],
      ).show();
    });
  }

  //for notifs
  Future getDeviceToken() async {
    FirebaseMessaging _firebaseMessage = FirebaseMessaging.instance;
    String? deviceToken = await _firebaseMessage.getToken();
    return (deviceToken == null) ? "" : deviceToken;
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      //endFloat, for padding and location
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 5.0,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => DropDown1()));
        },
      ), //FloatingButton
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
              background: Image.asset(
                  "images/plant.png",
                  fit: BoxFit.cover
              ),
              title:  Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child:
                Container(
                  child: Text(
                    'MY PLANTS',
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
              margin: const EdgeInsets.fromLTRB(0, 12, 0, 12),
              child: Column(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () async {
                                setFilter(filters[0], "all");
                              },
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                decoration: BoxDecoration(
                                  color: filters[0]['active']
                                      ? Colors.green
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  child: Text(
                                      'ALL',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: filters[0]['active']
                                            ? Colors.white
                                            : Colors.black,
                                      )
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                setFilter(filters[1], "finished");
                              },
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                decoration: BoxDecoration(
                                  color: filters[1]['active']
                                      ? Colors.green
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  child: Text(
                                      'FINISHED',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: filters[1]['active']
                                            ? Colors.white
                                            : Colors.black,
                                      )
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                setFilter(filters[2], "current");
                              },
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                decoration: BoxDecoration(
                                  color: filters[2]['active']
                                      ? Colors.green
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  child: Text(
                                      'CURRENT',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: filters[2]['active']
                                            ? Colors.white
                                            : Colors.black,
                                      )
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  FirebaseAnimatedList(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 100),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    query: ref.orderByChild('userId').equalTo(currentUserID),
                    itemBuilder: (BuildContext context, DataSnapshot snapshot,
                        Animation<double> animation, int index) {

                      if(filter == "finished") {
                        if ((snapshot.child('endDate').value == null || snapshot.child('endDate').value == "")
                            && snapshot.child('status').value.toString() == "ongoing"){
                          return SizedBox();
                        }
                      }

                      if(filter == "current") {
                        if (snapshot.child('endDate').value != null && snapshot.child('status').value.toString() == "completed"){
                          return SizedBox();
                        }
                      }

                      Batch batch = Batch();
                      batch.id =  snapshot.key != null ? snapshot.key.toString() : "";
                      batch.name = snapshot.child('batchName').value != null ? snapshot.child('batchName').value.toString() : "";

                      String? start_date = (snapshot.child('sowDate').value != null && snapshot.child('sowDate').value.toString() != "")
                          ? DateFormat(CompareData.daily_pattern).format(DateFormat("MM/dd/yyyy").parse(snapshot.child('sowDate').value.toString()))
                          : null;
                      String? end_date = (snapshot.child('endDate').value != null && snapshot.child('endDate').value.toString() != "")
                          ? DateFormat(CompareData.daily_pattern).format(DateFormat("MM/dd/yyyy").parse(snapshot.child('endDate').value.toString()))
                          : null;

                      batch.range = Range(start_date: start_date, end_date: end_date);
                      batch.status = snapshot.child('status').value != null ? snapshot.child('status').value.toString() : "";

                      if(index == 0) {
                        batch_list.clear();
                      }

                      batch_list.add(batch);

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
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        snapshot
                                            .child('batchName')
                                            .value
                                            .toString() != ""
                                            ? snapshot
                                            .child('batchName')
                                            .value
                                            .toString()

                                            : "[No Subject]",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: InkWell(
                                          onTap: () {

                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => comparePage(initialBatch: batch_list[index], batch_list: batch_list,)));
                                          },
                                          child: Icon(
                                            Icons.insert_chart_rounded,
                                            size: 30,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Table(
                                    border: TableBorder.symmetric(
                                      outside: BorderSide.none,
                                      inside: BorderSide(width: 1, color: Colors.grey, style: BorderStyle.solid),
                                    ),
                                    // Allows to add a border decoration around your table
                                    children: [
                                      TableRow(children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                          child: Text('Plant Type:   ',
                                              style: TextStyle(
                                                fontSize: 15,
                                              )
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                                          child: Text(
                                              snapshot.child('plantType').value.toString(),
                                              style: TextStyle(
                                                fontSize: 15,
                                              )
                                          ),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                          child: Text('Plant Variety:  ',
                                              style: TextStyle(
                                                fontSize: 15,
                                              )
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                                          child: Text(
                                              snapshot.child('plantVar').value.toString(),
                                              style: TextStyle(
                                                fontSize: 15,
                                              )
                                          ),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                          child: Text('Grow Method:  ',
                                              style: TextStyle(
                                                fontSize: 15,
                                              )
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                                          child: Text(
                                              snapshot.child('growMethod').value.toString(),
                                              style: TextStyle(
                                                fontSize: 15,
                                              )
                                          ),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                          child: Text('Nutrient Solution:  ',
                                              style: TextStyle(
                                                fontSize: 15,
                                              )
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                                          child: Text(
                                              snapshot.child('nutrientSol').value.toString(),
                                              style: TextStyle(
                                                fontSize: 15,
                                              )
                                          ),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                          child: Text('Sow Type:   ',
                                              style: TextStyle(
                                                fontSize: 15,
                                              )
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                                          child: Text(
                                              snapshot.child('sowType').value.toString(),
                                              style: TextStyle(
                                                fontSize: 15,
                                              )
                                          ),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                          child: Text('Sow Date:   ',
                                              style: TextStyle(
                                                fontSize: 15,
                                              )
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                                          child: Text(
                                              snapshot.child('sowDate').value.toString(),
                                              style: TextStyle(
                                                fontSize: 15,
                                              )
                                          ),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                          child: Text('End Date:   ',
                                              style: TextStyle(
                                                fontSize: 15,
                                              )
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                                          child: Builder(
                                              builder: (context) {
                                                if(snapshot.child('endDate').value != null && snapshot.child('status').value.toString() == "completed") {
                                                  return Text(
                                                      snapshot.child('endDate').value.toString(),
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      )
                                                  );
                                                } else {
                                                  return InkWell(
                                                    onTap: () async{
                                                      var result = await showDialog(
                                                          barrierDismissible: true,
                                                          context: context,
                                                          builder: (dialog) {
                                                            bool isGenerating = false;
                                                            bool hasError = false;
                                                            String validation = "";
                                                            date.clear();
                                                            return StatefulBuilder(
                                                                builder: (context, setState) {
                                                                  return AlertDialog(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.all(Radius.circular(10))),
                                                                    titlePadding: EdgeInsetsDirectional.fromSTEB(10, 30, 10, 15),
                                                                    content: Builder(builder: (context) {
                                                                      return Column(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        children: [
                                                                          Column(
                                                                            children: [
                                                                              Text(
                                                                                "Complete selected batch item?",
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(
                                                                                  fontSize: 14,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.fromLTRB(0, 20, 0, 10),
                                                                            child: Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Expanded(
                                                                                  child: Padding(
                                                                                    padding:
                                                                                    const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                                                                    child: Column(
                                                                                      mainAxisSize:
                                                                                      MainAxisSize.min,
                                                                                      children: [
                                                                                        Align(
                                                                                          child: Text("Select date",
                                                                                            style: TextStyle(fontSize: 12),
                                                                                          ),
                                                                                          alignment: Alignment.center,
                                                                                        ),
                                                                                        TextField(
                                                                                          controller: date,
                                                                                          readOnly: true,
                                                                                          enableInteractiveSelection: true,
                                                                                          textAlign: TextAlign.center,
                                                                                          style: TextStyle(
                                                                                            fontSize: 14,
                                                                                          ),
                                                                                          decoration: InputDecoration(
                                                                                            border: OutlineInputBorder(),
                                                                                            isDense: true,
                                                                                            contentPadding:
                                                                                            const EdgeInsets.all(10.0),
                                                                                          ),
                                                                                          onTap: () async {
                                                                                            DateTime? pickedDate = await showDatePicker(
                                                                                              context: context,
                                                                                              initialDate: DateTime.now(),
                                                                                              firstDate: Jiffy.now().subtract(years: 15).dateTime,
                                                                                              lastDate: Jiffy.now().add(years: 10).dateTime,
                                                                                            );

                                                                                            if (pickedDate != null) {
                                                                                              date.text = DateFormat('MM/dd/yyyy')
                                                                                                  .format(pickedDate);
                                                                                            }
                                                                                          },
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
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
                                                                                child: Text('Proceed'),
                                                                                style: ElevatedButton
                                                                                    .styleFrom(
                                                                                  backgroundColor:
                                                                                  isGenerating
                                                                                      ? Colors.grey
                                                                                      : Colors.green,
                                                                                  shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(20)),
                                                                                  padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
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

                                                                                  if (date.text.isEmpty) {
                                                                                    hasError = true;
                                                                                    validation = "Fields cannot be empty!";
                                                                                    setState(() {
                                                                                      isGenerating = false;
                                                                                    });
                                                                                    return;
                                                                                  }

                                                                                  if(snapshot.key != null) {
                                                                                    await FirebaseDatabase.instance.ref("Plants/${snapshot.key}").update({
                                                                                      "endDate" : date.text,
                                                                                      "status" : "completed"
                                                                                    });
                                                                                  }

                                                                                  setState(() {
                                                                                    isGenerating = false;
                                                                                    Navigator.pop(dialog, false);
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
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(50),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey.withOpacity(0.5),
                                                            spreadRadius: 1,
                                                            blurRadius: 1,
                                                            offset: Offset(0, 1),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
                                                        child: Text(
                                                            'Ongoing',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors.green
                                                            )
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                          ),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                          child: Text('Reservoir:  ',
                                              style: TextStyle(
                                                fontSize: 15,
                                              )
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                                          child: Text(
                                              snapshot.child('reserv').value.toString(),
                                              style: TextStyle(
                                                fontSize: 15,
                                              )
                                          ),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                          child: Text('Greenhouse  ',
                                              style: TextStyle(
                                                fontSize: 15,
                                              )
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                                          child: Text(
                                              snapshot.child('greenhouse').value.toString(),
                                              style: TextStyle(
                                                fontSize: 15,
                                              )
                                          ),
                                        ),
                                      ]),
                                    ],
                                  ),
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
                                                  updatePlant(snapshot: snapshot,)
                                          ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            /*GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => plantDetails(
                                      snapshot: snapshot,
                                    )));
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                    snapshot
                                        .child('batchName')
                                        .value
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),*/
                          )
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
