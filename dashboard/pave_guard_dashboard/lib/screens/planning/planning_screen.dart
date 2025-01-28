import 'package:admin/controllers/query_manager.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:flutter/material.dart';

import '../../constants.dart';

class CalendarData {
  LocationData location;
  bool done;
  CalendarData(this.location, this.done);
}

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
  List<LocationData>? locations;

  @override
  void initState() {
    super.initState();
    _fetchPlanningData();
    _fetchLocations();
  }

  void _showDialogAdd(BuildContext context, DateTime selectedDay) {
    LocationData selectedOption = locations![0];
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select and Enter Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<LocationData>(
                decoration: InputDecoration(
                  labelText: 'Select the Location',
                  border: OutlineInputBorder(),
                ),
                items: locations!
                    .map((LocationData option) => DropdownMenuItem(
                          value: option,
                          child: Text(option.toString()),
                        ))
                    .toList(),
                onChanged: (LocationData? newValue) {
                  selectedOption = newValue!;
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                AddPlanningQueryManager addPlanningQueryManager = AddPlanningQueryManager();
                AddPlanningData toSend = AddPlanningData(selectedOption, selectedDay, textController.text);
                addPlanningQueryManager.sendQuery(toSend, token: widget.token).then((_){
                  planningData = null;
                  _fetchPlanningData();
                }
                );
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, DateTime selectedDay) {
    LocationData? selectedOption;
    final TextEditingController textController = TextEditingController();
    bool showExtraFields = false;
    bool isChecked = false;
    PlanningData dayPlanningData = this.planningData!.getPlanning(selectedDay);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Edit Maintenance'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<LocationData>(
                    decoration: InputDecoration(
                      labelText: 'Select the Maintenance',
                      border: OutlineInputBorder(),
                    ),
                    items: dayPlanningData.locations
                        .map((LocationData option) => DropdownMenuItem(
                              value: option,
                              child: Text(option.toString()),
                            ))
                        .toList(),
                    onChanged: (LocationData? newValue) {
                      setState(() {
                        selectedOption = newValue;
                        showExtraFields = (newValue != null);
                        if(showExtraFields){
                          int index = dayPlanningData.locations.indexOf(newValue!);
                          isChecked =  dayPlanningData.dones[index];
                          textController.text = dayPlanningData.descriptions[index];
                        }
                      });
                    },
                  ),
                  if (showExtraFields) ...[
                    SizedBox(height: 16),
                    CheckboxListTile(
                      title: Text('Done?'),
                      value: isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked = value ?? false;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if(selectedOption == null) return;
                    EditPlanningQueryManager editPlanningQueryManager = EditPlanningQueryManager();
                    int index = dayPlanningData.locations.indexOf(selectedOption!);
                    String id = dayPlanningData.ids[index];
                    EditPlanningData toSend = EditPlanningData(id, textController.text, isChecked);
                    editPlanningQueryManager.sendQuery(toSend, token: widget.token).then((_){
                        planningData = null;
                        _fetchPlanningData();
                      }
                    );
                  },
                  child: Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _fetchLocations() async {
    QueryLocationManager locationQueryManager = QueryLocationManager();
    QueryResult result = await locationQueryManager.sendQuery("", token: widget.token);
    locations = locationQueryManager.getLocationData(result);
    setState(() {
    });
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
    if (planningData == null || locations == null) {
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
                              PlanningData dayData = planningData!.getPlanning(day);
                              List<CalendarData> calendarData = [];
                              for (int i = 0; i < dayData.locations.length; i++) {
                                calendarData.add(CalendarData(dayData.locations[i], dayData.dones[i]));
                              }
                              return calendarData;
                            }
                            return [];
                            },
                            calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, date, events) {
                              if (events.isNotEmpty) {
                                CalendarData calendarData = events[0] as CalendarData;
                              return Container(
                                width: 7,
                                height: 7,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                decoration: BoxDecoration(
                                color: calendarData.done ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                                ),
                              );
                              }
                              return null;
                            },
                            ),
                        ),
                        SizedBox(height: defaultPadding * 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                          ElevatedButton(
                            onPressed: () {
                            _showDialogAdd(context, _selectedDay);
                            },
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
                          ElevatedButton(
                            onPressed: () {
                            _showEditDialog(context, _selectedDay);
                            },
                            child: Text("Edit Maintenance"),
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
                        SizedBox(height: defaultPadding * 1.5),
                        if (planningData != null && !planningData!.getPlanning(_selectedDay).isEmpty()) ...[
                          SizedBox(height: defaultPadding * 1.5),
                          Text(
                            "Planned Maintenances for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: defaultPadding),
                          ...planningData!.getPlanning(_selectedDay).locations.map((location) {
                            int index = planningData!.getPlanning(_selectedDay).locations.indexOf(location);
                            return ListTile(
                              title: Text(location.toString()),
                              subtitle: Text(planningData!.getPlanning(_selectedDay).descriptions[index]),
                              trailing: Icon(
                                planningData!.getPlanning(_selectedDay).dones[index] ? Icons.check_circle : Icons.pending,
                                color: planningData!.getPlanning(_selectedDay).dones[index] ? Colors.green : Colors.red,
                              ),
                            );
                          }).toList(),
                        ]
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
