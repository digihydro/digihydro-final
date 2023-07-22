import 'dart:math';
import 'package:digihydro/enums/enums.dart';
import 'package:digihydro/mainpages/chart.dart';
import 'package:digihydro/mainpages/notes_screen.dart';
import 'package:digihydro/mainpages/notif.dart';
import 'package:digihydro/mainpages/plants_screen.dart';
import 'package:digihydro/mainpages/reservoir_screen.dart';
import 'package:digihydro/mainpages/device_screen.dart';
import 'package:digihydro/mainpages/history_screen.dart';
import 'package:digihydro/model/statistics.dart';
import 'package:digihydro/utils/filters.dart';
import 'package:digihydro/utils/tools.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:digihydro/drawer_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';

final FlutterLocalNotificationsPlugin localNotif =
    FlutterLocalNotificationsPlugin();

class dashBoard extends StatefulWidget {
  @override
  welcomeScreen createState() => welcomeScreen();
}

class welcomeScreen extends State<dashBoard> {
  final auth = FirebaseAuth.instance;
  late String currentUserID;
  final ref = FirebaseDatabase.instance.ref('Plants');
  final refReserv = FirebaseDatabase.instance.ref('Reservoir');
  final refDevice = FirebaseDatabase.instance.ref('Devices');
  final refNotes = FirebaseDatabase.instance.ref('Notes');

  List<Map> filters = Filters().filters;
  Filter filter = Filter.six_hour;
  bool showAll = true;

  @override
  void initState() {
    super.initState();
    Notif.initialize(localNotif); //FOR NOTIFS
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      currentUserID = currentUser.uid;
    }
    setFilter(filters[0], Filter.six_hour);
  }

  void setFilter(Map button, Filter _filter) {
    filter = _filter;
    setState(() {
      for (var element in filters) {
        element['active'] = false;
      }
      button['active'] = true;
    });
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
      body: SingleChildScrollView(
        child: Column(
          children: [
/*DEVICE CONTAINER */
            Container(
              margin: EdgeInsets.fromLTRB(10, 20, 10, 10),
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
              child: Container(
                height: 270,
                child: FirebaseAnimatedList(
                  query: refDevice,
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    return Wrap(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(10, 0, 0, 10),
                                    child: Text(
                                      'Realtime Stats',
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1a1a1a),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 0, 10, 10),
                                    child: GestureDetector(
                                      child: Icon(
                                        Icons.warning_sharp,
                                        color: iconColor(snapshot),
                                        size: 40,
                                      ),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          //barrierColor:
                                          //    Color(0xFF1a1a1a).withOpacity(0.8),
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              content: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    airTempChecker(snapshot),
                                                    humidityChecker(snapshot),
                                                    waterTempChecker(snapshot),
                                                    tdsChecker(snapshot),
                                                    acidityChecker(snapshot),
                                                  ],
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: Text("OK"),
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
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(Icons.thermostat),
                                        Text(
                                          ' Air Temp',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Color(0xFF4f4f4f),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                        snapshot
                                                .child('Temperature')
                                                .value
                                                .toString()
                                                .replaceAll(
                                                    RegExp(r'[^\d\.]'), '') +
                                            ' °C',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        )),
                                  ),
                                ],
                              ),
                              Divider(
                                  color: Colors.grey, thickness: 1, indent: 25),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'images/humidity_percentage_FILL0_wght400_GRAD0_opsz48.png',
                                          height: 24,
                                          width: 24,
                                        ),
                                        Text(
                                          ' Humidity',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Color(0xFF4f4f4f),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                        snapshot
                                                .child('Humidity')
                                                .value
                                                .toString()
                                                .replaceAll(
                                                    RegExp(r'[^\d\.]'), '') +
                                            ' %',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        )),
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.grey,
                                thickness: 1,
                                indent: 25,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'images/dew_point_FILL0_wght400_GRAD0_opsz48.png',
                                          height: 24,
                                          width: 24,
                                        ),
                                        Text(
                                          ' Water Temp',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Color(0xFF4f4f4f),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                        snapshot
                                                .child('WaterTemperature')
                                                .value
                                                .toString()
                                                .replaceAll(
                                                    RegExp(r'[^\d\.]'), '') +
                                            ' °C',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        )),
                                  ),
                                ],
                              ),
                              Divider(
                                  color: Colors.grey, thickness: 1, indent: 25),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'images/total_dissolved_solids_FILL0_wght400_GRAD0_opsz48.png',
                                          height: 24,
                                          width: 24,
                                        ),
                                        Text(
                                          ' TDS',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Color(0xFF4f4f4f),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                        snapshot
                                                .child('TotalDissolvedSolids')
                                                .value
                                                .toString()
                                                .replaceAll(
                                                    RegExp(r'[^\d\.]'), '') +
                                            ' PPM',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        )),
                                  ),
                                ],
                              ),
                              Divider(
                                  color: Colors.grey, thickness: 1, indent: 25),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'images/water_ph_FILL0_wght400_GRAD0_opsz48.png',
                                          height: 24,
                                          width: 24,
                                        ),
                                        Text(
                                          ' Water Acidity',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Color(0xFF4f4f4f),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                        snapshot
                                                .child('pH')
                                                .value
                                                .toString()
                                                .replaceAll(
                                                    RegExp(r'[^\d\.]'), '') +
                                            ' pH',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        )),
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
            ),

// HISTORY CONTAINER
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
                                'Stats History',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color(0xFF1a1a1a),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () async {
                                  setState(() {
                                    for (int i = 0; i < filters.length; i++) {
                                      if (filters[i]['active'] == true) {
                                        setFilter(filters[i], filter);
                                      }
                                    }
                                  });
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
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 12, 15, 0),
                        child: GestureDetector(
                          child: Text(
                            "See More",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => historyPage(
                                          filter: filter,
                                        )));
                          },
                        ),
                      )
                    ],
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /*Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                child: Container(
                                  child: Text('Show all:',
                                      style: TextStyle(
                                        fontSize: 12,
                                      )),
                                ),
                              ),
                              Container(
                                child: Switch(
                                  value: showAll,
                                  onChanged: (bool value) {
                                    setState(() {
                                      showAll = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),*/
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 70,
                                child: TextButton(
                                  style: ButtonStyle(
                                    foregroundColor: filters[0]['active']
                                        ? MaterialStateProperty.all(
                                            Colors.green)
                                        : MaterialStateProperty.all(
                                            Colors.grey),
                                  ),
                                  onPressed: () {
                                    setFilter(filters[0], Filter.six_hour);
                                  },
                                  child: Text('6HR',
                                      style: TextStyle(
                                        fontSize: 12,
                                      )),
                                ),
                              ),
                              Container(
                                width: 70,
                                child: TextButton(
                                  style: ButtonStyle(
                                    foregroundColor: filters[1]['active']
                                        ? MaterialStateProperty.all(
                                            Colors.green)
                                        : MaterialStateProperty.all(
                                            Colors.grey),
                                  ),
                                  onPressed: () {
                                    setFilter(filters[1], Filter.one_day);
                                  },
                                  child: Text('1D',
                                      style: TextStyle(
                                        fontSize: 12,
                                      )),
                                ),
                              ),
                              Container(
                                width: 70,
                                child: TextButton(
                                  style: ButtonStyle(
                                    foregroundColor: filters[2]['active']
                                        ? MaterialStateProperty.all(
                                            Colors.green)
                                        : MaterialStateProperty.all(
                                            Colors.grey),
                                  ),
                                  onPressed: () {
                                    setFilter(filters[2], Filter.one_week);
                                  },
                                  child: Text('1W',
                                      style: TextStyle(
                                        fontSize: 12,
                                      )),
                                ),
                              ),
                              Container(
                                width: 70,
                                child: TextButton(
                                  style: ButtonStyle(
                                    foregroundColor: filters[3]['active']
                                        ? MaterialStateProperty.all(
                                            Colors.green)
                                        : MaterialStateProperty.all(
                                            Colors.grey),
                                  ),
                                  onPressed: () {
                                    setFilter(filters[3], Filter.one_month);
                                  },
                                  child: Text('1M',
                                      style: TextStyle(
                                        fontSize: 12,
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    height: 300,
                    child: Chart(
                        filter: filter,
                        showAll: showAll,
                        axis: Axis.horizontal),
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

/*PLANTS CONTAINER */

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
                              Icons.energy_savings_leaf_outlined,
                              size: 25,
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                              child: Text(
                                'Plants Overview',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color(0xFF1a1a1a),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 12, 15, 0),
                        child: GestureDetector(
                          child: Text(
                            "See More",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => plantPage()));
                          },
                        ),
                      )
                    ],
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(15, 0, 0, 7),
                        child: Text(
                          'Plant Name',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF272727),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 7),
                        child: Text(
                          'Greenhouse',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF272727),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 20, 7),
                        child: Text(
                          'Reservoir',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF272727),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 200,
                    child: FirebaseAnimatedList(
                      query: ref
                          .orderByChild('userId')
                          .equalTo(currentUserID)
                          .limitToFirst(10),
                      itemBuilder: (BuildContext context, DataSnapshot snapshot,
                          Animation<double> animation, int index) {
                        //if (snapshot == null || snapshot.value == null)
                        if (snapshot.value == null) return SizedBox.shrink();
                        final plantName =
                            snapshot.child('batchName').value?.toString() ?? '';
                        final greenhouse =
                            snapshot.child('greenhouse').value?.toString() ??
                                '';
                        final reserName =
                            snapshot.child('reserv').value?.toString() ?? '';
                        return ListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            IntrinsicHeight(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                //mainAxisSize: MainAxisSize.max,
                                //crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${index + 1}. ' + plantName,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF4f4f4f),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 14.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            greenhouse,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF4f4f4f),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 14.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            reserName,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF4f4f4f),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

//Notes Container
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
                              Icons.notes_rounded,
                              size: 25,
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                              child: Text(
                                'Notes List',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color(0xFF1a1a1a),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 12, 15, 0),
                        child: GestureDetector(
                          child: Text(
                            "See More",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => notesPage()));
                          },
                        ),
                      )
                    ],
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                  ),
                  Container(
                    height: 300,
                    child: FirebaseAnimatedList(
                        query: refNotes
                            .orderByChild('userId')
                            .equalTo(currentUserID)
                            .limitToFirst(2),
                        itemBuilder: (BuildContext context,
                            DataSnapshot snapshot,
                            Animation<double> animation,
                            int index) {
                          return Wrap(
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
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
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            snapshot
                                                .child('title')
                                                .value
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
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
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text(snapshot
                                                .child('currentData')
                                                .value
                                                .toString()
                                                .replaceAll(RegExp("{|}"), "")
                                                .replaceAll(RegExp(","), '\n')
                                                .replaceAll(
                                                    RegExp("0420:"), ''))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                  ),
                ],
              ),
            ),
// BUTTONS
            Column(
              children: [
                Divider(
                  color: Colors.grey,
                  thickness: 2,
                  indent: 25,
                  endIndent: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 40,
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: ElevatedButton.icon(
                        // ignore: sort_child_properties_last
                        icon: Icon(
                          Icons.energy_savings_leaf,
                          color: Colors.green,
                          size: 30.0,
                        ),
                        label: const Text(
                          'Plants',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 20),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          foregroundColor: Color(0xFF343434), //text color
                          backgroundColor: Color(0xFFb8d4c4), //button color
                          textStyle: const TextStyle(color: Colors.black),
                          minimumSize: Size(150, 50),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => plantPage()));
                          //signIn();
                        },
                      ),
                    ),
                    Container(
                      height: 40,
                      margin: EdgeInsets.fromLTRB(20, 10, 0, 0),
                      child: ElevatedButton.icon(
                        // ignore: sort_child_properties_last
                        icon: Icon(
                          Icons.sticky_note_2_outlined,
                          color: Colors.green,
                          size: 30.0,
                        ),
                        label: const Text(
                          'Notes',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          foregroundColor: Color(0xFF343434),
                          backgroundColor: Color(0xFFb8d4c4),
                          textStyle: const TextStyle(color: Colors.black),
                          minimumSize: Size(150, 50),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => notesPage()));
                          //signIn();
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 40,
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 30),
                  child: ElevatedButton.icon(
                    // ignore: sort_child_properties_last
                    icon: Icon(
                      Icons.water,
                      color: Colors.green,
                      size: 30.0,
                    ),
                    label: const Text(
                      'Reservoirs',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      foregroundColor: Color(0xFF343434),
                      backgroundColor: Color(0xFFb8d4c4),
                      textStyle: const TextStyle(color: Colors.black),
                      minimumSize: Size(200, 50),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => reservoirPage()));
                      //signIn();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
