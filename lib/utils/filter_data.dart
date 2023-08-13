
import 'dart:isolate';

import 'package:digihydro/enums/constant.dart';
import 'package:digihydro/enums/enums.dart';
import 'package:digihydro/model/snapshot.dart';
import 'package:digihydro/model/statistics.dart';
import 'package:digihydro/utils/min_max.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jiffy/jiffy.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';

class FilterData {

  static String daily_pattern  = "MM-dd-yyyy";
  static String hourly_pattern = "MM-dd-yyyy HH:00";
  static String hourly_pattern_actual_value = "MM-dd-yyyy hh:mm a";
  static String timezone = "Asia/Manila";

  Future<DataSnapshot> query(Filter filter, String type, {Range? date_range}) {
    var arr = [Filter.six_hour, Filter.one_day, Filter.custom0];
    String node = arr.contains(filter) ? "HourlyData/$type" : "DailyData/$type";

    if(filter != Filter.custom0 && filter != Filter.custom1) {
      String params = getFilter(filter);
      return FirebaseDatabase.instance.ref(node)
          .orderByChild("timestamp")
          .startAt(getTimeStamp(filter, params))
          .get();

    } else {
      String start_date = getFilter(filter, date: date_range?.start_date);
      String end_date = getFilter(filter, date: date_range?.end_date);
      return FirebaseDatabase.instance.ref(node)
          .orderByChild("timestamp")
          .startAt(getTimeStamp(filter, start_date))
          .endAt(getTimeStamp(filter, end_date))
          .get();
    }
  }

  Future<dynamic> fetch(Filter filter, {Range? date_range}) async {
    Map<String, dynamic>? stats = {};
    final receivePort = ReceivePort();

    List<String> range = getRange(filter, date_range: date_range);
    var arr = [Constant.air_temperature, Constant.water_temperature, Constant.humidity, Constant.ph, Constant.tds];
    for (int i=0; i<arr.length; i++) {
      DataSnapshot result = await query(filter, arr[i], date_range: date_range);
      if (result.value != null) {
        stats.putIfAbsent(arr[i], () => Map<String, dynamic>.from(result.value as Map<dynamic, dynamic>));
      }
    }

    await Isolate.spawn(processPoints, [stats, receivePort.sendPort, range]);
    return receivePort.first;
  }

  processPoints(List<dynamic> args) async {
    Map<String, dynamic> val = args[0];
    SendPort resultPort = args[1];
    List<String> range = args[2];
    Map<dynamic, dynamic> data = {};

    Map<dynamic, List<Map<String, dynamic>>> props = {};
    props.putIfAbsent("Air Temp", () => []);
    props.putIfAbsent("Water Temp", () => []);
    props.putIfAbsent("Humidity", () => []);
    props.putIfAbsent("Water Acidity", () => []);
    props.putIfAbsent("TDS", () => []);

    Map<dynamic, List<FlSpot>> result = {};
    result[Constant.air_temperature] = [];
    result[Constant.water_temperature] =  [];
    result[Constant.humidity] = [];
    result[Constant.ph] = [];
    result[Constant.tds] = [];

    val.forEach((raw_key, raw_value) {
      for (int i=0; i<range.length; i++) {
        if(raw_value[range[i]] != null) {
          StatisticsData sd = StatisticsData.fromMap(raw_value[range[i]]);
          props[getKey(raw_key)]?.add({"total_value": sd.total_value ?? 0, "count": sd.count ?? 0, "min": sd.min ?? 0, "max" : sd.max ?? 0});
          FlSpot val = new FlSpot(i.toDouble(), double.parse((sd.total_value!/sd.count!).toStringAsFixed(2)));
          result[raw_key]!.add(val);
        }else {
          result[raw_key]!.add(new FlSpot(i.toDouble(), 0.0));
        }
      }
    });

    if (val.length == 0) {
      for (int i=0; i<range.length; i++ ) {
        FlSpot val = new FlSpot(i.toDouble(), 0.00);
        result[Constant.air_temperature]?.add(val);
        result[Constant.water_temperature]?.add(val);
        result[Constant.humidity]?.add(val);
        result[Constant.ph]?.add(val);
        result[Constant.tds]?.add(val);
      }
    }

    List<MinAndMax> min_max = await MinMax().getMinMax(props);
    data["range_x"] = range;
    data["spots"] = result;
    data["min_max"] = min_max;
    resultPort.send(data);
  }

  Map<String, Map<String, dynamic>> populateValues(Map<String, Map<String, dynamic>> props, String key, StatisticsData sd) {
    props[key]!.putIfAbsent("ave", () => (sd.total_value!/sd.count!));
    props[key]!.putIfAbsent("min", () => (sd.min!));
    props[key]!.putIfAbsent("max", () => (sd.max!));
    return props;
  }

  String getKey(String value) {
    if(value == Constant.air_temperature) {
      return "Air Temp";
    } else if(value == Constant.water_temperature) {
      return "Water Temp";
    } else if(value == Constant.humidity) {
      return "Humidity";
    } else if(value == Constant.ph) {
      return "Water Acidity";
    } else if(value == Constant.tds) {
      return "TDS";
    }
    return "";
  }

  List<String> getRange(Filter filter, {Range? date_range}) {

    var arr = [Filter.six_hour, Filter.one_day, Filter.custom0];
    var pattern = arr.contains(filter) ? hourly_pattern : daily_pattern;
    DateTime max = filter != Filter.custom0 && filter != Filter.custom1 ? DateFormat(pattern).parse(DateFormat(pattern).format(dateTimeNow()).toString()) : DateFormat(pattern).parse(getFilter(filter, date: date_range?.end_date));
    DateTime min = DateFormat(pattern).parse(getFilter(filter, date: date_range?.start_date));
    DateTime point = min;
    List<String> range = [DateFormat(pattern).format(point)];

    switch (filter) {
      case Filter.six_hour:
      case Filter.one_day:
      case Filter.custom0:
        while (point.isBefore(max) && !point.isAfter(max)) {
          point = point.add(Duration(hours: 1));
          range.add(DateFormat(pattern).format(point));
        }
        break;
      case Filter.one_week:
      case Filter.one_month:
      case Filter.custom1:
        while (point.isBefore(max) && !point.isAfter(max)) {
          point = point.add(Duration(days: 1));
          range.add(DateFormat(pattern).format(point));
        }
        break;
    }

    return range;
  }

  String getFilter(Filter filter, {String? date}) {
    switch (filter) {
      case Filter.one_day:
        return DateFormat(hourly_pattern).format(dateTimeNow().subtract(Duration(hours: 23)));
      case Filter.one_week:
        return DateFormat(daily_pattern).format(dateTimeNow().subtract(Duration(days: 6)));
      case Filter.one_month:
        return DateFormat(daily_pattern).format(dateTimeNow().subtract(Duration(days: 30)));
      case Filter.six_hour:
        return DateFormat(hourly_pattern).format(dateTimeNow().subtract(Duration(hours: 5)));
      case Filter.custom0:
      case Filter.custom1:
        String pattern = filter != Filter.custom0 ? daily_pattern : hourly_pattern;
        DateTime _date = DateFormat(pattern).parse(date!);
        return DateFormat(pattern).format(_date);
    }
  }

  int getTimeStamp(Filter filter, String date) {
    DateTime _date = dateTimeNow();
    switch (filter) {
      case Filter.six_hour:
      case Filter.one_day:
        _date = DateFormat(hourly_pattern).parse(date);
        break;
      case Filter.one_week:
      case Filter.one_month:
        _date = DateFormat(daily_pattern).parse(date);
        break;
      case Filter.custom0:
      case Filter.custom1:
        String pattern = filter != Filter.custom0 ? daily_pattern : hourly_pattern;
        _date = DateFormat(pattern).parse(date);
    }
    String date_string = (_date.millisecondsSinceEpoch / 1000).toStringAsFixed(0);
    print('$date $date_string');
    return int.parse(date_string);
  }

  DateTime dateTimeNow() {
    tz.initializeTimeZones();
    return tz.TZDateTime.from(DateTime.now().toUtc(), tz.getLocation(timezone));
  }

  List<Map> filters = [
    {'filter' : '6HR', 'active': false,},
    {'filter' : '1D', 'active': false,},
    {'filter' : '1W', 'active': false,},
    {'filter' : '1M', 'active': false,},
  ];

}