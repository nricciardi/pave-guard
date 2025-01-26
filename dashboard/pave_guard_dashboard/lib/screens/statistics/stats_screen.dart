import 'dart:async';

import 'package:admin/constants.dart';
import 'package:admin/controllers/query_manager.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

const double lineChartWidth = 400;
int granularity = 30;
bool didGranularityChange = false;

class SeverityData {
  final List<int> severities;
  final List<DateTime> dates;
  SeverityData(this.severities, this.dates);

  SeverityData getRecentData(int days, {DateTime? currentDate}) {
    List<int> recentSeverities = [];
    List<DateTime> recentDates = [];
    currentDate ??= dates.reduce((a, b) => a.isAfter(b) ? a : b);

    for (int i = 0; i < dates.length; i++) {
      if (dates[i].isAfter(currentDate.subtract(Duration(days: days))) &&
        dates[i].isBefore(currentDate.add(Duration(days: 1)))) {
      recentSeverities.add(severities[i]);
      recentDates.add(dates[i]);
      }
    }

    return SeverityData(recentSeverities, recentDates);
  }

}

Widget getLineChart(MapEntry<String, SeverityData?> entry) {
  if (entry.value == null) {
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
                child: Text(
                  "${entry.value!.dates[value.toInt()].day}/${entry.value!.dates[value.toInt()].month}",
                  style: TextStyle(fontSize: 10),
                ),
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
                color = Color.lerp(Colors.blue, Colors.red, value / 50)!;
              } else {
                color = Color.lerp(Colors.red, Colors.red, (value - 50) / 50)!;
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

Column getCharts(MapEntry<String, SeverityData?> sev_entry,
    MapEntry<String, SeverityData?> poth_entry) {
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
                label: Text("10"),
                selected: false,
                onSelected: (selected) {
                  granularity = 10;
                  didGranularityChange = true;
                },
              ),
              ChoiceChip(
                label: Text("20"),
                selected: false,
                onSelected: (selected) {
                  granularity = 20;
                  didGranularityChange = true;
                },
              ),
              ChoiceChip(
                label: Text("30"),
                selected: false,
                onSelected: (selected) {
                  granularity = 30;
                  didGranularityChange = true;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatsScreen extends StatefulWidget {
  final MeData data;
  final String token;
  final String searched_text;

  StatsScreen(this.data, this.token, {required this.searched_text, Key? key})
      : super(key: key);

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final List<LocationData> locations = [];
  final Map<LocationData, SeverityData> streets_sev = {};
  final Map<LocationData, SeverityData> streets_poth = {};

  void startGranularityChangeTimer() {
    Timer.periodic(Duration(milliseconds: 250), (timer) {
      if (didGranularityChange) {
        setState(() {
          didGranularityChange = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    QueryLocationManager queryManager = QueryLocationManager();
    SeverityCrackQueryManager sev_queryManager = SeverityCrackQueryManager();
    SeverityPotholeQueryManager poth_queryManager =
        SeverityPotholeQueryManager();

    startGranularityChangeTimer();

    queryManager.sendQuery("", token: widget.token).then((qr) {
      locations.addAll(queryManager.getLocationData(qr));
      sev_queryManager
          .getSeveritiesForLocations(locations, widget.token)
          .then((sev) {
        setState(() {
          streets_sev.addAll(sev);
        });
      });
      poth_queryManager
          .getSeveritiesForLocations(locations, widget.token)
          .then((poth) {
        setState(() {
          streets_poth.addAll(poth);
        });
      });
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty || streets_sev.isEmpty || streets_poth.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(data: widget.data, title: "Statistics"),
            SizedBox(height: defaultPadding),
            StateHeader(),
            SizedBox(height: defaultPadding),
            Column(
              children: locations.where((loc) {
                return widget.searched_text == ""
                    ? true
                    : loc.contains(widget.searched_text.toLowerCase());
              }).map((loc) {
                return getCharts(MapEntry(loc.toString(), streets_sev[loc]?.getRecentData(granularity)),
                    MapEntry(loc.toString(), streets_poth[loc]?.getRecentData(granularity)));
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
