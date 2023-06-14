import 'package:cloud_firestore/cloud_firestore.dart';

class MeetingsModel {
  String? uid;
  String? sName;
  String? dId;
  String? date;

  String? pTitle;
  String? status;
  String? profId;
  String? profName;
  String? projId;
  String? tm;
  bool? comp;

  MeetingsModel({
    this.uid,
    this.sName,
    this.dId,
    this.date,
    this.pTitle,
    this.status,
    this.profId,
    this.profName,
    this.projId,
    this.tm,
    this.comp,
  });

  factory MeetingsModel.fromJson(Map<String, dynamic> json) => MeetingsModel(
        uid: json['uid'] as String?,
        sName: json['s_name'] as String?,
        dId: json['dId'] as String?,
        date: json['date'] as String?,
        status: json['status'] as String?,
        pTitle: json['p_title'] as String?,
        profId: json['prof_id'] as String?,
        profName: json['prof_name'] as String?,
        projId: json['projId'] as String?,
        tm: json['tm'] as String?,
        comp: json['comp'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        's_name': sName,
        'dId': dId,
        'date': date,
        'status': status,
        'p_title': pTitle,
        'prof_id': profId,
        'prof_name': profName,
        'projId': projId,
        'tm': tm,
        'comp': comp,
      };
  List<MeetingsModel> dataListFromSnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((snapshot) {
      final Map<String, dynamic> json = snapshot.data() as Map<String, dynamic>;

      return MeetingsModel(
        uid: json['uid'] as String?,
        sName: json['s_name'] as String?,
        dId: json['dId'] as String?,
        date: json['date'] as String?,
        pTitle: json['p_title'] as String?,
        status: json['status'] as String?,
        profId: json['prof_id'] as String?,
        profName: json['prof_name'] as String?,
        projId: json['projId'] as String?,
        tm: json['tm'] as String?,
        comp: json['comp'] as bool?,
      );
    }).toList();
  }
}
