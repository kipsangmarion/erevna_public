import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erevna/models/project/project_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'project_screen.dart';

class StudentProjects extends StatefulWidget {
  const StudentProjects({Key? key}) : super(key: key);

  @override
  _StudentProjectsState createState() => _StudentProjectsState();
}

class _StudentProjectsState extends State<StudentProjects> {
  User? user;
  currentUser() {
    var res = FirebaseAuth.instance.currentUser;
    setState(() {
      user = res;
    });
  }

  @override
  void initState() {
    super.initState();
    currentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        const SizedBox(
          height: 50.0,
        ),
        const Center(
          child: Text(
            'My Projects',
            style: TextStyle(
                decoration: TextDecoration.underline,
                fontSize: 25,
                fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(
          height: 30.0,
        ),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection("projects")
                .where("comp", isEqualTo: true)
                .where('uid', isEqualTo: user!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var projModel = ProjectModel();
                var ds = projModel.dataListFromSnapshot(snapshot.data!);
                if (snapshot.data!.docs.isNotEmpty) {
                  log("ds[0].pId ${ds[0].pId}");
                  return ListView.builder(
                      itemCount: ds.length,
                      shrinkWrap: true,
                      itemBuilder: (_, i) {
                        return ListTile(
                          onTap: (){
                            launchProjectScreen(ds[i].pId);
                          },
                            subtitle: Text(ds[i].sName!),
                            title: Text(ds[i].pTitle!));
                      });
                } else {
                  return const Text("Nothing to see here yet!");
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ],
    ));
  }

  launchProjectScreen(String? projectId) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProjectScreen(
              projectId: projectId,
            )));
  }
}
