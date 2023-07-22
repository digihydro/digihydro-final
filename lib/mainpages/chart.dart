import 'dart:isolate';
import 'package:digihydro/enums/enums.dart';
import 'package:digihydro/utils/filters.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

class Chart extends StatefulWidget {
  Chart(
      {Key? key,
      required this.filter,
      required this.showAll,
      required this.axis,
      this.snapshot})
      : super(key: key);
  final Filter filter;
  final bool showAll;
  final Axis axis;
  final snapshot;

  @override
  chartScreen createState() => chartScreen();
}

class chartScreen extends State<Chart> {
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
    return Scaffold(
      body: FutureBuilder(
        future: Filters().fetch(widget.filter, date_range: widget.snapshot),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error = ${snapshot.error}'));
            }

            if (snapshot.hasData && snapshot.data != null) {
              Map<dynamic, dynamic> data = snapshot.data;

              if (widget.showAll) {
                return ShowAllChart(data, widget.filter, gradientColors);
              } else {
                return ShowIndividualChart(
                    data, widget.filter, gradientColors, widget.axis);
              }
            } else {
              return Center(child: Text('no data found!'));
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
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
          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 20, 10),
          child: Stack(
            children: [
              Column(
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
                            lineChartBarData(data["spots"]["temperature"],
                                Colors.green, true),
                            lineChartBarData(data["spots"]["water_temperature"],
                                Colors.blue, true),
                            lineChartBarData(
                                data["spots"]["humidity"], Colors.orange, true),
                            lineChartBarData(
                                data["spots"]["ph"], Colors.yellow, true),
                            lineChartBarData(
                                data["spots"]["tota"], Colors.red, true),
                          ]),
                    ),
                  ),
                ],
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
    List<Color> gradientColors, Axis axis) {
  return Builder(builder: (context) {
    return ListView.builder(
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
            _data = data["spots"]["temperature"];
            title = "AIR TEMPERATURE";
            maxY = 100;
            interval = 20;
            reserve_size = 35;
            break;
          case 1:
            _data = data["spots"]["water_temperature"];
            title = "WATER TEMPERATURE";
            maxY = 100;
            interval = 20;
            reserve_size = 35;
            break;
          case 2:
            _data = data["spots"]["humidity"];
            title = "HUMIDITY";
            maxY = 100;
            interval = 20;
            reserve_size = 35;
            break;
          case 3:
            _data = data["spots"]["ph"];
            title = "WATER ACIDITY";
            maxY = 100;
            interval = 20;
            reserve_size = 35;
            break;
          case 4:
            _data = data["spots"]["tota"];
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
              child: Stack(
                children: [
                  Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20, 5, 10, 10),
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
                              ]),
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                        thickness: 1,
                        indent: 10,
                        endIndent: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
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
      vertical_interval = 1;
    } else {
      maxX = 29;
      maxX_interval = 29;
      vertical_interval = 1;
    }
  } else if (filter == Filter.one_week) {
    maxX = 6;
    maxX_interval = 6;
    vertical_interval = 1;
  } else if (filter == Filter.one_day || filter == Filter.custom0) {
    maxX = 23;
    maxX_interval = 23;
    vertical_interval = 1;
  } else if (filter == Filter.six_hour) {
    maxX = 5;
    maxX_interval = 5;
    vertical_interval = 1;
  } else if (filter == Filter.custom1) {
    maxX = (data['range_x'].length.toDouble() - 1);
    maxX_interval = (data['range_x'].length.toDouble() - 1);
    vertical_interval = 500;
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

              if (filter == Filter.one_month) {
                if (value.toInt() == 0) {
                  _value = Jiffy.parseFromDateTime(data['range_x'][0])
                      .format(pattern: "MM-dd-yyyy")
                      .toString();
                } else if (value.toInt() == 29 || value.toInt() == 30) {
                  _value = Jiffy.parseFromDateTime(
                          data['range_x'][data['range_x'].length - 1])
                      .format(pattern: "MM/dd/yyyy")
                      .toString();
                }
              } else if (filter == Filter.one_week) {
                if (value.toInt() == 0 || value.toInt() == 6) {
                  _value =
                      Jiffy.parseFromDateTime(data['range_x'][value.toInt()])
                          .format(pattern: "MM/dd/yyyy")
                          .toString();
                }
              } else if (filter == Filter.one_day || filter == Filter.custom0) {
                if (value.toInt() == 0 || value.toInt() == 23) {
                  _value =
                      Jiffy.parseFromDateTime(data['range_x'][value.toInt()])
                          .format(pattern: "MM/dd/yy h:00 aa")
                          .toString();
                }
              } else if (filter == Filter.six_hour) {
                if (value.toInt() == 0 || value.toInt() == 5) {
                  _value =
                      Jiffy.parseFromDateTime(data['range_x'][value.toInt()])
                          .format(pattern: "MM/dd/yy h:00 aa")
                          .toString();
                }
              } else if (filter == Filter.custom1) {
                if (value.toInt() == 0 ||
                    value.toInt() == (data['range_x'].length - 1)) {
                  _value =
                      Jiffy.parseFromDateTime(data['range_x'][value.toInt()])
                          .format(pattern: "MM/dd/yy")
                          .toString();
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
            title = Jiffy.parseFromDateTime(data['range_x'][flSpot.x.toInt()])
                .format(pattern: "MM/dd/yyyy")
                .toString();
          } else if (filter == Filter.one_day ||
              filter == Filter.six_hour ||
              filter == Filter.custom0) {
            title = Jiffy.parseFromDateTime(data['range_x'][flSpot.x.toInt()])
                .format(pattern: "MM/dd/yy hh aa")
                .toString();
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
