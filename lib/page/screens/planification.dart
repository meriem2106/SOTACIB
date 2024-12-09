import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Planifications extends StatefulWidget {
  @override
  _PlanificationsState createState() => _PlanificationsState();
}

class _PlanificationsState extends State<Planifications> {
  DateTime _selectedDate = DateTime.now();
  final List<Map<String, String>> _events = [];
  bool _isPlanTabActive = true;

  void _showAddEventDialog() {
    TextEditingController clientNameController = TextEditingController();
    TextEditingController placeController = TextEditingController();
    TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Planifier une visite",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: clientNameController,
                    decoration: InputDecoration(
                      labelText: 'Nom du client',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: placeController,
                    decoration: InputDecoration(
                      labelText: 'Lieu',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Annuler",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (clientNameController.text.isNotEmpty) {
                            setState(() {
                              _events.add({
                                'day': _selectedDate.day.toString(),
                                'title': clientNameController.text,
                                'place': placeController.text,
                                'notes': notesController.text,
                                'date': _selectedDate.toIso8601String(),
                              });
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          "Ajouter",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Planification',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        backgroundColor: Colors.red,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          _buildTabs(),
          SizedBox(height: 16),
          if (_isPlanTabActive) _buildCalendar(),
          SizedBox(height: 16),
          if (_isPlanTabActive) _buildTodayEvents(),
          if (!_isPlanTabActive) _buildEventList(),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildTabButton('Plan', isActive: _isPlanTabActive),
          SizedBox(width: 8),
          _buildTabButton('Listes', isActive: !_isPlanTabActive),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, {required bool isActive}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isPlanTabActive = text == 'Plan';
          });
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Colors.red : Colors.grey.shade800,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(16.0),
        child: TableCalendar(
          firstDay: DateTime(2020),
          lastDay: DateTime(2030),
          focusedDay: _selectedDate,
          selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDate = selectedDay;
            });
            _showAddEventDialog();
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.grey.shade600,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: TextStyle(color: Colors.black),
            leftChevronIcon: Icon(Icons.chevron_left),
            rightChevronIcon: Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayEvents() {
    final todayEvents = _events.where((event) {
      return isSameDay(DateTime.parse(event['date']!), DateTime.now());
    }).toList();

    return todayEvents.isEmpty
        ? Center(child: Text("Non visite pour aujourd'hui"))
        : Expanded(
      child: ListView.builder(
        itemCount: todayEvents.length,
        itemBuilder: (context, index) {
          final event = todayEvents[index];
          return ListTile(
            title: Text(event['title']!),
            subtitle: Text(event['place']!),
          );
        },
      ),
    );
  }

  Widget _buildEventList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return ListTile(
            title: Text(event['title']!),
            subtitle: Text(event['place']!),
          );
        },
      ),
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
