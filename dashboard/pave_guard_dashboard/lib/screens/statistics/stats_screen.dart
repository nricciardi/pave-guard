import 'package:admin/constants.dart';
import 'package:admin/controllers/query_manager.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

const double lineChartWidth = 400;
int granularity = 30;

class SeverityData {
  final List<int> severities;
  final List<DateTime> dates;
  SeverityData(this.severities, this.dates);

  SeverityData getRecentData(int days, {DateTime? currentDate}) {
    List<int> recentSeverities = [];
    List<DateTime> recentDates = [];
    if(dates.isEmpty) return SeverityData(recentSeverities, recentDates);
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

Widget getLineChart(MapEntry<LocationData, SeverityData?> entry1, MapEntry<LocationData, SeverityData?> entry2) {
  if (entry1.value == null || entry2.value == null) {
    return Center(
      child: Text(
        'No data available',
        style: TextStyle(color: Colors.red, fontSize: 16),
      ),
    );
    }
    return LineChart(
    LineChartData(
      titlesData: FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
        int index = value.toInt();
        if (index >= 0 && index < entry2.value!.dates.length) {
          DateTime date = entry2.value!.dates[index];
          return Text('${date.day}/${date.month}', style: TextStyle(color: Colors.white, fontSize: 12));
            } else {
              return Text('');
            }
          },)),
        leftTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            return Text(value.toInt().toString(), style: TextStyle(color: Colors.white, fontSize: 12));
          },
        ),
        ),
        rightTitles: AxisTitles(),
        topTitles: AxisTitles(),
      ),
      minY: 0,
      maxY: 100,
      lineBarsData: [
LineChartBarData(
  spots: entry1.value!.severities.asMap().entries.map((e) {
    return FlSpot(e.key.toDouble(), e.value.toDouble());
  }).toList(),
  isCurved: true,
  color: Colors.lightBlueAccent,
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
LineChartBarData(
  spots: entry2.value!.severities.asMap().entries.map((e) {
    return FlSpot(e.key.toDouble(), e.value.toDouble());
  }).toList(),
  isCurved: true,
  color: Colors.green,
  barWidth: 4,
  isStrokeCapRound: true,
  dotData: FlDotData(
    show: true,
    getDotPainter: (spot, percent, bar, index) {
      double value = spot.y;
      Color color;
      if (value <= 50) {
        color = Color.lerp(Colors.green, Colors.yellow, value / 50)!;
      } else {
        color = Color.lerp(Colors.yellow, Colors.red, (value - 50) / 50)!;
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
)],));
}

Widget getLineTelemetryChart(MapEntry<LocationData, List<Temperature>?> temperatures, MapEntry<LocationData, List<Humidity>?> humidities){
  if (temperatures.value == null && humidities.value == null) {
    return Center(
      child: Text(
        'No data available',
        style: TextStyle(color: Colors.red, fontSize: 16),
      ),
    );
  } else {
    return LineChart(
      LineChartData(
        minY: -20,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index >= 0 && index < humidities.value!.length) {
                DateTime date = humidities.value![index].date;
                return Text('${date.day}/${date.month}', style: TextStyle(color: Colors.white, fontSize: 12));
              } else {
                return Text('');
              }
            },)),
          leftTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(value.toInt().toString(), style: TextStyle(color: Colors.white, fontSize: 12));
            },
          ),
          ),
          rightTitles: AxisTitles(),
          topTitles: AxisTitles(),
        ),
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: temperatures.value!.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.temperature);
            }).toList(),
            isCurved: true,
            color: Colors.lightBlueAccent,
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
          LineChartBarData(
            spots: humidities.value!.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.humidity);
            }).toList(),
            isCurved: true,
            color: Colors.green,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                double value = spot.y;
                Color color;
                if (value <= 50) {
                  color = Color.lerp(Colors.green, Colors.yellow, value / 50)!;
                } else {
                  color = Color.lerp(Colors.yellow, Colors.red, (value - 50) / 50)!;
                }
                return FlDotCirclePainter(
                  radius: 4,
                  color: color,
                  strokeColor: Colors.black87,
                  strokeWidth: 1.3,
                );
              },
            ),)]));}
          }

Column getCharts(MapEntry<LocationData, SeverityData?> sev_entry,
    MapEntry<LocationData, SeverityData?> poth_entry,
    MapEntry<LocationData, Telemetries?> telemetries) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
                "${sev_entry.key.road}",
                style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent,
                ),
              ),
              Text(
                "${sev_entry.key.city}",
                style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                ),
              ),
              ],
            ),
            ),
          SizedBox(width: defaultPadding * 3),
          Container(
            height: 200,
            width: lineChartWidth,
            child: getLineChart(sev_entry, poth_entry),
          ),
          SizedBox(width: defaultPadding * 3),
          Container(
            height: 200,
            width: lineChartWidth,
            child: getLineTelemetryChart(MapEntry(sev_entry.key, telemetries.value!.temperatures), MapEntry(sev_entry.key, telemetries.value!.humidities)),
          ),
        ],
      ),
      SizedBox(height: defaultPadding * 1.7),
    ],
  );
}

class StateHeader extends StatelessWidget {

  final Widget slider;

  const StateHeader({
    required this.slider,
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
          SizedBox(width: lineChartWidth / 2.5),
          Row(
            children: [slider],
          ),
        ],
      ),
    );
  }
}

class StatsScreen extends StatefulWidget {
  final MeData data;
  final String token;

  StatsScreen(this.data, this.token, {Key? key})
      : super(key: key);

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final List<LocationData> locations = [];
  final Map<LocationData, SeverityData> streets_sev = {};
  final Map<LocationData, SeverityData> streets_poth = {};
  final Map<LocationData, Telemetries> telemetries = {};
  late final Header header;
  String searched_text = "";

  @override
  void initState() {
    super.initState();

    header = Header(data: widget.data, title: "Statistics", onSubmitted: (String search) => _onSearchSubmitted(search));

    QueryLocationManager queryManager = QueryLocationManager();
    SeverityCrackQueryManager sev_queryManager = SeverityCrackQueryManager();
    SeverityPotholeQueryManager poth_queryManager = SeverityPotholeQueryManager();

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
      TelemetryQueryManager.getTelemetriesForLocations(locations, widget.token).then((telemetries) {
        setState(() {
          this.telemetries.addAll(telemetries);
        });
      });
      setState(() {});
    });
  }

  void _onSearchSubmitted(String search){
    setState(() {
      searched_text = search;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty || streets_sev.isEmpty || streets_poth.isEmpty || telemetries.isEmpty) {
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
            header,
            SizedBox(height: defaultPadding),
            StateHeader(slider: Slider(
              value: granularity.toDouble(),
              min: 2,
              max: 40,
              divisions: 38,
              label: granularity.toString(),
              onChanged: (double value) {
                setState(() {
                  granularity = value.toInt();
                });
              },
            )),
            SizedBox(height: defaultPadding),
            Column(
              children: locations.where((loc) {
                return searched_text == ""
                    ? true
                    : loc.contains(searched_text.toLowerCase());
              }).map((loc) {
                return getCharts(MapEntry(loc, streets_sev[loc]?.getRecentData(granularity)),
                    MapEntry(loc, streets_poth[loc]?.getRecentData(granularity)), MapEntry(loc, telemetries[loc]?.getRecentData(granularity)));
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
