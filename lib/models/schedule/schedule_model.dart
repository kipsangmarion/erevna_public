import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  String? profId;
  String? profName;
  String? date;
  String? time;
  String? did;
  String? tm;

  ScheduleModel({
    this.profId,
    this.profName,
    this.date,
    this.time,
    this.did,
    this.tm,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => ScheduleModel(
        profId: json['prof_id'] as String?,
        profName: json['prof_name'] as String?,
        date: json['date'] as String?,
        time: json['time'] as String?,
        did: json['did'] as String?,
        tm: json['tm'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'prof_id': profId,
        'prof_name': profName,
        'date': date,
        'time': time,
        'did': did,
        'tm': tm,
      };

  List<ScheduleModel> dataListFromSnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((snapshot) {
      final Map<String, dynamic> json = snapshot.data() as Map<String, dynamic>;

      return ScheduleModel(
        profId: json['prof_id'] as String?,
        profName: json['prof_name'] as String?,
        date: json['date'] as String?,
        time: json['time'] as String?,
        did: json['did'] as String?,
        tm: json['tm'] as String?,
      );
    }).toList();
  }
}
