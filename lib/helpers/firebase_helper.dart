import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erevna/models/meetings/meetings_model.dart';
import 'package:erevna/models/project/project_model.dart';
import 'package:erevna/models/schedule/schedule_model.dart';
import 'package:erevna/models/user/user_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

var firebaseHelper = FirebaseHelper();
firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;

class FirebaseHelper {
  Future<UserCredential?> signupUser(
      {String? email, String? password, String? displayName}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email!, password: password!);
      FirebaseAuth.instance.currentUser!.updateDisplayName(displayName);
      await addUser(userCredential.user!, displayName!);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        log('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        log('The account already exists for that email.');
      }
    } catch (e) {
      log(e.toString());
      throw Exception("error");
    }
  }

  Future<UserCredential?> singInUser({String? email, String? password}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email!, password: password!);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        log('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        log('Wrong password provided for that user.');
      }
      throw Exception("error");
    }
  }

  addUser(User user, String displayName) async {
    checkUserExist(user.uid).then((value) {
      if (!value) {
        log("user ${user.displayName} ${user.email} added");

        FirebaseFirestore.instance.doc("users/${user.uid}").set({
          "email": user.email,
          "role": "unk",
          "uid": user.uid,
          "name": displayName
        });
      } else {
        log("user ${user.displayName} ${user.email} exists");
      }
    });
  }

  static Future<bool> checkUserExist(String? userID) async {
    bool exists = false;
    try {
      await FirebaseFirestore.instance.doc("users/$userID").get().then((doc) {
        if (doc.exists) {
          exists = true;
        } else {
          exists = false;
        }
      });
      return exists;
    } catch (e) {
      return false;
    }
  }

  Future<FilePickerResult?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx', 'pdf', 'doc', 'xlsx'],
    );

    if (result != null) {
      return result;
    }
  }

  Future<List<UserModel>>? fetchSupervisors() async {
    var userm = UserModel();
    var querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("role", isEqualTo: "sup")
        .get();

    return userm.dataListFromSnapshot(querySnapshot);
  }

  Future<String>? createAProject({ProjectModel? projectModel}) async {
    try {
      DocumentReference? documentReference =
          await FirebaseFirestore.instance.collection("projects").add({
        "uid": "",
      });
      var proj = ProjectModel(
          comp: false,
          profName: projectModel!.profName,
          profId: projectModel.profId,
          fProposal: projectModel.fProposal,
          uid: projectModel.uid,
          pId: documentReference.id,
          tm: DateTime.now().toIso8601String(),
          pTitle: projectModel.pTitle,
          status: 'pend',
          sName: projectModel.sName,
          fData: '',
          fDatan: '',
          fDataint: '',
          fReport: '');
      //on accept delete
      FirebaseFirestore.instance
          .collection("sus_notfi")
          .doc(documentReference.id)
          .set({
        "sname": projectModel.sName,
        
        "docId": documentReference.id,
        "propTitle": projectModel.pTitle,
        "url": projectModel.fProposal,
        "sId": projectModel.uid,
        "profID": projectModel.profId,
        "tm": DateTime.now().toIso8601String(),
      });

      FirebaseFirestore.instance
          .collection("projects")
          .doc(documentReference.id)
          .update(proj.toJson());
      return documentReference.id;
    } catch (e) {
      throw Exception("Failed");
    }
  }

  upDateProject({ProjectModel? projectModel}) async {
    FirebaseFirestore.instance
        .collection("projects")
        .doc(projectModel!.pId)
        .update(projectModel.toJson())
        .then((value) {
      log("Success");
    }).onError((error, stackTrace) {
      throw Exception("Failed");
    });
  }
  /// no need to update entire proj model just status
  /// on update doc status delete from sus notif
  acceptDeclineproject({ProjectModel? projectModel}) async {
    FirebaseFirestore.instance
        .collection("projects")
        .doc(projectModel!.pId)
        .update({
          "status":projectModel.status
        })
        .then((value) {
      FirebaseFirestore.instance.collection("sus_notfi").doc(projectModel.pId).delete();
    }).onError((error, stackTrace) {
      throw Exception("Failed");
    });
  }

  Future<String?> uploadFile(FilePickerResult? fileName) async {
    Uint8List? fileBytes = fileName!.files.first.bytes;

    // Create a Reference to the file
    var filename = DateTime.now().toLocal().toIso8601String();
    if (kIsWeb) {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .refFromURL(storageRefFbS)
          .child("files")
          .child(filename + "." + fileName.files.first.extension!);
      await ref.putData(fileName.files.first.bytes!);

      var dwonloadurl = await ref.getDownloadURL();
      log(dwonloadurl);
      return dwonloadurl;
    }
  }

  //craete a meeting

  Future<String>? createASchedule({ScheduleModel? scheduleModel}) async {
    try {
      DocumentReference? documentReference =
          await FirebaseFirestore.instance.collection("sc").add({
        "uid": "",
      });
      var proj = ScheduleModel(
        profName: scheduleModel!.profName,
        profId: scheduleModel.profId,
        date: scheduleModel.date,
        did: documentReference.id,
        time: scheduleModel.time,
        tm: DateTime.now().toIso8601String(),
      );
      //on accept delete

      FirebaseFirestore.instance
          .collection("sc")
          .doc(documentReference.id)
          .update(proj.toJson());
      return documentReference.id;
    } catch (e) {
      throw Exception("Failed");
    }
  }

  Future createAMeetingRequest({MeetingsModel? meetingsModel}) async {
    try {
     
      var proj = MeetingsModel(
        uid: meetingsModel!.uid,
        sName: meetingsModel.sName,
        dId: meetingsModel.projId,
        projId: meetingsModel.projId,
        comp: false,
        profName: meetingsModel.profName,
        profId: meetingsModel.profId,
        date: meetingsModel.date,
        status: "pending",
        pTitle: meetingsModel.pTitle,
        tm: DateTime.now().toIso8601String(),
      );
      //on accept delete

      FirebaseFirestore.instance
          .collection("meetings")
          .doc(meetingsModel.projId)
          .set(proj.toJson());
      return meetingsModel.projId;
    } catch (e) {
      throw Exception("Failed");
    }
  }

  Future acceptAMeetingRequest({MeetingsModel? meetingsModel}) async {
    try {
      
      //on accept delete

      FirebaseFirestore.instance
          .collection("meetings")
          .doc(meetingsModel!.dId!)
          .update(meetingsModel.toJson());
      return meetingsModel.dId;
    } catch (e) {
      throw Exception("Failed");
    }
  }

   launchURL(String? url) async {
  if (!await launch(url!)) throw 'Could not launch $url';
}
}
