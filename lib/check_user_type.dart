import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erevna/models/user/user_model.dart';
import 'package:erevna/root_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'Student_Screens/students_main.dart';
import 'Supervisor_Screens/supervisor_main.dart';
import 'blocs/checkuser_type_bloc/check_user_type_bloc.dart';
import 'ervana_widgets/e_textField.dart';

/// checks use tyep using role in cf
///
class CheckUserTypeScreen extends StatefulWidget {
  const CheckUserTypeScreen({Key? key}) : super(key: key);

  @override
  _CheckUserTypeScreenState createState() => _CheckUserTypeScreenState();
}

class _CheckUserTypeScreenState extends State<CheckUserTypeScreen> {
  var checkUserBloc = CheckUserTypeBloc();
  @override
  void dispose() {
    super.dispose();
    //  checkUserBloc.close();
  }

  User? user;
  getUserData() {
    var res = FirebaseAuth.instance.currentUser;
    setState(() {
      user = res;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    checkUserBloc.add(CheckUserRole());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder<CheckUserTypeBloc, CheckUserTypeState>(
          bloc: checkUserBloc,
          builder: (context, state) {
            if (state is CheckUserTypeSuccess) {
              WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                log("CheckUserTypeSuccess");
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => RootScreen()),
                    (Route<dynamic> route) => false);
              });
            }
            if (state is CheckUserTypeSuccessSup) {
              WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const SupervisorMainScreens()),
                    (Route<dynamic> route) => false);
              });
            }
            if (state is CheckUserTypeSetupAccount) {
              return formData();
            }
            if (state is CheckUserTypeSuccessStudent) {
              WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                log("CheckUserTypeSuccessStudent2");
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const StudentsMainScreens()));
              });
            }
            if (state is CheckUserTypeLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is CheckUserTypeInitial) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  var fullName = TextEditingController();
  var phone = TextEditingController();
  String? _Field = 'Pure Mathematics';
  bool? isStudent = true;
  Widget formData() {
    return Container(
      padding: EdgeInsets.all(12),
      width: MediaQuery.of(context).size.width * .6,
      child: Center(
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 150,
                ),
                const Text(
                  'Please fill in the form below:',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 40,
                ),
                ETextField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                  controller: fullName,
                  labelText: "Full Name",
                ),
                const SizedBox(
                  height: 25,
                ),
                ETextField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                  controller: phone,
                  labelText: "Phone",
                ),
                const SizedBox(
                  height: 25,
                ),
                SwitchListTile(
                    title: const Text(
                      "Is Student",
                      style: TextStyle(fontSize: 25),
                    ),
                    activeColor: Colors.blueGrey,
                    value: isStudent!,
                    onChanged: (val) {
                      setState(() {
                        isStudent = val;
                      });
                    }),
                const SizedBox(
                  height: 25,
                ),
                Container(
                  height: 36,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _Field,
                      style: const TextStyle(fontSize: 23),
                      hint: const Text(
                        'Field',
                        style: TextStyle(color: Colors.black, fontSize: 23),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          _Field = value!;
                        });
                      },
                      items: <String>[
                        'Pure Mathematics',
                        'Applied Mathematics',
                        'Statistics',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),

                //
                Container(
                  height: 55,
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        checkUserBloc.add(UpdateUserData(UserModel(
                            fullName: fullName.text,
                            phone: phone.text,
                            role: isStudent! ? "stu" : "sup",
                            field: _Field,
                            email: user!.email,
                            uid: user!.uid)));
                      }
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(fontSize: 25),
                    ),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blueGrey, shape: const StadiumBorder()),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
