import 'package:erevna/models/meetings/meetings_model.dart';
import 'package:flutter/material.dart';

class NeatCleanCalendarEvent {
  String summary;
  String description;
  String location;
  DateTime startTime;
  DateTime endTime;
  Color color;
  bool isAllDay;
  bool isDone;
  MeetingsModel meetingsModel;

  NeatCleanCalendarEvent(this.summary,
      {this.description = '',
      this.location = '',
      required this.meetingsModel,
      required this.startTime,
      required this.endTime,
      this.color = Colors.blue,
      this.isAllDay = false,
      this.isDone = false});
}
