import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  String? fullName;
  String? email;
  String? role;
  String? phone;
  String? field;

  UserModel({
    this.uid,
    this.fullName,
    this.email,
    this.role,
    this.phone,
    this.field,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] as String?,
        fullName: json['fullName'] as String?,
        email: json['email'] as String?,
        role: json['role'] as String?,
        phone: json['phone'] as String?,
        field: json['field'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'role': role,
        'phone': phone,
        'field': field,
      };

  List<UserModel> dataListFromSnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((snapshot) {
      final Map<String, dynamic> documentSnapshot =
          snapshot.data() as Map<String, dynamic>;

      return UserModel(
        uid: documentSnapshot['uid'] as String?,
        fullName: documentSnapshot['fullName'] as String?,
        email: documentSnapshot['email'] as String?,
        role: documentSnapshot['role'] as String?,
        phone: documentSnapshot['phone'] as String?,
        field: documentSnapshot['field'] as String?,
      );
    }).toList();
  }
}
