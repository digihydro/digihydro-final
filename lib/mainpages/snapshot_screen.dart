import 'package:digihydro/enums/enums.dart';
import 'package:digihydro/mainpages/notif.dart';
import 'package:digihydro/utils/filter_data.dart';
import 'package:digihydro/widgets/chart.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:digihydro/drawer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin localNotif =
    FlutterLocalNotificationsPlugin();

class snapshotPage extends StatefulWidget {
  snapshotPage({Key? key, required this.filter, this.title, this.snapshot})
      : super(key: key);
  final Filter filter;
  final String? title;
  final snapshot;

  @override
  snapshotScreen createState() => snapshotScreen();
}

class snapshotScreen extends State<snapshotPage> {
  final auth = FirebaseAuth.instance;
  late String currentUserID;
  final ref = FirebaseDatabase.instance.ref('Plants');
  final refReserv = FirebaseDatabase.instance.ref('Reservoir');
  final refDevice = FirebaseDatabase.instance.ref('Devices');

  bool showAll = false;
  Filter filter = Filter.six_hour;

  @override
  void initState() {
    super.initState();
    Notif.initialize(localNotif); //FOR NOTIFS
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      currentUserID = currentUser.uid;
    }
    filter = widget.filter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 201, 237, 220),
      drawer: drawerPage(),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.green,
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 8, 0, 0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.analytics,
                              size: 25,
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                              child: Text(
                                "Snapshot Data",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF1a1a1a),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () async {
                                  setState(() {});
                                },
                                child: Icon(
                                  Icons.refresh_outlined,
                                  size: 25,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(20, 5, 0, 0),
                                child: Container(
                                  child: Text('Show all:',
                                      style: TextStyle(
                                        fontSize: 12,
                                      )),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 5, 10, 0),
                                child: Container(
                                  child: Switch(
                                    value: showAll,
                                    onChanged: (bool value) {
                                      setState(() {
                                        showAll = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                  ),
                  Container(
                    width: double.infinity,
                    /*height: (MediaQuery.of(context).size.height - AppBar().preferredSize.height) - MediaQuery.of(context).padding.top,*/
                    child: Chart(
                      filter: filter,
                      showAll: showAll,
                      axis: Axis.horizontal,
                      snapshot: widget.snapshot,
                      isFromDashboard: false,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 8, 0, 0),
                        child: SizedBox(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
