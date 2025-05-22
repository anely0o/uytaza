import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/models/order_model.dart';

import 'package:uytaza/screen/order/client/payment_method_screen.dart';

class CalendarPage extends StatefulWidget {
  final String cleaningType;
  final String frequency;
  final List<String> extras;

  const CalendarPage({
    super.key,
    required this.cleaningType,
    required this.frequency,
    required this.extras,
  });

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  final List<String> availableTimes = [
    '09:00',
    '10:00',
    '11:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
  ];

  String? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Select date and time",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
              leftChevronIcon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 17,
              ),
              rightChevronIcon: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 17,
              ),
            ),
            calendarStyle: CalendarStyle(
              weekendTextStyle: TextStyle(color: Colors.white),
              defaultTextStyle: TextStyle(color: Colors.white),
              todayDecoration: BoxDecoration(
                color: TColor.secondary,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(color: TColor.primary),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekendStyle: TextStyle(color: Colors.white60),
              weekdayStyle: TextStyle(color: Colors.white60),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: TColor.secondary),
                      SizedBox(width: 8),
                      Text(
                        "Choose a Date",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TColor.primaryText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      _selectedDay != null
                          ? "📅 ${_selectedDay!.day}.${_selectedDay!.month}.${_selectedDay!.year}"
                          : "Please, choose a date on a calendar",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: TColor.secondary),
                      SizedBox(width: 8),
                      Text(
                        "It's time to choose time!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TColor.primaryText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children:
                        availableTimes.map((time) {
                          bool isSelected = _selectedTime == time;
                          return ChoiceChip(
                            label: Text(time),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _selectedTime = time;
                              });
                            },
                            selectedColor: TColor.primary,
                            backgroundColor: Colors.grey[200],
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                            elevation: 2,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          );
                        }).toList(),
                  ),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          (_selectedDay != null && _selectedTime != null)
                              ? () {
                                final selectedDateTime = DateTime(
                                  _selectedDay!.year,
                                  _selectedDay!.month,
                                  _selectedDay!.day,
                                  int.parse(_selectedTime!.split(":")[0]),
                                  int.parse(_selectedTime!.split(":")[1]),
                                );

                                final order = Order(
                                  cleaningType: widget.cleaningType,
                                  frequency: widget.frequency,
                                  extras: widget.extras,
                                  dateTime: selectedDateTime,
                                );

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentMethodScreen(),
                                  ),
                                );
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.primary,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Confirm",
                        style: TextStyle(
                          fontSize: 16,
                          color: TColor.primaryText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
