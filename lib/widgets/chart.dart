import 'package:digihydro/enums/constant.dart';
import 'package:digihydro/enums/enums.dart';
import 'package:digihydro/model/statistics.dart';
import 'package:digihydro/utils/filter_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';

class Chart extends StatefulWidget {
  Chart(
      {Key? key,
      required this.filter,
      required this.showAll,
      required this.axis,
      this.snapshot,
      required this.isFromDashboard})
      : super(key: key);
  final Filter filter;
  final bool showAll;
  final Axis axis;
  final snapshot;
  final bool isFromDashboard;

  @override
  chartScreen createState() => chartScreen();
}

class chartScreen extends State<Chart> {
  final ScrollController controller = ScrollController();
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
        future: FilterData().fetch(widget.filter, date_range: widget.snapshot),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error = ${snapshot.error}'));
            }

            if (snapshot.hasData && snapshot.data != null) {
              Map<dynamic, dynamic> data = snapshot.data;

              Widget chart = ShowIndividualChart(
                  data, widget.filter, gradientColors, widget.axis, controller);
              if (widget.showAll) {
                chart = ShowAllChart(data, widget.filter, gradientColors);
              }

              return Container(
                  child: Column(
                children: [
                  Container(child: chart),
                  Visibility(
                    visible: !widget.isFromDashboard,
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
                                                                "Date Range\n",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: 'From: ',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                "${getRangeTitle(widget.filter, data["range_x"][0]).toString()}\t\t",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: 'To: ',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                "${getRangeTitle(widget.filter, data["range_x"][data["range_x"].length - 1]).toString()}\n\n",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14,
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
                                        padding:
                                            EdgeInsets.fromLTRB(0, 8, 10, 0),
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
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                          child: Table(
                            border: TableBorder.all(),
                            columnWidths: {
                              0: FlexColumnWidth(4),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(2),
                            }, // Allows to add a border decoration around your table
                            children: minAndMaxTable(data["min_max"]),
                          ),
                        ),
                      ],
                    ),
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

//show chart
Widget ShowAllChart(
    Map<dynamic, dynamic> data, Filter filter, List<Color> gradientColors) {
  return Builder(builder: (context) {
    Map<dynamic, double> values = getValues(data, filter);
    double maxX = values["maxX"]!;
    double maxX_interval = values["maxX_interval"]!;
    double vertical_interval = values["vertical_interval"]!;

    return Container(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 300,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 10, 10),
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 350,
                child: Column(
                  children: [
                    Flexible(
                      child: LineChart(
                        LineChartData(
                            borderData: flBorderData(),
                            gridData: flGridData(vertical_interval),
                            titlesData: flTitlesData(
                                data, filter, maxX_interval, 300, 50),
                            lineTouchData: lineTouchData(filter, data),
                            maxY: 1500,
                            minY: 0,
                            minX: 0,
                            maxX: maxX,
                            lineBarsData: [
                              lineChartBarData(
                                  data["spots"][Constant.air_temperature],
                                  Colors.green,
                                  true),
                              lineChartBarData(
                                  data["spots"][Constant.water_temperature],
                                  Colors.blue,
                                  true),
                              lineChartBarData(data["spots"][Constant.humidity],
                                  Colors.orange, true),
                              lineChartBarData(data["spots"][Constant.ph],
                                  Colors.yellow, true),
                              lineChartBarData(data["spots"][Constant.tds],
                                  Colors.red, true),
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });
}

//show chart individually
Widget ShowIndividualChart(Map<dynamic, dynamic> data, Filter filter,
    List<Color> gradientColors, Axis axis, ScrollController controller) {
  return Builder(builder: (context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 300,
      child: Scrollbar(
        thickness: 15.0,
        thumbVisibility: true,
        controller: controller,
        child: ListView.builder(
          controller: controller,
          itemCount: data["spots"].length,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          scrollDirection: axis,
          itemBuilder: (BuildContext context, int index) {
            List<FlSpot> _data = [];
            double maxY = 0;
            double interval = 0;
            double reserve_size = 0;
            String title = "";

            switch (index) {
              case 0:
                _data = data["spots"][Constant.air_temperature];
                title = "AIR TEMPERATURE";
                maxY = 100;
                interval = 20;
                reserve_size = 35;
                break;
              case 1:
                _data = data["spots"][Constant.water_temperature];
                title = "WATER TEMPERATURE";
                maxY = 100;
                interval = 20;
                reserve_size = 35;
                break;
              case 2:
                _data = data["spots"][Constant.humidity];
                title = "HUMIDITY";
                maxY = 100;
                interval = 20;
                reserve_size = 35;
                break;
              case 3:
                _data = data["spots"][Constant.ph];
                title = "WATER ACIDITY";
                maxY = 100;
                interval = 20;
                reserve_size = 35;
                break;
              case 4:
                _data = data["spots"][Constant.tds];
                title = "TOTAL DISOLVED SOLIDS";
                maxY = 2000;
                interval = 500;
                reserve_size = 50;
                break;
            }

            Map<dynamic, double> values = getValues(data, filter);
            double maxX = values["maxX"]!;
            double maxX_interval = values["maxX_interval"]!;
            double vertical_interval = values["vertical_interval"]!;

            return Builder(builder: (context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: 300,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 20, 10),
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
                            titlesData: flTitlesData(data, filter,
                                maxX_interval, interval, reserve_size),
                            lineTouchData:
                                lineTouchData(filter, data, index: index),
                            maxY: maxY,
                            minY: 0,
                            minX: 0,
                            maxX: maxX,
                            lineBarsData: [
                              lineChartBarData(_data, Colors.green, false),
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
    );
  });
}

//get values for maxX, maxX_interval, vertical_interval
Map<dynamic, double> getValues(Map<dynamic, dynamic> data, Filter filter) {
  double maxX = 0;
  double maxX_interval = 0;
  double vertical_interval = 0;

  if (filter == Filter.one_month) {
    if (data['range_x'].length == 31) {
      maxX = 30;
      maxX_interval = 30;
      vertical_interval = 2.5;
    } else {
      maxX = 29;
      maxX_interval = 29;
      vertical_interval = 2.416666666666667;
    }
  } else if (filter == Filter.one_week) {
    maxX = 6;
    maxX_interval = 6;
    vertical_interval = 1;
  } else if (filter == Filter.one_day || filter == Filter.custom0) {
    maxX = 23;
    maxX_interval = 23;
    vertical_interval = 1.916666666666667;
  } else if (filter == Filter.six_hour) {
    maxX = 5;
    maxX_interval = 5;
    vertical_interval = 1;
  } else if (filter == Filter.custom1) {
    maxX = (data['range_x'].length.toDouble() - 1);
    maxX_interval = (data['range_x'].length.toDouble() - 1);

    if (data['range_x'].length > 31 && data['range_x'].length <= 372) {
      vertical_interval = data['range_x'].length/12;
    } else {
      vertical_interval = 1;
    }

  }

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
    show: true,
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
FlTitlesData flTitlesData(Map<dynamic, dynamic> data, Filter filter,
    double maxX_interval, double interval, double reserve_size) {
  return FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
        sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            interval: maxX_interval,
            getTitlesWidget: (value, meta) {
              String _value = value.toInt().toString();

              if (filter == Filter.one_day || filter == Filter.custom0) {
                if (value.toInt() == 0 || value.toInt() == 23) {
                  DateTime date = DateFormat(FilterData.hourly_pattern)
                      .parse(data['range_x'][value.toInt()]);
                  _value = DateFormat(FilterData.hourly_pattern_actual_value)
                      .format(date);
                }
              } else if (filter == Filter.six_hour) {
                if (value.toInt() == 0 || value.toInt() == 5) {
                  DateTime date = DateFormat(FilterData.hourly_pattern)
                      .parse(data['range_x'][value.toInt()]);
                  _value = DateFormat(FilterData.hourly_pattern_actual_value)
                      .format(date);
                }
              } else if (filter == Filter.one_month) {
                if (value.toInt() == 0 || value.toInt() == 30) {
                  _value = data['range_x'][value.toInt()];
                }
              } else if (filter == Filter.one_week) {
                if (value.toInt() == 0 || value.toInt() == 6) {
                  _value = data['range_x'][value.toInt()];
                }
              } else if (filter == Filter.custom1) {
                if (value.toInt() == 0 ||
                    value.toInt() == (data['range_x'].length - 1)) {
                  _value = data['range_x'][value.toInt()];
                }
              }

              return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 6,
                  fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                  child: Text(
                    "$_value",
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
LineChartBarData lineChartBarData(
    List<FlSpot> data, Color color, bool isShowAll) {
  List<Color> gradientColors = [
    Colors.teal,
    Colors.amberAccent,
  ];

  return LineChartBarData(
    spots: data,
    isCurved: true,
    barWidth: isShowAll ? 1 : 2,
    preventCurveOverShooting: true,
    isStrokeJoinRound: true,
    color: color,
    dotData: FlDotData(
      show: false,
    ),
    belowBarData: BarAreaData(
      show: isShowAll ? false : true,
      gradient: isShowAll
          ? null
          : LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
    ),
  );
}

//tooltip data
LineTouchData lineTouchData(Filter filter, Map<dynamic, dynamic> data,
    {int? index}) {
  return LineTouchData(
    touchTooltipData: LineTouchTooltipData(
      tooltipBgColor: Colors.teal,
      fitInsideHorizontally: true,
      fitInsideVertically: true,
      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
        int k = 0;
        return touchedBarSpots.map((barSpot) {
          final flSpot = barSpot;
          String title = "";
          String i = "";

          if (filter == Filter.one_month ||
              filter == Filter.one_week ||
              filter == Filter.custom1) {
            title = data['range_x'][flSpot.x.toInt()];
          } else if (filter == Filter.one_day ||
              filter == Filter.six_hour ||
              filter == Filter.custom0) {
            DateTime date = DateFormat(FilterData.hourly_pattern)
                .parse(data['range_x'][flSpot.x.toInt()]);
            title =
                DateFormat(FilterData.hourly_pattern_actual_value).format(date);
          }

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

          title = '${k == 0 ? '$title\n' : ''}$i';
          k++;

          return LineTooltipItem(
            '$title',
            TextStyle(color: Colors.white, fontSize: 10),
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
