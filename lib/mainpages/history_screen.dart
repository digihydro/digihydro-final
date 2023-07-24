import 'package:digihydro/enums/enums.dart';
import 'package:digihydro/mainpages/chart.dart';
import 'package:digihydro/mainpages/notif.dart';
import 'package:digihydro/utils/filter_data.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:digihydro/drawer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin localNotif =
    FlutterLocalNotificationsPlugin();

class historyPage extends StatefulWidget {
  historyPage({Key? key, required this.filter, this.title, this.snapshot})
      : super(key: key);
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

  bool showAll = false;
  List<Map> filters = FilterData().filters;
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
    if (widget.filter != Filter.custom0 && widget.filter != Filter.custom1) {
      setFilter(filters[widget.filter.index], widget.filter);
    }
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

  String getFilterTitle(Filter filter) {
    String title = "Data Track Record";
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
        title =
            widget.title != null ? widget.title.toString() : 'Stats History';
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.green,
        //automaticallyImplyLeading: false,
        /*iconTheme: const IconThemeData(
          color: Colors.white,
          size: 40.00,
        ),*/
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
              child: Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                    child: Icon(
                      Icons.analytics,
                      size: 50,
                      color: Colors.green,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 10, 5, 0),
                    child: Text(
                      'Stats History',
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
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
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
                                "Data Track Record",
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
                  Visibility(
                    visible: widget.filter != Filter.custom0 &&
                        widget.filter != Filter.custom1,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 50,
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
                                width: 50,
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
                                width: 50,
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
                                width: 50,
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
                        ),
                      ],
                    ),
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
