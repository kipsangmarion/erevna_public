import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erevna/Student_Screens/project_screen.dart';
import 'package:erevna/models/project/project_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SupervisorProjects extends StatefulWidget {
  const SupervisorProjects({Key? key}) : super(key: key);

  @override
  _SupervisorProjectsState createState() => _SupervisorProjectsState();
}

class _SupervisorProjectsState extends State<SupervisorProjects> {
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const Center(
                child: Text(
                  'Ongoing Projects',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Card(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection("projects")
                        .where('prof_id', isEqualTo: user!.uid)
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
                                    onTap: () => launchProjectScreen(ds[i].pId),
                                    subtitle: Text(ds[i].sName!),
                                    title: Text(ds[i].pTitle!));
                              });
                        } else {
                          return const Text(
                            "Nothing to see here yet!",
                            style: TextStyle(fontSize: 20),
                          );
                        }
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  launchProjectScreen(String? projectId) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProjectScreen(
              projectId: projectId,
            )));
  }
}
