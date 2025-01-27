import 'package:admin/controllers/query_manager.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:flutter/material.dart';

import '../../constants.dart';

CalendarFormat _calendarFormat = CalendarFormat.month;
DateTime _selectedDay = DateTime.now();

class PlanningScreen extends StatefulWidget {
  final MeData data;
  final String token;

  PlanningScreen(this.data, this.token, {Key? key}) : super(key: key);

  @override
  _PlanningScreenState createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  PlanningData? planningData;

  @override
  void initState() {
    super.initState();
    _fetchPlanningData();
  }

  void _fetchPlanningData() async {
    PlanningQueryManager planningQueryManager = PlanningQueryManager();
    QueryResult result = await planningQueryManager.sendQuery("", token: widget.token);
    planningData = await PlanningQueryManager().getPlanningData(result);
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    if (planningData == null) {
      return Center(child: CircularProgressIndicator());
    }
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(data: widget.data, title: "Planning", show_searchbar: false),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: EdgeInsets.all(defaultPadding),
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Column(
                      children: [
                        TableCalendar(
                          firstDay: DateTime.utc(2010, 10, 1),
                          lastDay: DateTime.utc(2050, 10, 31),
                          focusedDay: DateTime.now(),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                            weekendStyle: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          calendarStyle: CalendarStyle(
                            selectedDecoration: BoxDecoration(
                              color: Colors.deepPurpleAccent,
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: Colors.grey.shade700,
                              shape: BoxShape.circle,
                            ),
                            markersMaxCount: 1,
                          ),
                          calendarFormat: _calendarFormat,
                          onFormatChanged: (format) {
                            _calendarFormat = format;
                            setState(() {});
                          },
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            _selectedDay = selectedDay;
                            setState(() {});
                          },
                          eventLoader: (day) {
                            if (planningData != null) {
                              return planningData!.getLocations(day).map((loc)=>loc.toString()).toList();
                            }
                            return [];
                            },
                            calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, date, events) {
                              if (events.isNotEmpty) {
                              return Container(
                                width: 7,
                                height: 7,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                ),
                              );
                              }
                              return null;
                            },
                            ),
                        ),
                        SizedBox(height: defaultPadding * 3),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text("Plan Maintenance"),
                          style: ElevatedButton.styleFrom(
                            shadowColor: Colors.purpleAccent,
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 20),
                            textStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: defaultPadding * 2),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text("Delete Maintenance"),
                          style: ElevatedButton.styleFrom(
                            shadowColor: Colors.purpleAccent,
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 20),
                            textStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
