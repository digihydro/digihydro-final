import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:digihydro/create/add_reser.dart';
import 'package:digihydro/drawer_screen.dart';
import 'package:flutter/material.dart';

class reservoirPage extends StatefulWidget {
  @override
  reserv createState() => reserv();
}

class reserv extends State<reservoirPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final auth = FirebaseAuth.instance;
  late String currentUserID;
  final ref = FirebaseDatabase.instance.ref('Reservoir');

  @override
  void initState() {
    super.initState();
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      currentUserID = currentUser.uid;
    }
  }

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
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DropDownReserv()));
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
                  "images/reservoirs.png",
                  fit: BoxFit.cover
              ),
              title:  Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child:
                Container(
                  child: Text(
                    'RESERVOIRS',
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
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 12, 0, 12),
              child: Column(
                children: [
                  FirebaseAnimatedList(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 100),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    query: ref.orderByChild('userId').equalTo(currentUserID),
                    itemBuilder: (BuildContext context, DataSnapshot snapshot,
                        Animation<double> animation, int index) {
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
                                Row(
                                  children: [
                                    Text(
                                        snapshot.child('reservName').value.toString(),
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ],
                                ),
                                Row(
                                  children: [Text(' ')],
                                ),
                                Row(
                                  children: [
                                    Text(
                                        'Grow Method: ' +
                                            snapshot
                                                .child('growMethod')
                                                .value
                                                .toString(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context).primaryColor,
                                        )),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                        'Nutrient Solution: ' +
                                            snapshot
                                                .child('nutrientSol')
                                                .value
                                                .toString(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context).primaryColor,
                                        )),
                                  ],
                                ),
                                Row(
                                  children: [Text(' ')],
                                ),
                                Row(
                                  children: [
                                    Text(
                                        'Greenhouse: ' +
                                            snapshot.child('greenH').value.toString(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context).primaryColor,
                                        )),
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
          )
        ],
      ),
    );
  }
}
