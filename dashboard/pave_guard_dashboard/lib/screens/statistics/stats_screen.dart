import 'package:admin/constants.dart';
import 'package:admin/controllers/query_manager.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

const double lineChartWidth = 400;
int granularity = 30;

class SeverityData {
  final List<int> severities;
  final List<String> dates;
  SeverityData(this.severities, this.dates);
}

Widget getLineChart(MapEntry<String, SeverityData?> entry){
  if(entry.value == null){
    return Center(
      child: Text(
      'No data available',
      style: TextStyle(color: Colors.red, fontSize: 16),
      ),
    );
  }
  return LineChart(
              LineChartData(
                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey,
                        strokeWidth: 1,
                      );
                    },
                    horizontalInterval: 20.0,
                    verticalInterval: 1.0),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(entry.value!.dates[value.toInt()]),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(),
                  topTitles: AxisTitles(),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: Colors.grey),
                    bottom: BorderSide(color: Colors.grey),
                    right: BorderSide.none,
                    top: BorderSide.none,
                  ),
                ),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: entry.value!.severities.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        double value = spot.y;
                        Color color;
                        if (value <= 50) {
                          color =
                              Color.lerp(Colors.blue, Colors.red, value / 50)!;
                        } else {
                          color = Color.lerp(
                              Colors.red, Colors.red, (value - 50) / 50)!;
                        }
                        return FlDotCirclePainter(
                          radius: 4,
                          color: color,
                          strokeColor: Colors.black87,
                          strokeWidth: 1.3,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                    aboveBarData: BarAreaData(show: false),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y}',
                          TextStyle(color: Colors.white),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            );
}

Column getCharts(MapEntry<String, SeverityData?> sev_entry, MapEntry<String, SeverityData?> poth_entry) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            width: 150,
            child: Text(
              "${sev_entry.key}:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent,
              ),
            ),
          ),
          SizedBox(width: defaultPadding * 3),
          Container(
            height: 200,
            width: lineChartWidth,
            child: getLineChart(sev_entry),
          ),
          SizedBox(width: defaultPadding * 3),
          Container(
            height: 200,
            width: lineChartWidth,
            child: getLineChart(poth_entry),
          )
        ],
      ),
      SizedBox(height: defaultPadding * 1.7),
    ],
  );
}

class StateHeader extends StatelessWidget {

  const StateHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150 + lineChartWidth / 2),
          Text(
        "Cracks",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.lightBlueAccent,
        ),
          ),
          SizedBox(width: lineChartWidth),
          Text(
        "Pothole",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.lightBlueAccent,
        ),
          ),
          SizedBox(width: lineChartWidth / 3),
          Row(
        children: [
          ChoiceChip(
            label: Text("30"),
            selected: false,
            onSelected: (selected) {
              granularity = 30;
            },
          ),
          ChoiceChip(
            label: Text("90"),
            selected: false,
            onSelected: (selected) {
              granularity = 90;
            },
          ),
          ChoiceChip(
            label: Text("180"),
            selected: false,
            onSelected: (selected) {
              granularity = 180;
            },
          ),
        ],
          ),
        ],
      ),
    );
  }

}

class StatsScreen extends StatelessWidget {

  StatsScreen(this.data, this.token, {required this.searched_text, Key? key}) : super(key: key) {
    QueryLocationManager queryManager = QueryLocationManager();
    queryManager.sendQuery("", token: token).then((qr) {
      locations = queryManager.getLocationData(qr);
    });
  }

  final Map<String, SeverityData> streets_sev = {
    "Via Nizza": SeverityData([10, 16, 23, 52, 49],
        ["10/01/21", "10/02/21", "10/03/21", "10/04/21", "10/05/21"]),
    "Via Roma": SeverityData([30, 38, 41, 39, 48],
        ["10/01/21", "10/02/21", "10/03/21", "10/04/21", "10/05/21"]),
  };

  final Map<String, SeverityData> streets_poth = {
    "Via Nizza": SeverityData([10, 16, 50, 52, 60],
        ["10/01/21", "10/02/21", "10/03/21", "10/04/21", "10/05/21"]),
  };

  final List<String> locations_temp = ["Via Nizza", "Via Roma", "Via Catania", "Via Belgrado", "Via Colvento"];

  final MeData data;
  final String token;
  final String searched_text;
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
            StateHeader(),
            SizedBox(height: defaultPadding),
            Column(
                children: locations_temp.where((loc){return searched_text == "" ? true : loc.toLowerCase().contains(searched_text.toLowerCase());}).map((loc) {
                return getCharts(
                  MapEntry(loc, streets_sev[loc]), MapEntry(loc, streets_poth[loc]));
                }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
