import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/controllers/query_manager.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:flutter/material.dart';

import '../../constants.dart';

CalendarFormat _calendarFormat = CalendarFormat.month;
DateTime _selectedDay = DateTime.now();

class PlanningScreen extends StatelessWidget {

  PlanningScreen(this.data, {Key? key}) : super(key: key);

  final MeData data;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(data: data, title: "Planning"),
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
                          firstDay: DateTime.utc(2000, 10, 1),
                          lastDay: DateTime.utc(2100, 10, 31),
                          focusedDay: DateTime.now(),
                          calendarFormat: _calendarFormat,
                          onFormatChanged: (format) { 
                            _calendarFormat = format;
                            Provider.of<MenuAppController>(context, listen: false).refresh();
                          },
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          onDaySelected: (selectedDay, focusedDay){
                            _selectedDay = selectedDay;
                            Provider.of<MenuAppController>(context, listen: false).refresh();
                          },
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
