import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erevna/Student_Screens/project_screen.dart';
import 'package:erevna/Supervisor_Screens/supervisor_notifications.dart';
import 'package:erevna/calendar/cal/flutter_neat_and_clean_calendar.dart';
import 'package:erevna/calendar/cal/neat_and_clean_calendar_event.dart';
import 'package:erevna/models/meetings/meetings_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SupervisorHome extends StatefulWidget {
  const SupervisorHome({Key? key}) : super(key: key);

  @override
  _SupervisorsScreenState createState() => _SupervisorsScreenState();
}

class _SupervisorsScreenState extends State<SupervisorHome> {
  DateFormat format = DateFormat("yyyy-MM-dd");
  User? user;

  Map<DateTime, List<NeatCleanCalendarEvent>> _events = {};

  @override
  void initState() {
    super.initState();
    currentUser();
  }

  currentUser() {
    var res = FirebaseAuth.instance.currentUser;
    setState(() {
      user = res;
    });
  }

  Map<DateTime, List<NeatCleanCalendarEvent>> _groupDates(
      List<MeetingsModel> allEvents) {
    _events.clear();
    for (var event in allEvents) {
      var ds = format.parse(event.date!);
      log(ds.toString());
      DateTime date = DateTime(
        ds.year,
        ds.month,
        ds.day,
      );

      if (_events[date] == null) _events[date] = [];
      _events[date]!.add(NeatCleanCalendarEvent(
        "henlo",
        isAllDay: true,
        meetingsModel: event,
        isDone: false,
        startTime: ds,
        endTime: ds,
        location: event.date!,
        description: event.sName!,
        color: Colors.green,
      ));
    }
    return _events;
  }

  void _handleNewDate(date) {}

  Widget newCalendar(List<MeetingsModel>? attendanceCard) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
            top: 20.0, left: 250.0, right: 250.0, bottom: 20.0),
        child: Center(
          child: Calendar(
            startOnMonday: true,
            weekDays: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fr', 'Sat', 'Sun'],
            events: _groupDates(attendanceCard!),
            isExpandable: true,
            eventDoneColor: Colors.green,
            selectedColor: Colors.pink,
            todayColor: Colors.blue,
            onDateSelected: (_) => _handleNewDate,
            //dayBuilder: (BuildContext context, DateTime day) {
            //   return new Text("!");
            // },
            eventListBuilder: (BuildContext context,
                List<NeatCleanCalendarEvent> _selectesdEvents) {
              return _buildEventList(_selectesdEvents);
            },
            eventColor: Colors.grey,
            //locale: 'de_DE',
            todayButtonText: 'today',
            expandableDateFormat: 'EEEE, dd. MMMM yyyy',
            dayOfWeekStyle: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w800, fontSize: 11),
          ),
        ),
      ),
    );
  }

  getColor(String? txt) {
    if (txt == "acc") {
      return Colors.greenAccent;
    }
    if (txt == "rej") {
      return Colors.redAccent;
    }
    if (txt == "pending") {
      return Colors.amberAccent;
    } else {
      return Colors.white;
    }
  }

  Widget _buildEventList(List<NeatCleanCalendarEvent> _selectesdEvents) {
    return Container(
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _selectesdEvents.length,
          addAutomaticKeepAlives: true,
          itemBuilder: (_, i) {
            return Card(
                // color: getColor(_selectesdEvents[i].meetingsModel.status),
                child: Column(
              children: [
                Icon(
                  Icons.star,
                  color: getColor(_selectesdEvents[i].meetingsModel.status),
                ),
                ListTile(
                  trailing: const Icon(Icons.arrow_forward_ios),
                  title: Text(_selectesdEvents[i].meetingsModel.sName!),
                  onTap: () => launchProjectScreen(
                      _selectesdEvents[i].meetingsModel.projId!),
                ),
                Text(_selectesdEvents[i].meetingsModel.sName!),
                Text(_selectesdEvents[i].meetingsModel.pTitle!),
              ],
            ));
          }),
    );
  }

  launchProjectScreen(String? projectId) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProjectScreen(
              projectId: projectId,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              margin: const EdgeInsets.only(left: 20.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  const Spacer(
                    flex: 5,
                  ),
                  Expanded(
                      child: IconButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) =>
                                    const SupervisorNotificationScreens()));
                          },
                          icon: const Icon(
                            Icons.notifications,
                            color: Colors.blueGrey,
                          ))),
                  Expanded(
                      child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.person,
                            color: Colors.blueGrey,
                          ))),
                ],
              ),
            ),
            const SizedBox(
              height: 40.0,
            ),
            Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        const Text(
                          'Upcoming meetings',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              decoration: TextDecoration.underline),
                        ),
                        const SizedBox(
                          height: 40.0,
                        ),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection("meetings")
                                .where('prof_id', isEqualTo: user!.uid)
                                .where("comp", isEqualTo: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                var projModel = MeetingsModel();
                                var ds = projModel
                                    .dataListFromSnapshot(snapshot.data!);
                                if (snapshot.data!.docs.isNotEmpty) {
                                  log(ds.length.toString());
                                  return newCalendar(ds);
                                } else {
                                  return const Text("No requests to see here!");
                                }
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            })
                      ],
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
