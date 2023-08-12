import 'package:digihydro/enums/constant.dart';
import 'package:digihydro/enums/enums.dart';
import 'package:digihydro/model/snapshot.dart';
import 'package:digihydro/model/statistics.dart';
import 'package:digihydro/utils/compare_data.dart';
import 'package:digihydro/utils/filter_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';

class ChartCompare extends StatefulWidget {
  ChartCompare({Key? key,
      required this.initialBatch, required this.batch_list})
      : super(key: key);
  final Batch initialBatch;
  final List<Batch> batch_list;

  @override
  chartCompareScreen createState() => chartCompareScreen();
}

class chartCompareScreen extends State<ChartCompare> {
  final ScrollController controller = ScrollController();
  final page_controller = PageController();
  Batch? _selectedValue;
  List<Color> gradientColors = [
    Colors.teal,
    Colors.amberAccent,
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: CompareData().fetch(widget.initialBatch, compare_batch: _selectedValue),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error = ${snapshot.error}'));
            }

            if (snapshot.hasData && snapshot.data != null) {
              List<Map<dynamic, dynamic>> data = snapshot.data;

              return Container(
                  child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Text("Batch name:"),
                            ),
                            Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: DropdownButton<Batch>(
                                    value: widget.initialBatch,
                                    style: TextStyle(color: Colors.teal),
                                    onChanged: null,
                                    items: widget.batch_list.map<DropdownMenuItem<Batch>>((Batch value) {
                                      return DropdownMenuItem<Batch>(
                                        value: value,
                                        child: Text(value.name!),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                Icon(Icons.square_rounded, color: Colors.teal)
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Text("Compare to batch:"),
                            ),
                            Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: DropdownButton<Batch>(
                                    hint: Text('Select item'),
                                    value: _selectedValue,
                                    style: TextStyle(color: Colors.grey),
                                    onChanged: (Batch? newValue) {
                                      setState(() {
                                        _selectedValue = newValue;
                                      });
                                    },
                                    items: widget.batch_list.map<DropdownMenuItem<Batch>>((Batch value) {
                                      return DropdownMenuItem<Batch>(
                                        value: value,
                                        child: Text(value.name!),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                Icon(Icons.square_rounded, color: Colors.red)
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    child: PageView.builder(
                      controller: page_controller,
                      itemCount: 5,
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        List<FlSpot> initial_data = [];
                        List<FlSpot> compare_data = [];
                        double maxY = 0;
                        double interval = 0;
                        double reserve_size = 0;
                        String title = "";

                        switch (index) {
                          case 0:
                            initial_data = data[0]["spots"][Constant.air_temperature];
                            compare_data = data.length > 1 ? data[1]["spots"][Constant.air_temperature] : [];
                            title = "AIR TEMPERATURE";
                            maxY = 100;
                            interval = 20;
                            reserve_size = 35;
                            break;
                          case 1:
                            initial_data = data[0]["spots"][Constant.water_temperature];
                            compare_data = data.length > 1 ? data[1]["spots"][Constant.water_temperature] : [];
                            title = "WATER TEMPERATURE";
                            maxY = 100;
                            interval = 20;
                            reserve_size = 35;
                            break;
                          case 2:
                            initial_data = data[0]["spots"][Constant.humidity];
                            compare_data = data.length > 1 ? data[1]["spots"][Constant.humidity] : [];
                            title = "HUMIDITY";
                            maxY = 100;
                            interval = 20;
                            reserve_size = 35;
                            break;
                          case 3:
                            initial_data = data[0]["spots"][Constant.ph];
                            compare_data = data.length > 1 ? data[1]["spots"][Constant.ph] : [];
                            title = "WATER ACIDITY";
                            maxY = 30;
                            interval = 5;
                            reserve_size = 35;
                            break;
                          case 4:
                            initial_data = data[0]["spots"][Constant.tds];
                            compare_data = data.length > 1 ? data[1]["spots"][Constant.tds] : [];
                            title = "TOTAL DISOLVED SOLIDS";
                            maxY = 2000;
                            interval = 500;
                            reserve_size = 50;
                            break;
                        }

                        Map<dynamic, double> values = getValues(data);
                        double maxX = values["maxX"]!;
                        double maxX_interval = values["maxX_interval"]!;
                        double vertical_interval = values["vertical_interval"]!;

                        return Builder(builder: (context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                              child: Column(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            10, 0, 10, 10),
                                        child: Text('$title'),
                                      ),
                                    ],
                                  ),
                                  Flexible(
                                    child: LineChart(
                                      LineChartData(
                                        borderData: flBorderData(),
                                        gridData: flGridData(vertical_interval),
                                        titlesData: flTitlesData(data, maxX_interval, interval, reserve_size),
                                        lineTouchData: lineTouchData(index: index),
                                        maxY: maxY,
                                        minY: 0,
                                        minX: 0,
                                        maxX: maxX,
                                        lineBarsData: [
                                          lineChartBarData(initial_data, Colors.teal),
                                          if(compare_data.isNotEmpty)
                                            lineChartBarData(compare_data, Colors.red),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      InkWell(
                        onTap: () async {
                          if (page_controller.page == 0 ) {
                            return;
                          }
                          page_controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                        },
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                            child: Icon(Icons.arrow_back)
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          if (page_controller.page == 4) {
                            return;
                          }
                          page_controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                        },
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                            child: Icon(Icons.arrow_forward)
                        ),
                      ),
                    ],
                  ),
                  Column(
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
                                    "Details",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF1a1a1a),
                                      fontWeight: FontWeight.bold,
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
                                  InkWell(
                                    onTap: () async {
                                      showDialog(
                                        context: context,
                                        //barrierColor:
                                        //    Color(0xFF1a1a1a).withOpacity(0.8),
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            insetPadding: EdgeInsets.fromLTRB(
                                                20, 0, 20, 0),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  RichText(
                                                    text: TextSpan(
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 16,
                                                      ),
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                          text:
                                                          "Information:\n\n",
                                                          style: TextStyle(
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: 'MIN: ',
                                                          style: TextStyle(
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                          'Minimum recorded value within the given time frame.\n',
                                                          style: TextStyle(
                                                            color:
                                                            Colors.black,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: 'MAX: ',
                                                          style: TextStyle(
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                          'Maximum recorded value within the given time frame.\n',
                                                          style: TextStyle(
                                                            color:
                                                            Colors.black,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: 'AVE: ',
                                                          style: TextStyle(
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                          'Computed average value for the given timeframe.',
                                                          style: TextStyle(
                                                            color:
                                                            Colors.black,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                child: Text('OK'),
                                                style:
                                                ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                  Colors.green,
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
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(0, 8, 10, 0),
                                      child: Container(
                                        child: Icon(
                                          Icons.info,
                                          size: 24,
                                        ),
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 20),
                        child: ListView.builder(
                          itemCount: data.length,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (BuildContext context, int index) {
                            Ranges range = data[index]["ranges"];
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(index == 0 ? range.initial_batch!.name!
                                            : range.compare_batch!.name!,
                                          style: TextStyle(fontSize: 15, color: index == 0 ? Colors.teal : Colors.red),
                                          textAlign: TextAlign.start,
                                        ),
                                        Text("Range: " + (index == 0 ? range.initial_batch!.range!.start_date!
                                            : range.compare_batch!.range!.start_date!) + " - "  + (index == 0 ? range.initial_batch!.status != "ongoing" ? range.initial_batch!.range!.end_date! : "PRESENT"
                                            : range.compare_batch!.status != "ongoing" ? range.compare_batch!.range!.end_date! : "PRESENT"),
                                          style: TextStyle(fontSize: 12, color: index == 0 ? Colors.teal : Colors.red),
                                          textAlign: TextAlign.start,
                                        ),
                                        Text("Duration: " + (index == 0 ? (range.initial_batch!.batch_duration! + 1).toString() +  ((range.initial_batch!.batch_duration! + 1) > 1 ? " days" : " day")
                                            : (range.compare_batch!.batch_duration! + 1).toString() + ((range.compare_batch!.batch_duration! + 1) > 1 ? " days" : " day")),
                                          style: TextStyle(fontSize: 12, color: index == 0 ? Colors.teal : Colors.red),
                                          textAlign: TextAlign.start,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Table(
                                  border: TableBorder.all(),
                                  columnWidths: {
                                    0: FlexColumnWidth(4),
                                    1: FlexColumnWidth(2),
                                    2: FlexColumnWidth(2),
                                    3: FlexColumnWidth(2),
                                  }, // Allows to add a border decoration around your table
                                  children: minAndMaxTable(data[index]["min_max"]),
                                ),
                              ],
                            );
                          }
                        ),
                      ),
                    ],
                  ),
                ],
              ));
            } else {
              return Center(child: Text('no data found!'));
            }
          } else {
            return Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height - 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }
        });
  }
}

//get values for maxX, maxX_interval, vertical_interval
Map<dynamic, double> getValues(List<Map<dynamic, dynamic>> data) {

  double maxX = data[0]["duration"] - 1;
  double maxX_interval = data[0]["duration"] - 1;
  double vertical_interval = 1;

  Map<dynamic, double> res = {};
  res.putIfAbsent("maxX", () => maxX);
  res.putIfAbsent("maxX_interval", () => maxX_interval);
  res.putIfAbsent("vertical_interval", () => vertical_interval);
  return res;

}

//chart border data
FlBorderData flBorderData() {
  return FlBorderData(
    show: true,
    border: Border.all(color: const Color(0xff37434d)),
  );
}

//grid data lines
FlGridData flGridData(double vertical_interval) {
  return FlGridData(
    show: false,
    verticalInterval: vertical_interval,
    getDrawingHorizontalLine: (value) {
      return FlLine(color: Colors.grey, strokeWidth: 1);
    },
    getDrawingVerticalLine: (value) {
      return FlLine(color: Colors.grey, strokeWidth: 1);
    },
  );
}

//side titles data
FlTitlesData flTitlesData(List<Map<dynamic, dynamic>> data,
    double maxX_interval, double interval, double reserve_size) {
  return FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
        sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            interval: maxX_interval,
            getTitlesWidget: (value, meta) {
              String _value = (value.toInt() + 1).toString();
              return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 6,
                  fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                  child: Text(
                    "Day $_value",
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ));
            })),
    rightTitles: AxisTitles(
        sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 15,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(axisSide: meta.axisSide, child: Text(""));
            })),
    topTitles: AxisTitles(sideTitles: SideTitles()),
    leftTitles: AxisTitles(
        sideTitles: SideTitles(
            showTitles: true,
            reservedSize: reserve_size,
            interval: interval,
            getTitlesWidget: (value, meta) {
              String _value = value.toInt().toString();
              return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 6,
                  fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                  child: Text("$_value",
                      style: TextStyle(
                        fontSize: 10,
                      )));
            })),
  );
}

//chart data
LineChartBarData lineChartBarData(List<FlSpot> data, Color color) {

  List<Color> gradientColors = [
    Colors.teal,
    Colors.amberAccent,
  ];

  return LineChartBarData(
    spots: data,
    isCurved: true,
    barWidth: 2,
    preventCurveOverShooting: true,
    isStrokeJoinRound: true,
    color: color,
    dotData: FlDotData(
      show: false,
    ),
    belowBarData: BarAreaData(
      gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
    ),
  );
}

//tooltip data
LineTouchData lineTouchData({int? index}) {
  return LineTouchData(
    touchTooltipData: LineTouchTooltipData(
      tooltipBgColor: Colors.white,
      tooltipBorder: BorderSide(color: Colors.teal),
      fitInsideHorizontally: true,
      fitInsideVertically: true,
      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {

        return touchedBarSpots.map((barSpot) {
          final flSpot = barSpot;
          String title = "";
          String i = "";

          int _index = index == null ? flSpot.barIndex : index;
          switch (_index) {
            case 0:
              i = 'A. Temp.(avg): ${flSpot.y.toString()} °C';
              break;
            case 1:
              i = 'W. Temp.(avg): ${flSpot.y.toString()} °C';
              break;
            case 2:
              i = 'Humidity(avg): ${flSpot.y.toString()} %';
              break;
            case 3:
              i = 'PH(avg): ${flSpot.y.toString()} pH';
              break;
            case 4:
              i = 'TDS(avg): ${flSpot.y.toString()} PPM';
              break;
          }

          title = 'Day ${(flSpot.x + 1).toStringAsFixed(0)}\n $i';
          return LineTooltipItem(
            '$title',
            TextStyle(color: flSpot.barIndex == 0 ? Colors.teal : Colors.red, fontSize: 10),
            textAlign: TextAlign.center,
          );
        }).toList();
      },
    ),
  );
}

//min and max values
List<TableRow> minAndMaxTable(List<MinAndMax> data) {
  List<TableRow> row = [];
  row.add(
    TableRow(children: [
      Text(''),
      Text(
        'MIN',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        'MAX',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        'AVE',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      )
    ]),
  );

  if (data.length != 0) {
    for (var min_max in data) {
      row.add(TableRow(children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: provideTitle(min_max.title.toString())),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              min_max.min.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            )),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              min_max.max.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            )),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              min_max.ave.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            )),
      ]));
    }
  }

  return row;
}

Widget provideTitle(String title) {
  switch (title) {
    case "Air Temp":
      return Container(
        child: Row(
          children: [
            Icon(
              Icons.thermostat,
              size: 15,
            ),
            Text(
              'Air Temp (°C)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    case "Water Temp":
      return Container(
        child: Row(
          children: [
            Image.asset(
              'images/dew_point_FILL0_wght400_GRAD0_opsz48.png',
              height: 15,
              width: 15,
            ),
            Text(
              'Water Temp (°C)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    case "Humidity":
      return Container(
        child: Row(
          children: [
            Image.asset(
              'images/humidity_percentage_FILL0_wght400_GRAD0_opsz48.png',
              height: 15,
              width: 15,
            ),
            Text(
              'Humidity (%)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    case "Water Acidity":
      return Container(
        child: Row(
          children: [
            Image.asset(
              'images/water_ph_FILL0_wght400_GRAD0_opsz48.png',
              height: 15,
              width: 15,
            ),
            Text(
              'Water Acidity (pH)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    case "TDS":
      return Container(
        child: Row(
          children: [
            Image.asset(
              'images/total_dissolved_solids_FILL0_wght400_GRAD0_opsz48.png',
              height: 15,
              width: 15,
            ),
            Text(
              'TDS',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
  }

  return SizedBox();
}

String getRangeTitle(Filter filter, String date) {
  String res = "";
  switch (filter) {
    case Filter.six_hour:
    case Filter.one_day:
    case Filter.custom0:
      DateTime _date = DateFormat(FilterData.hourly_pattern).parse(date);
      res = DateFormat(FilterData.hourly_pattern_actual_value).format(_date);
      break;
    case Filter.one_week:
    case Filter.one_month:
    case Filter.custom1:
      res = date;
      break;
  }
  return res;
}
