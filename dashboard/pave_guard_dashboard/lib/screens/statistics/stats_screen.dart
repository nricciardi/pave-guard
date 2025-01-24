import 'package:admin/constants.dart';
import 'package:admin/controllers/query_manager.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsScreen extends StatelessWidget {
  StatsScreen(this.data, this.token, {Key? key}) : super(key: key) {
    QueryLocationManager queryManager = QueryLocationManager();
    queryManager.sendQuery("", token: token).then((qr) {
      locations = queryManager.getLocationData(qr);
    });
  }

  final Map<String, List<int>> streets_sev = {
    "Via Nizza": [10, 12, 13, 15],
    "Via Roma": [34, 38, 41, 42]
  };

  final MeData data;
  final String token;
  late final List<LocationData> locations;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(data: data, title: "Statistics"),
            SizedBox(height: defaultPadding),
            Column(
              children: streets_sev.entries.map((entry) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Container(
                          height: 200,
                          width: 300,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(show: true),
                              borderData: FlBorderData(show: true),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: entry.value
                                      .asMap()
                                      .entries
                                      .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                                      .toList(),
                                  isCurved: true,
                                  color: Colors.blue,
                                  barWidth: 4,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(show: false),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: defaultPadding),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
