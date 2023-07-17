
import 'dart:ffi';
import 'dart:isolate';

import 'package:digihydro/enums/enums.dart';
import 'package:digihydro/model/snapshot.dart';
import 'package:digihydro/model/statistics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jiffy/jiffy.dart';

class Filters {

  Future<DataSnapshot> query(Filter filter, {Range? date_range}) {
    if(filter != Filter.custom0 && filter != Filter.custom1) {
      String params = getTimestamp(getFilter(filter)).toString() ;
      return FirebaseDatabase.instance.ref('measurement_history/Devices/0420')
          .orderByKey()
          .startAt(params)
          .get();
    } else {
      String start_date = getTimestamp(getFilter(filter, date: date_range?.start_date)).toString();
      String end_date = getTimestamp(getFilter(filter, date: date_range?.end_date)).toString() ;
      return FirebaseDatabase.instance.ref('measurement_history/Devices/0420')
          .orderByKey()
          .startAt(start_date)
          .endAt(end_date)
          .get();
    }
  }

  Future<dynamic> fetch(Filter filter, {Range? date_range}) async {
    DataSnapshot result = await query(filter, date_range: date_range);
    List<DateTime> range = getRange(filter, date_range: date_range);
    Map<dynamic, dynamic>? stats = {};
    final receivePort = ReceivePort();

    if (result.value != null) {
      stats = Map<dynamic, dynamic>.from(result.value as Map<dynamic, dynamic>);
    }

    await Isolate.spawn(processPoints, [stats, filter, receivePort.sendPort, range]);
    return receivePort.first;
  }

  processPoints(List<dynamic> args) {
    Map<dynamic, dynamic> val = args[0];
    Filter filter = args[1];
    SendPort resultPort = args[2];
    List<DateTime> range = args[3];

    Map<dynamic, dynamic> data = {};
    List<Statistics> statistics = [];
    val.forEach((key, value) {
      dynamic data = Statistics.fromMap(value);
      statistics.add(Statistics.instance(data));
    });

    Map<dynamic, Map<dynamic,List<double>>> props = {};
    props.putIfAbsent("temperature", () => {});
    props.putIfAbsent("water_temperature", () => {});
    props.putIfAbsent("humidity", () => {});
    props.putIfAbsent("ph", () => {});
    props.putIfAbsent("tota", () => {});

    statistics.forEach((i) {
      try {
        for (int k=0; k<range.length; k++ ) {
          String stats_date = sanitize(filter, i.timestamp.toString());
          String range_date = sanitize(filter, getTimestamp(range[k]).toString());
          Map<String,dynamic> res = isInRange(filter, stats_date, range_date);

          if(res["isInRange"] == true){
            String key = res["key"];
            props['temperature']?.putIfAbsent(key, () => []);
            props['temperature']?[key]?.add(double.parse(i.Temperature!.toString()));

            props['water_temperature']?.putIfAbsent(key, () => []);
            props['water_temperature']?[key]?.add(double.parse(i.WaterTemperature!.toString()));

            props['humidity']?.putIfAbsent(key, () => []);
            props['humidity']?[key]?.add(double.parse(i.Humidity!.toString()));

            props['ph']?.putIfAbsent(key, () => []);
            props['ph']?[key]?.add(double.parse(i.pH!.toString()));

            props['tota']?.putIfAbsent(key, () => []);
            props['tota']?[key]?.add(double.parse(i.TotalDissolvedSolids!.toString()));

            break;
          }
        }
      } catch (error) {
        //print(error);
      }

    });

    props.forEach((key, value) {
      value = getAverage(value);
    });

    Map<dynamic, List<FlSpot>> result = {};
    result["temperature"] = [];
    result["water_temperature"] =  [];
    result["humidity"] = [];
    result["ph"] = [];
    result["tota"] = [];

    if (statistics.length == 0) {
      result.forEach((key, value) {
        for (int i=0; i<range.length; i++ ) {
          FlSpot val = new FlSpot(i.toDouble(), 0);
          result[key]?.add(val);
        }
      });
    } else {
      for (int i=0; i<range.length; i++) {
        props.forEach((k0, v0) {
          v0.forEach((k1, v1) {
            if(sanitize(filter, getTimestamp(range[i]).toString()) == k1) {
              FlSpot val = new FlSpot(i.toDouble(), double.parse(v1[0].toStringAsFixed(2)));
              result[k0]?.add(val);
            } else if(v0[sanitize(filter, getTimestamp(range[i]).toString())] == null
                && !result[k0]!.contains(new FlSpot(i.toDouble(), 0.0))){
              result[k0]?.add(new FlSpot(i.toDouble(), 0.0));
            }
          });
        });
      }
    }

    data["range_x"] = range;
    data["spots"] = result;
    resultPort.send(data);

  }

  List<DateTime> getRange(Filter filter, {Range? date_range}) {

    DateTime max = filter != Filter.custom0 && filter != Filter.custom1 ? Jiffy.now().dateTime :  getFilter(filter, date: date_range?.end_date);
    DateTime min = getFilter(filter, date: date_range?.start_date);
    DateTime point = min;
    List<DateTime> range = [point];

    switch (filter) {
      case Filter.six_hour:
      case Filter.one_day:
        point = max;
        range = [point];
        while (point.isAfter(min) && !point.isBefore(min) && !Jiffy.parseFromDateTime(point).subtract(hours: 1).dateTime.isBefore(min)) {
          point = Jiffy.parseFromDateTime(point).subtract(hours: 1).dateTime;
          range.add(point);
        }
        break;
      case Filter.custom0:
        while (point.isBefore(max) && !point.isAfter(max) && !Jiffy.parseFromDateTime(point).add(hours: 1).dateTime.isAfter(max)) {
          point = Jiffy.parseFromDateTime(point).add(hours: 1).dateTime;
          range.add(point);
        }
        break;
      case Filter.one_week:
      case Filter.one_month:
        point = max;
        range = [point];
        while (point.isAfter(min) && !point.isBefore(min) && !Jiffy.parseFromDateTime(point).subtract(days: 1).dateTime.isBefore(min)) {
          point = Jiffy.parseFromDateTime(point).subtract(days: 1).dateTime;
          range.add(point);
        }
        break;
      case Filter.custom1:
        while (point.isBefore(max) && !point.isAfter(max) && !Jiffy.parseFromDateTime(point).add(days: 1).dateTime.isAfter(max)) {
          point = Jiffy.parseFromDateTime(point).add(days: 1).dateTime;
          range.add(point);
        }
        break;
    }

    switch (filter) {
      case Filter.six_hour:
      case Filter.one_day:
      case Filter.one_week:
      case Filter.one_month:
        range = new List.from(range.reversed);
        break;
      case Filter.custom0:
      case Filter.custom1:
        break;
    }

    return range;
  }

  Map<dynamic,List<double>> getAverage(Map<dynamic,List<double>> map) {
    map.forEach((key, value) {
      double sum = 0; double ave = 0;
      value.forEach((element) {
        sum = sum + element;
      });
      if (sum != 0) {
        ave = sum/value.length;
      } else {
        ave = 0;
      }
      value.clear();
      value.add(ave);
    });

    return map;
  }

  Map<String, dynamic> isInRange(Filter filter, String stats_date, String range_date) {
    Map<String, dynamic> res = {};
    res.putIfAbsent("key", () => "");
    res.putIfAbsent("isInRange", () => false);

   /* if(filter == Filter.six_hour || filter == Filter.one_day || filter == Filter.custom1) {
      int r0 = (Jiffy.parse(stats_date, pattern: "MM-dd-yyyy hh aa")
          .millisecondsSinceEpoch/1000).ceil();
      int r1 = (Jiffy.parse(range_date, pattern: "MM-dd-yyyy hh aa")
          .millisecondsSinceEpoch/1000).ceil();
      int r2 = (Jiffy.parseFromMillisecondsSinceEpoch(r1 * 1000).add(hours: 1)
          .millisecondsSinceEpoch/1000).ceil();

      if(r0 >= r1 && r0 <= r2) {
        res["key"] = sanitize(filter, r2.toString());
        res['isInRange'] = true;
      }
    }

    if(filter == Filter.one_week || filter == Filter.one_month) {
      if(stats_date == range_date) {
        res["key"] = stats_date;
        res['isInRange'] = true;
      }
    }*/

    if(stats_date == range_date) {
      res["key"] = stats_date;
      res['isInRange'] = true;
    }

    return res;
  }

  String sanitize(Filter filter, String date) {
    String res = "";
    switch (filter) {
      case Filter.six_hour:
      case Filter.one_day:
      case Filter.custom0:
        res = getDateAndTime(date);
        break;
      case Filter.one_week:
      case Filter.one_month:
      case Filter.custom1:
        res = getDate(date);
        break;
    }
    return res;
  }

  DateTime getFilter(Filter filter, {String? date}) {
    switch (filter) {
      case Filter.one_day:
        return Jiffy.now().subtract(days: 1).dateTime;
      case Filter.one_week:
        return Jiffy.now().subtract(weeks: 1).dateTime;
      case Filter.one_month:
        return Jiffy.now().subtract(months: 1).dateTime;
      case Filter.six_hour:
        return Jiffy.now().subtract(hours: 6).dateTime;
      case Filter.custom0:
      case Filter.custom1:
        return Jiffy.parse(date!, pattern: "MM-dd-yyyy HH:mm").dateTime;
    }
  }

  String getTimestamp(DateTime dateTime) {
    return (dateTime.millisecondsSinceEpoch/1000).ceil().toString();
  }

  String getDate(String? val) {
    if(val == null) {return "";}
    return Jiffy.parseFromMillisecondsSinceEpoch(int.parse(val.trim()) * 1000).format(pattern:"MM-dd-yyyy");
  }

  String getDateAndTime(String? val) {
    if(val == null) {return "";}
    return Jiffy.parseFromMillisecondsSinceEpoch(int.parse(val.trim()) * 1000).format(pattern: "MM-dd-yyyy hh aa");
  }

  List<Map> filters = [
    {'filter' : '6HR', 'active': false,},
    {'filter' : '1D', 'active': false,},
    {'filter' : '1W', 'active': false,},
    {'filter' : '1M', 'active': false,},
  ];

}
