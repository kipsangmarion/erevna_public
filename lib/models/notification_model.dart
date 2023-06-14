// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

NotificationModel notificationModelFromJson(String str) => NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) => json.encode(data.toJson());

class NotificationModel {
    NotificationModel({
        this.profId,
        this.sId,
        this.docId,
        this.propTitle,
        this.url,
        this.sname,
        this.tm,
    });

    final String? profId;
    final String? sId;
    final String? docId;
    final String? propTitle;
    final String? url;
    final String? sname;
    final String? tm;

    factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        profId: json["profId"],
        sId: json["sId"],
        docId: json["docId"],
        propTitle: json["propTitle"],
        url: json["url"],
        sname: json["sname"],
        tm: json["tm"],
    );

    Map<String, dynamic> toJson() => {
        "profId": profId,
        "sId": sId,
        "docId": docId,
        "propTitle": propTitle,
        "url": url,
        "sname": sname,
        "tm": tm,
    };


    List<NotificationModel> dataListFromSnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((snapshot) {
      final Map<String, dynamic> documentSnapshot =
          snapshot.data() as Map<String, dynamic>;

      return NotificationModel(
        profId: documentSnapshot["profId"],
        sId: documentSnapshot["sId"],
        docId: documentSnapshot["docId"],
        propTitle: documentSnapshot["propTitle"],
        url: documentSnapshot["url"],
        sname: documentSnapshot["sname"],
        tm: documentSnapshot["tm"],
      );
    }).toList();
  }
}
