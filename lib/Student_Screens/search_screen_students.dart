import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erevna/models/project/project_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'project_screen.dart';

class SearchScreenStudents extends StatefulWidget {
  const SearchScreenStudents({Key? key}) : super(key: key);

  @override
  _SearchScreenStudentsState createState() => _SearchScreenStudentsState();
}

class _SearchScreenStudentsState extends State<SearchScreenStudents> {
  String? _authorChosenValue = 'Prof. X';
  String? _fieldChosenValue = 'Mathematics';
  String? _subFieldChosenValue = 'Pure Mathematics';
  String? _cartegoryChosenValue = 'Similar Projects';
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                decoration: InputDecoration(
                    fillColor: Colors.blueGrey.shade50,
                    filled: true,
                    hintText: 'Title',
                    border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    suffixIcon: InkWell(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                            color: Colors.blueGrey.shade50,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: const Icon(
                          Icons.search_outlined,
                          color: Colors.black,
                        ),
                      ),
                    )),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                    child: Container(
                  height: 36,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _cartegoryChosenValue,
                      hint: const Text(
                        'All',
                        style: TextStyle(color: Colors.black),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          _cartegoryChosenValue = value!;
                        });
                      },
                      items: <String>[
                        'Similar Projects',
                        'Papers',
                        'Books',
                        'Jornals'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                )),
                const Spacer(),
                Expanded(
                    child: Container(
                  height: 36,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _authorChosenValue,
                      hint: const Text(
                        'Author',
                        style: TextStyle(color: Colors.black12),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          _authorChosenValue = value!;
                        });
                      },
                      items: <String>['Prof. X', 'Dr. Y', 'Mr. Z', 'Mrs. V']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                )),
                const Spacer(),
                Expanded(
                    child: Container(
                  height: 36,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _fieldChosenValue,
                      hint: const Text(
                        'Field',
                        style: TextStyle(color: Colors.black12),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          _fieldChosenValue = value!;
                        });
                      },
                      items: <String>[
                        'Mathematics',
                        'Physics',
                        'Economics',
                        'Biology'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                )),
                const Spacer(),
                Expanded(
                    child: Container(
                  height: 36,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _subFieldChosenValue,
                      hint: const Text(
                        'Subfield',
                        style: TextStyle(color: Colors.black12),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          _subFieldChosenValue = value!;
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
                )),
              ],
            ),
            const SizedBox(
              height: 30.0,
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection("projects")
                    .where("comp", isEqualTo: true)
                    //TODO here query your data
                    //.where('uid', isEqualTo: user!.uid)
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
                            return ListTile( onTap: (){
                            launchProjectScreen(ds[i].pId);
                          },
                                subtitle: Text(ds[i].sName!),
                                title: Text(ds[i].pTitle!));
                          });
                    } else {
                      return const Text("Nothing to see here!");
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ],
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
