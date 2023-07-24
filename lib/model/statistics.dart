
import 'dart:ffi';

class Statistics {

  String? Temperature = "";
  String? WaterTemperature = "";
  String? Humidity= "";
  String? pH = "";
  String? TotalDissolvedSolids = "";
  dynamic timestamp = "";

  Statistics({
    required this.Temperature,
    required this.WaterTemperature,
    required this.Humidity,
    required this.pH,
    required this.TotalDissolvedSolids,
    required this.timestamp
  });

  Statistics.instance(Statistics stats){
    Temperature = stats.Temperature;
    WaterTemperature = stats.WaterTemperature;
    Humidity = stats.Humidity;
    pH = stats.pH;
    TotalDissolvedSolids = stats.TotalDissolvedSolids;
    timestamp = stats.timestamp;
  }

  Statistics.fromMap(Map map)
  : this(
    Temperature : map['Temperature'],
    WaterTemperature : map['WaterTemperature'],
    Humidity : map['Humidity'],
    pH : map['pH'],
    TotalDissolvedSolids : map['TotalDissolvedSolids'],
    timestamp : map['timestamp'],
  );

  Map<String, dynamic> asMap() => {
    'userName' : Temperature,
    'email' : WaterTemperature,
    'Humidity' : Humidity,
    'pH' : pH,
    'TotalDissolvedSolids' : TotalDissolvedSolids,
    'timestamp' : timestamp,
  };

}

class MinAndMax {

  String title;
  List<Map<String, dynamic>> details;
  double min;
  double max;
  double ave;

  MinAndMax({
    required this.title,
    required this.details,
    required this.min,
    required this.max,
    required this.ave,
  });

  MinAndMax.fromMap(Map map)
      : this(
    title : map['title'],
    details : map['details'],
    min : map['min'],
    max : map['max'],
    ave : map['ave'],
  );

  Map<String, dynamic> asMap() => {
    'title' : title,
    'details' : details,
    'min' : min,
    'max' : max,
    'ave' : ave,
  };

}

class Type {

  Map<String, dynamic>? Temperature = {};
  Map<String, dynamic>? WaterTemperature = {};
  Map<String, dynamic>? Humidity= {};
  Map<String, dynamic>? pH = {};
  Map<String, dynamic>? TotalDissolvedSolids = {};

  Type({
    required this.Temperature,
    required this.WaterTemperature,
    required this.Humidity,
    required this.pH,
    required this.TotalDissolvedSolids,
  });

  Type.instance(Type stats){
    Temperature = stats.Temperature;
    WaterTemperature = stats.WaterTemperature;
    Humidity = stats.Humidity;
    pH = stats.pH;
    TotalDissolvedSolids = stats.TotalDissolvedSolids;
  }

  Type.fromMap(Map map)
      : this(
    Temperature : map['Temperature'],
    WaterTemperature : map['WaterTemperature'],
    Humidity : map['Humidity'],
    pH : map['pH'],
    TotalDissolvedSolids : map['TotalDissolvedSolids'],
  );

  Map<String, dynamic> asMap() => {
    'userName' : Temperature,
    'email' : WaterTemperature,
    'Humidity' : Humidity,
    'pH' : pH,
    'TotalDissolvedSolids' : TotalDissolvedSolids,
  };

}

class StatisticsData {

  int? count;
  double? min;
  double? max;
  double? current_value;
  double? total_value;

  StatisticsData({
    required this.count,
    required this.min,
    required this.max,
    required this.current_value,
    required this.total_value,
  });

  StatisticsData.instance(StatisticsData stats){
    count = stats.count;
    min = stats.min;
    max = stats.max;
    current_value = stats.current_value;
    total_value = stats.total_value;
  }

  StatisticsData.fromMap(Map map)
      : this(
    count : map['count'],
    min : map['min'],
    max : map['max'],
    current_value : map['current_value'],
    total_value : map['total_value'],
  );

  Map<String, dynamic> asMap() => {
    'count' : count,
    'min' : min,
    'max' : max,
    'current_value' : current_value,
    'total_value' : total_value,
  };

}
