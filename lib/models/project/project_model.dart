import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  String? uid;
  String? sName;
  String? pId;
  String? pTitle;
  String? status;
  String? profId;
  bool? comp;
  String? profName;
  String? fProposal;
  String? fData;
  String? fDatan;
  String? fDataint;
  String? fReport;
  String? tm;

  ProjectModel({
    this.uid,
    this.sName,
    this.pId,
    this.pTitle,
    this.status,
    this.profId,
    this.profName,
    this.fProposal,
    this.fData,
    this.comp,
    this.fDatan,
    this.fDataint,
    this.fReport,
    this.tm,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        uid: json['uid'] as String?,
        sName: json['s_name'] as String?,
        pId: json['p_id'] as String?,
        pTitle: json['p_title'] as String?,
        status: json['status'] as String?,
        profId: json['prof_id'] as String?,
        comp: json['comp'] as bool?,
        profName: json['prof_name'] as String?,
        fProposal: json['f_Proposal'] as String?,
        fData: json['f_data'] as String?,
        fDatan: json['f_datan'] as String?,
        fDataint: json['f_dataint'] as String?,
        fReport: json['f_report'] as String?,
        tm: json['tm'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        's_name': sName,
        'p_id': pId,
        'p_title': pTitle,
        'status': status,
        'prof_id': profId,
        "comp": comp,
        'prof_name': profName,
        'f_Proposal': fProposal,
        'f_data': fData,
        'f_datan': fDatan,
        'f_dataint': fDataint,
        'f_report': fReport,
        'tm': tm,
      };

  List<ProjectModel> dataListFromSnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((snapshot) {
      final Map<String, dynamic> json = snapshot.data() as Map<String, dynamic>;

      return ProjectModel(
        uid: json['uid'] as String?,
        sName: json['s_name'] as String?,
        pId: json['p_id'] as String?,
        comp: json['comp'] as bool?,
        pTitle: json['p_title'] as String?,
        status: json['status'] as String?,
        profId: json['prof_id'] as String?,
        profName: json['prof_name'] as String?,
        fProposal: json['f_Proposal'] as String?,
        fData: json['f_data'] as String?,
        fDatan: json['f_datan'] as String?,
        fDataint: json['f_dataint'] as String?,
        fReport: json['f_report'] as String?,
        tm: json['tm'] as String?,
      );
    }).toList();
  }
}
