import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erevna/helpers/firebase_helper.dart';
import 'package:erevna/models/project/project_model.dart';
import 'package:flutter/material.dart';

class ProjectScreen extends StatefulWidget {
  final String? projectId;
  const ProjectScreen({Key? key, required this.projectId}) : super(key: key);

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Project Details View ",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection("projects")
                  .where("p_id", isEqualTo: widget.projectId)
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
                          return db(ds[i]);
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
        ));
  }

  Widget db(ProjectModel? projectModel) {
    return Card(
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Text(
            'Student Name: ' + projectModel!.sName.toString(),
            style: const TextStyle(fontSize: 25),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'Supervisor Name: ' + projectModel.profName.toString(),
            style: const TextStyle(fontSize: 25),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
              onTap: () =>
                  firebaseHelper.launchURL(projectModel.fProposal.toString()),
              child: const Text("Proposal",
                  style: TextStyle(
                      fontSize: 25,
                      decoration: TextDecoration.underline,
                      color: Colors.blueGrey))),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
    ;
  }
}
