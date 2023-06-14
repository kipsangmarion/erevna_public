import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:erevna/models/user/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'check_user_type_event.dart';
part 'check_user_type_state.dart';

class CheckUserTypeBloc extends Bloc<CheckUserTypeEvent, CheckUserTypeState> {
  CheckUserTypeBloc() : super(CheckUserTypeInitial()) {
    on<CheckUserRole>((event, emit) async {
      try {
        emit.call(CheckUserTypeLoading());
        //get current digned in user
        User? user = FirebaseAuth.instance.currentUser;
        //get user data from firestore
        var doc =
            await FirebaseFirestore.instance.doc("users/${user!.uid}").get();

        //user exists check so check role
        log("userRole ${doc.data()!['role']}");
        if (doc.data()!['role'].toString() == "sup") {
          emit.call(CheckUserTypeSuccessSup());
        } else if (doc.data()!['role'].toString() == "stu") {
          log("CheckUserTypeSuccessStudent1");
          emit.call(CheckUserTypeSuccessStudent());
        } else {
          emit.call(CheckUserTypeSetupAccount());
        }
      } catch (e) {
        log(e.toString());
        emit.call(CheckUserTypeError());
      }
    });
    on<UpdateUserData>((event, emit) async {
      try {
        emit.call(CheckUserTypeLoading());
        FirebaseFirestore.instance
            .collection("users")
            .doc(event.userModel!.uid)
            .update(event.userModel!.toJson());
        emit.call(CheckUserTypeSuccess());
      } catch (e) {
        emit.call(CheckUserTypeSetupAccount());
      }
    });
  }
}
