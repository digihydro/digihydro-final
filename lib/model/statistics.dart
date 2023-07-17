
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