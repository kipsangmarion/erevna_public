import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erevna/Student_Screens/project_screen.dart';
import 'package:erevna/helpers/firebase_helper.dart';
import 'package:erevna/models/notification_model.dart';
import 'package:erevna/models/project/project_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SupervisorNotificationScreens extends StatefulWidget {
  const SupervisorNotificationScreens({Key? key}) : super(key: key);

  @override
  _SupervisorNotificationScreensState createState() =>
      _SupervisorNotificationScreensState();
}

class _SupervisorNotificationScreensState
    extends State<SupervisorNotificationScreens> {
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

  launchProjectScreen(String? projectId) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProjectScreen(
              projectId: projectId,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection("sus_notfi")
                .where('profID', isEqualTo: user!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var projModel = NotificationModel();
                var ds = projModel.dataListFromSnapshot(snapshot.data!);
                if (snapshot.data!.docs.isNotEmpty) {
                  log("ds[0].pId ${ds[0].profId}");
                  return ListView.builder(
                      itemCount: ds.length,
                      shrinkWrap: true,
                      itemBuilder: (_, i) {
                        return GestureDetector(
                          onTap: () {
                            firebaseHelper.launchURL(ds[i].url!);
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: [
                                  ListTile(
                                    trailing:
                                        const Icon(Icons.arrow_forward_ios),
                                    title: Text(ds[i].propTitle!),
                                    onTap: () =>
                                        launchProjectScreen(ds[i].docId!),
                                  ),
                                  Text(ds[i].sname!),
                                  Text(ds[i].url!),
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.green,
                                            shape: const StadiumBorder()),
                                        onPressed: () async {
                                          await firebaseHelper
                                              .acceptDeclineproject(
                                                  projectModel: ProjectModel(
                                                      status: "acc",
                                                      pId: ds[i].docId));
                                        },
                                        child: const Text("Accept"),
                                      ),
                                      const SizedBox(
                                        width: 30,
                                      ),
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.red,
                                              shape: const StadiumBorder()),
                                          onPressed: () async {
                                            await firebaseHelper
                                                .acceptDeclineproject(
                                                    projectModel: ProjectModel(
                                                        status: "rej",
                                                        pId: ds[i].docId));
                                          },
                                          child: const Text("Decline")),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
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
    );
  }
}
