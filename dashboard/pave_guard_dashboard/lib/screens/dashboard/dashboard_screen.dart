import 'package:admin/controllers/query_manager.dart';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../constants.dart';
import 'components/header.dart';
import 'package:fl_chart/fl_chart.dart';

const double lineChartWidth = 400;

class Prediction {
  int n_month;
  int severity_crack;
  int severity_pothole;
  Prediction(this.n_month, this.severity_crack, this.severity_pothole);
}

class Predictions {
  final Map<LocationData, List<Prediction>> predictions;
  Predictions(this.predictions);
}

class DashboardHeader extends StatelessWidget {

  const DashboardHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 300 + lineChartWidth / 2),
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
        ],
      ),
    );
  }
}

Widget getLineChart(List<int>? months, List<int>? severities) {
  if (months == null || severities == null) {
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
          horizontalInterval: 25.0,
          verticalInterval: 1.0),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 25,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            interval: 1,
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  "${months[value.toInt()]}",
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
          spots: severities.asMap().entries.map((e) {
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
                '${spot.y}\nIn ${months[spot.x.toInt()]} months',
                TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      ),
    ),
  );
}

Widget getCharts(List<Prediction> predictions) {
  return Row(
    children: [
      Column(
        children: [
          SizedBox(
            width: lineChartWidth,
            height: 200,
            child: getLineChart(
              predictions.map((p) => p.n_month).toList(),
              predictions.map((p) => p.severity_crack).toList(),
            ),
          ),
        ],
      ),
      SizedBox(width: defaultPadding * 4.2),
      Column(
        children: [
          SizedBox(
            width: lineChartWidth,
            height: 200,
            child: getLineChart(
              predictions.map((p) => p.n_month).toList(),
              predictions.map((p) => p.severity_pothole).toList(),
            ),
          ),
        ],
      ),
    ],
  );
}

class _DashboardScreenState extends State<DashboardScreen> {
  Predictions? predictions;
  String searched_text = "";
  late final Header header;

  @override
  void initState() {
    super.initState();
    header = Header(data: widget.data, title: "Dashboard", onSubmitted: (String search) => _onSearchSubmitted(search));
    _fetchPredictions();
  }

  void _fetchPredictions() async {
    /* TODO: This is a placeholder
    predictions = Predictions({
      LocationData(
          road: "Luigi", city: "Tenco", county: "Camaiore", state: "Lodi"): [
            Prediction(1, 30, 30),
            Prediction(2, 30, 35),
            Prediction(3, 30, 40),
            Prediction(6, 60, 70),
            Prediction(12, 100, 100),
      ],
      LocationData(
          road: "Mario", city: "Bros", county: "Mushroom", state: "Kingdom"): [
        Prediction(3, 10, 20),
        Prediction(6, 20, 30),
        Prediction(12, 40, 50),
      ],
      LocationData(
          road: "Peach", city: "Toadstool", county: "Mushroom", state: "Kingdom"): [
        Prediction(3, 20, 30),
        Prediction(6, 40, 50),
        Prediction(12, 80, 90),
      ],
      });
      */
      PredictionQueryManager predictionQueryManager = PredictionQueryManager();
      QueryResult qr = await predictionQueryManager.sendQuery("", token: widget.token);
      predictions = predictionQueryManager.getPredictions(qr);
      predictions = Predictions({
        for (var entry in predictions!.predictions.entries)
        if (entry.key.contains(searched_text))
          entry.key: entry.value
      });
      predictions = Predictions({
      for (var entry in predictions!.predictions.entries.toList()
      ..sort((a, b) => (b.value.fold(0, (sum, p) => sum + p.severity_crack + p.severity_pothole))
      .compareTo(a.value.fold(0, (sum, p) => sum + p.severity_crack + p.severity_pothole))))
      entry.key: entry.value
    });
    setState(() {});
  }

  void _onSearchSubmitted(String search){
    searched_text = search;
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            header,
            SizedBox(height: defaultPadding),
            DashboardHeader(),
            SizedBox(height: defaultPadding),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (predictions == null)
                    Center(child: CircularProgressIndicator())
                  else
                      for (var entry in predictions!.predictions.entries)
                      if(entry.key.contains(searched_text))
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                            Container(
                              width: 150,
                              child: Text(
                              '${entry.key}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: predictions!.predictions.keys.toList().length > 1
                                  ? Color.lerp(
                                    Colors.red,
                                    Colors.green,
                                    predictions!.predictions.keys.toList().indexOf(entry.key) /
                                      (predictions!.predictions.length - 1))
                                  : Colors.red,
                              ),
                              ),
                            ),
                        SizedBox(width: defaultPadding * 8),
                        Padding(
                          padding: const EdgeInsets.only(right: defaultPadding),
                          child: SizedBox(
                          child: getCharts(entry.value),
                          ),
                          ),
                        ]),
                        SizedBox(height: defaultPadding * 2),
                        ],
                      ),
                      ],
                    ), 
        )],
            ),
        ),
      );
  }
}

class DashboardScreen extends StatefulWidget {
  final MeData data;
  final String token;

  DashboardScreen(this.data, this.token, {Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}
