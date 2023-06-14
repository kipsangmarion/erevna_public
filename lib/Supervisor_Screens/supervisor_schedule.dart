import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:erevna/Student_Screens/project_screen.dart';
import 'package:erevna/calendar/cal/flutter_neat_and_clean_calendar.dart';
import 'package:erevna/calendar/cal/neat_and_clean_calendar_event.dart';
import 'package:erevna/helpers/firebase_helper.dart';
import 'package:erevna/models/meetings/meetings_model.dart';
import 'package:erevna/models/project/project_model.dart';
import 'package:erevna/models/schedule/schedule_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart' as ds;
import 'package:intl/intl.dart';

class SupervisorSchedule extends StatefulWidget {
  const SupervisorSchedule({Key? key}) : super(key: key);

  @override
  _SupervisorScheduleState createState() => _SupervisorScheduleState();
}

class _SupervisorScheduleState extends State<SupervisorSchedule> {
  ds.DateFormat format = ds.DateFormat("yyyy-MM-dd");
  bool isChecked = false;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  User? user;
  var dateController = TextEditingController(text: DateTime.now().toString());

  Map<DateTime, List<NeatCleanCalendarEvent>> _events = {};
  String? _setDate;
  String? _hour, _minute, _time, _setTime;
  TextEditingController _timeController = TextEditingController();

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
                color: Colors.black, fontWeight: FontWeight.w800, fontSize: 25),
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
                //color: getColor(_selectesdEvents[i].meetingsModel.status),
                child: Padding(
              padding: const EdgeInsets.all(30.0),
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
                  Row(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              shape: const StadiumBorder()),
                          onPressed: () async {
                            Fluttertoast.showToast(msg: "Accepting A Meeting");
                            await firebaseHelper.acceptAMeetingRequest(
                                meetingsModel: MeetingsModel(
                                    dId: _selectesdEvents[i].meetingsModel.dId,
                                    uid: _selectesdEvents[i].meetingsModel.uid,
                                    sName:
                                        _selectesdEvents[i].meetingsModel.sName,
                                    date:
                                        _selectesdEvents[i].meetingsModel.date,
                                    pTitle: _selectesdEvents[i]
                                        .meetingsModel
                                        .pTitle,
                                    profId: _selectesdEvents[i]
                                        .meetingsModel
                                        .profId,
                                    profName: _selectesdEvents[i]
                                        .meetingsModel
                                        .profName,
                                    projId: _selectesdEvents[i]
                                        .meetingsModel
                                        .projId,
                                    tm: _selectesdEvents[i].meetingsModel.tm,
                                    comp: true,
                                    status: "acc"));
                            Fluttertoast.showToast(msg: "Accepted");
                          },
                          child: const Text("Accept")),
                      const SizedBox(
                        width: 30,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              shape: const StadiumBorder()),
                          onPressed: () async {
                            Fluttertoast.showToast(msg: "Declining A Meeting");
                            await firebaseHelper.acceptAMeetingRequest(
                                meetingsModel: MeetingsModel(
                                    dId: _selectesdEvents[i].meetingsModel.dId,
                                    uid: _selectesdEvents[i].meetingsModel.uid,
                                    sName:
                                        _selectesdEvents[i].meetingsModel.sName,
                                    date:
                                        _selectesdEvents[i].meetingsModel.date,
                                    pTitle: _selectesdEvents[i]
                                        .meetingsModel
                                        .pTitle,
                                    profId: _selectesdEvents[i]
                                        .meetingsModel
                                        .profId,
                                    profName: _selectesdEvents[i]
                                        .meetingsModel
                                        .profName,
                                    projId: _selectesdEvents[i]
                                        .meetingsModel
                                        .projId,
                                    tm: _selectesdEvents[i].meetingsModel.tm,
                                    comp: false,
                                    status: "rej"));
                            Fluttertoast.showToast(msg: "Declined");
                          },
                          child: const Text("Decline")),
                    ],
                  )
                ],
              ),
            ));
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text(
              'Post Your Schedule',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DateTimePicker(
                    controller: dateController,
                    type: DateTimePickerType.dateTime,
                    dateMask: 'yyyy-MM-dd HH:mm',
                    //initialValue: DateTime.now().toString(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                    icon: const Icon(Icons.event),
                    dateLabelText: 'Date',
                    timeLabelText: "Hour",

                    selectableDayPredicate: (date) {
                      // Disable weekend days to select from the calendar
                      if (date.weekday == 7) {
                        return false;
                      }

                      return true;
                    },
                    onChanged: (val) => print(val),
                    validator: (val) {
                      print(val);
                      return null;
                    },
                    onSaved: (val) => print(val),
                  ),
                ),
                Container(
                  height: 150,
                  width: 150,
                  child: ElevatedButton(
                      onPressed: () async {
                        if (dateController.text.isNotEmpty) {
                          Fluttertoast.showToast(msg: "Creating");
                          await firebaseHelper.createASchedule(
                              scheduleModel: ScheduleModel(
                            profId: user!.uid,
                            profName: user!.displayName,
                            date: dateController.text,
                            time: dateController.text,
                            tm: DateTime.now().toIso8601String(),
                          ));
                          Fluttertoast.showToast(msg: "Created");
                          dateController.clear();
                        }
                      },
                      child: const Text("Post"),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.blueGrey,
                          shape: const StadiumBorder())),
                )
              ],
            ),
            const SizedBox(
              height: 90.0,
            ),
            const Text(
              'Meeting Requests ',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline),
            ),
            const SizedBox(
              height: 50.0,
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection("meetings")
                    .where('prof_id', isEqualTo: user!.uid)
                    .where("comp", isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var projModel = MeetingsModel();
                    var ds = projModel.dataListFromSnapshot(snapshot.data!);
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
                }),
          ],
        ),
      )),
    );
  }

  launchProjectScreen(String? projectId) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProjectScreen(
              projectId: projectId,
            )));
  }
}
