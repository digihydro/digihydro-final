
import 'dart:math';
import 'package:digihydro/model/statistics.dart';


class MinMax {

  Future<List<MinAndMax>> getMinMax(Map<dynamic, List<Map<String, dynamic>>> data) async {

    List<MinAndMax> min_max = [];
    data.forEach((key, value) {
      if(value .length != 0) {
        var _min = value.map<num>((e) => e["min"]).reduce(min);
        var min_data = value.where((i) => i["min"] == _min).toList();
        print(min_data);

        var _max = value.map<num>((e) => e["max"]).reduce(max);
        var max_data = value.where((i) => i["max"] == _max).toList();
        print(max_data);

        var _sum_value = value.map<num>((e) => e["total_value"]).reduce((sum,currentValue)=>sum+currentValue);
        var _sum_total = value.map<int>((e) => e["count"]).reduce((sum,currentValue)=>sum+currentValue);
        var _ave = double.parse((_sum_value / _sum_total).toStringAsFixed(2));

        List<Map<String, dynamic>> details = [];
        details.add({"min":min_data, "max":max_data});
        min_max.add(MinAndMax(
            title: key,
            details: details,
            min: _min.toDouble(),
            max: _max.toDouble(),
            ave: _ave));
      } else {
        List<Map<String, dynamic>> details = [];
        min_max.add(MinAndMax(
            title: key,
            details: details,
            min: 0.0,
            max: 0.0,
            ave: 0.0));
      }
    });

    return min_max;

  }

}