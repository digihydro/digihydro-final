
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
    'start_date' : start_date,
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

class Ranges {

  Batch? initial_batch;
  Batch? compare_batch;
  double? duration;

  Ranges({
    this.initial_batch,
    this.compare_batch,
    this.duration,
  });

  Ranges.fromMap(Map map)
      : this(
    initial_batch : map['initial_batch'],
    compare_batch : map['compare_batch'],
    duration : map['duration'],
  );

  Map<String, dynamic> asMap() => {
    'initial_batch' : initial_batch,
    'compare_batch' : compare_batch,
    'duration' : duration,
  };

}

class Batch {

  String? id;
  String? name;
  Range? range;
  List<String>? range_list;
  String? status;
  int? batch_duration;

  Batch({
    this.id,
    this.name,
    this.range,
    this.range_list,
    this.status,
    this.batch_duration,
  });

  Batch.fromMap(Map map)
      : this(
    id : map['id'],
    name : map['name'],
    range : map['range'],
    range_list : map['range_list'],
    status : map['status'],
    batch_duration : map['batch_duration'],
  );

  Map<String, dynamic> asMap() => {
    'id' : id,
    'name' : name,
    'range' : range,
    'range_list' : range_list,
    'status' : status,
    'batch_duration' : batch_duration,
  };

}
