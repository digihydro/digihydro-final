import 'package:digihydro/enums/enums.dart';
import 'package:digihydro/mainpages/chart.dart';
import 'package:digihydro/mainpages/notes_screen.dart';
import 'package:digihydro/mainpages/notif.dart';
import 'package:digihydro/mainpages/plants_screen.dart';
import 'package:digihydro/mainpages/reservoir_screen.dart';
import 'package:digihydro/mainpages/device_screen.dart';
import 'package:digihydro/utils/filters.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:digihydro/drawer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin localNotif =
    FlutterLocalNotificationsPlugin();

class historyPage extends StatefulWidget {
  historyPage({Key? key, required this.filter, this.title, this.snapshot}) : super(key: key);
  final Filter filter;
  final String? title;
  final snapshot;

  @override
  histScreen createState() => histScreen();
}

class histScreen extends State<historyPage> {
  final auth = FirebaseAuth.instance;
  late String currentUserID;
  final ref = FirebaseDatabase.instance.ref('Plants');
  final refReserv = FirebaseDatabase.instance.ref('Reservoir');
  final refDevice = FirebaseDatabase.instance.ref('Devices');

  @override
  void initState() {
    super.initState();
    Notif.initialize(localNotif); //FOR NOTIFS
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      currentUserID = currentUser.uid;
    }
  }

  String getFilterTitle(Filter filter) {
     String title = "Stats History";
     switch (filter) {
       case Filter.six_hour:
         title = '$title (6HR)';
         break;
       case Filter.one_day:
         title = '$title (1D)';
         break;
       case Filter.one_week:
         title = '$title (1W)';
         break;
       case Filter.one_month:
         title = '$title (1M)';
         break;
       case Filter.custom0:
       case Filter.custom1:
         title = widget.title != null ? widget.title.toString() : 'Stats History';
         break;
     }
     return title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 201, 237, 220),
      drawer: drawerPage(),
      appBar: AppBar(
        backgroundColor: Colors.green,
        //automaticallyImplyLeading: false,
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
      body:  SingleChildScrollView(
        child: Column(
          children: [
            Container(
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
                                getFilterTitle(widget.filter),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1a1a1a),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                    height: 300,
                    child: Chart(filter: widget.filter, showAll: true, axis: Axis.horizontal, snapshot: widget.snapshot),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            Container(
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
                                getFilterTitle(widget.filter),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1a1a1a),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                    height: 300,
                    child: Chart(filter: widget.filter, showAll: false, axis: Axis.horizontal, snapshot: widget.snapshot),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
