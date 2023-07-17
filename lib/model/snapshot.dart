
import 'package:fl_chart/fl_chart.dart';
import 'package:json_annotation/json_annotation.dart';

class Snapshot {

  String? title;
  List<String> range;

  Snapshot({
    required this.title,
    required this.range,
  });

  Snapshot.fromMap(Map map)
      : this(
    title : map['title'],
    range : map['range'],
  );

  Map<String, dynamic> asMap() => {
    'title' : title,
    'range' : range,
  };


}

class Range {

  String? start_date;
  String? end_date;

  Range({
    required this.start_date,
    required this.end_date,
  });

  Range.fromMap(Map map)
      : this(
    start_date : map['start_date'],
    end_date : map['end_date'],
  );

  Map<String, dynamic> asMap() => {
    'title' : start_date,
    'end_date' : end_date,
  };

}

class Data {

  List<String>? range_x;
  Map<String, Map<String, List<List<double>>>>? spots;

  Data({
    required this.range_x,
    required this.spots,
  });

  Data.fromMap(Map map)
      : this(
    range_x : map['range_x'],
    spots : map['spots'],
  );

  Map<String, dynamic> asMap() => {
    'range_x' : range_x,
    'spots' : spots,
  };

}
