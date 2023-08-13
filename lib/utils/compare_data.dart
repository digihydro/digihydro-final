
import 'dart:isolate';

import 'package:digihydro/enums/constant.dart';
import 'package:digihydro/enums/enums.dart';
import 'package:digihydro/model/snapshot.dart';
import 'package:digihydro/model/statistics.dart';
import 'package:digihydro/utils/filter_data.dart';
import 'package:digihydro/utils/min_max.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jiffy/jiffy.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';

class CompareData {

  static String daily_pattern  = "MM-dd-yyyy";
  static String hourly_pattern = "MM-dd-yyyy HH:00";
  static String hourly_pattern_actual_value = "MM-dd-yyyy hh:mm a";
  static String timezone = "Asia/Manila";

  Future<DataSnapshot> query(String type, Batch? batch_range) {

    String node = "DailyData/$type";
    Range range = batch_range!.range!;
    String start_date = range.start_date!;
    String end_date =  range.end_date!;

    return FirebaseDatabase.instance.ref(node)
        .orderByChild("timestamp")
        .startAt(FilterData().getTimeStamp(Filter.custom1, start_date))
        .endAt(FilterData().getTimeStamp(Filter.custom1, end_date))
        .get();
  }

  Future<dynamic> fetch(Batch initial_batch, {Batch? compare_batch}) async {
    List<Map<String, dynamic>> stats_list = [];
    final receivePort = ReceivePort();

    Ranges range = getRange(initial_batch, compare_batch: compare_batch);
    int loop = range.compare_batch == null ? 1 : 2;

    for(int num=0; num<loop; num++) {
      Map<String, dynamic>? stats = {};
      var arr = [Constant.air_temperature, Constant.water_temperature, Constant.humidity, Constant.ph, Constant.tds];
      for (int i=0; i<arr.length; i++) {
        DataSnapshot result = await query(arr[i], num == 0 ? range.initial_batch : range.compare_batch);
        if (result.value != null) {
          stats.putIfAbsent(arr[i], () => Map<String, dynamic>.from(result.value as Map<dynamic, dynamic>));
        }
      }
      stats_list.add(stats);
    }

    await Isolate.spawn(processPoints, [stats_list, receivePort.sendPort, range]);
    return receivePort.first;
  }

  processPoints(List<dynamic> args) async {
    List<Map<String, dynamic>> val = args[0];
    SendPort resultPort = args[1];
    Ranges _range = args[2];
    List<Map<dynamic, dynamic>> data_list = [];

    for(int num=0; num<val.length; num++) {

      List<String> range =  num == 0 ? _range.initial_batch!.range_list! : _range.compare_batch!.range_list!;
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

      val[num].forEach((raw_key, raw_value) {
        for (int i=0; i<range.length; i++) {
          if(raw_value[range[i]] != null) {
            StatisticsData sd = StatisticsData.fromMap(raw_value[range[i]]);
            props[getKey(raw_key)]?.add({"total_value": sd.total_value ?? 0, "count": sd.count ?? 0.0, "min": sd.min ?? 0.0, "max" : sd.max ?? 0.0});
            FlSpot val = new FlSpot(i.toDouble(), double.parse((sd.total_value!/sd.count!).toStringAsFixed(2)));
            result[raw_key]!.add(val);
          }
        }
      });

      List<MinAndMax> min_max = await MinMax().getMinMax(props);
      data["duration"] = _range.duration! + 1;
      data["range_x"] = range;
      data["ranges"] = _range;
      data["spots"] = result;
      data["min_max"] = min_max;
      data_list.add(data);

    }

    resultPort.send(data_list);
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

  Ranges getRange(Batch initial_batch, {Batch? compare_batch}) {

    Ranges range = Ranges();
    range.duration = 7;

    String start_dr1 = DateFormat(daily_pattern).format(DateFormat(daily_pattern).parse(initial_batch.range!.start_date!));
    String end_dr1 = DateFormat(daily_pattern).format(initial_batch.range?.end_date == null ? dateTimeNow() : DateFormat(daily_pattern).parse(initial_batch.range!.end_date!));
    initial_batch.range?.start_date = start_dr1;
    initial_batch.range?.end_date = end_dr1;

    Duration duration = DateFormat(daily_pattern).parse(initial_batch.range!.end_date!)
        .difference(DateFormat(daily_pattern).parse(initial_batch.range!.start_date!));
    initial_batch.batch_duration = duration.inDays;
    if (duration.inDays> range.duration!) {
      range.duration = duration.inDays.toDouble();
    }

    List<String> initial_range_list = [start_dr1];
    DateTime initial_range_point = DateFormat(daily_pattern).parse(start_dr1);
    int i = 0;
    while (i < range.duration!) {
      initial_range_point = initial_range_point.add(Duration(days: 1));
      initial_range_list.add(DateFormat(daily_pattern).format(initial_range_point));
      i++;
    }

    initial_batch.range_list = initial_range_list;
    range.initial_batch = initial_batch;

    if (compare_batch == null) {
      return range;
    }

    String start_dr2 = DateFormat(daily_pattern).format(DateFormat(daily_pattern).parse(compare_batch.range!.start_date!));
    String end_dr2 = DateFormat(daily_pattern).format(compare_batch.range!.end_date == null ? dateTimeNow() : DateFormat(daily_pattern).parse(compare_batch.range!.end_date!));
    compare_batch.range?.start_date = start_dr2;
    compare_batch.range?.end_date = end_dr2;

    duration = DateFormat(daily_pattern).parse(compare_batch.range!.end_date!)
        .difference(DateFormat(daily_pattern).parse(compare_batch.range!.start_date!));
    compare_batch.batch_duration = duration.inDays;
    if (duration.inDays > range.duration!) {
      range.duration = duration.inDays.toDouble();
    }

    List<String> compare_range_list = [start_dr2];
    DateTime compare_range_point = DateFormat(daily_pattern).parse(start_dr2);
    int h = 0;
    while (h < range.duration!) {
      compare_range_point = compare_range_point.add(Duration(days: 1));
      compare_range_list.add(DateFormat(daily_pattern).format(compare_range_point));
      h++;
    }

    compare_batch.range_list = compare_range_list;
    range.compare_batch = compare_batch;

    return range;
  }

  DateTime dateTimeNow() {
    tz.initializeTimeZones();
    return tz.TZDateTime.from(DateTime.now().toUtc(), tz.getLocation(timezone));
  }

  List<Map> filters = [
    {'filter' : 'all', 'active': false,},
    {'filter' : 'finished', 'active': false,},
    {'filter' : 'current', 'active': false,},
  ];

}