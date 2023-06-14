import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erevna/blocs/fetch_sups/fetch_sups_bloc.dart';
import 'package:erevna/blocs/project_creator_bloc/project_creator_bloc.dart';
import 'package:erevna/calendar/cal/flutter_neat_and_clean_calendar.dart';
import 'package:erevna/ervana_widgets/e_textField.dart';
import 'package:erevna/helpers/firebase_helper.dart';
import 'package:erevna/models/meetings/meetings_model.dart';
import 'package:erevna/models/project/project_model.dart';
import 'package:erevna/models/schedule/schedule_model.dart';
import 'package:erevna/models/user/user_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import 'project_screen.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({Key? key}) : super(key: key);

  @override
  _StudentHomeState createState() => _StudentHomeState();
}

final _formKey = GlobalKey<FormState>();

class _StudentHomeState extends State<StudentHome> {
  var fetchSupsBloc = FetchSupsBloc();
  String? fileName = "";
  bool isChecked = false;
  String? myFile;
  String? dataColl;
  String? data_Analysis;
  String? dataint;
  String? report;
  FilePickerResult? proposal;
  FilePickerResult? dataCollect;
  FilePickerResult? dataanalysis;
  UserModel? profSelected;
  int? selectedIndex = 0;
  var createProjectBloc = ProjectCreatorBloc();
  int _currentStep = 0;

  @override
  void dispose() {
    super.dispose();
    fetchSupsBloc.close();
    createProjectBloc.close();
    createProjectBloc.add(StartProjectInit());
  }

  User? user;
  currentUser() {
    var res = FirebaseAuth.instance.currentUser;
    setState(() {
      user = res;
    });
  }

  DateFormat format = DateFormat("yyyy-MM-dd");

  Map<DateTime, List<NeatCleanCalendarEvent>> _events = {};

  Map<DateTime, List<NeatCleanCalendarEvent>> _groupDates(
      List<MeetingsModel> allEvents) {
    _events.clear();
    for (var event in allEvents) {
      var ds = format.parse(event.date!);
      log(ds.toString());
      DateTime date = DateTime(
        ds.year,
        ds.month,
        ds.day,
      );

      if (_events[date] == null) _events[date] = [];
      _events[date]!.add(NeatCleanCalendarEvent(
        "henlo",
        isAllDay: true,
        meetingsModel: event,
        isDone: false,
        startTime: ds,
        endTime: ds,
        location: event.date!,
        description: event.sName!,
        color: Colors.green,
      ));
    }
    return _events;
  }

  void _handleNewDate(date) {}

  Widget newCalendar(List<MeetingsModel>? attendanceCard) {
    return SingleChildScrollView(
      child: Center(
        child: Calendar(
          startOnMonday: true,
          weekDays: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fr', 'Sat', 'Sun'],
          events: _groupDates(attendanceCard!),
          isExpandable: true,
          eventDoneColor: Colors.green,
          selectedColor: Colors.pink,
          todayColor: Colors.blue,
          onDateSelected: (_) => _handleNewDate,
          //dayBuilder: (BuildContext context, DateTime day) {
          //   return new Text("!");
          // },
          eventListBuilder: (BuildContext context,
              List<NeatCleanCalendarEvent> _selectesdEvents) {
            return _buildEventList(_selectesdEvents);
          },
          eventColor: Colors.grey,
          //locale: 'de_DE',
          todayButtonText: 'today',
          expandableDateFormat: 'EEEE, dd. MMMM yyyy',
          dayOfWeekStyle: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w800, fontSize: 11),
        ),
      ),
    );
  }

  getColor(String? txt) {
    if (txt == "acc") {
      return Colors.greenAccent;
    }
    if (txt == "rej") {
      return Colors.redAccent;
    }
    if (txt == "pending") {
      return Colors.amberAccent;
    } else {
      return Colors.white;
    }
  }

  Widget _buildEventList(List<NeatCleanCalendarEvent> _selectesdEvents) {
    return Container(
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _selectesdEvents.length,
          addAutomaticKeepAlives: true,
          itemBuilder: (_, i) {
            return Card(
                //color: getColor(_selectesdEvents[i].meetingsModel.status),
                child: Column(
              children: [
                Icon(
                  Icons.star,
                  color: getColor(_selectesdEvents[i].meetingsModel.status),
                ),
                ListTile(
                  trailing: const Icon(Icons.arrow_forward_ios),
                  title: Text(_selectesdEvents[i].meetingsModel.sName!),
                  onTap: () => launchProjectScreen(
                      _selectesdEvents[i].meetingsModel.projId!),
                ),
                Text(_selectesdEvents[i].meetingsModel.sName!),
                Text(_selectesdEvents[i].meetingsModel.pTitle!),
              ],
            ));
          }),
    );
  }

  launchProjectScreen(String? projectId) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProjectScreen(
              projectId: projectId,
            )));
  }

  @override
  void initState() {
    super.initState();
    myFile = null;
    proposal = null;
    profSelected = null;
    currentUser();
    fetchSupsBloc.add(FetchALlSUpsEvent());
  }

  var projectTile = TextEditingController();
  Widget startProject() {
    return SizedBox(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ETextField(
                controller: projectTile,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                labelText: "Project Title",
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            GestureDetector(
              onTap: () async {
                var fl = await firebaseHelper.pickFile();

                if (fl != null) {
                  setState(() {
                    proposal = fl;
                    myFile = fl.files.first.name;
                  });
                } else {
                  // User canceled the picker
                }
              },
              child: Text(
                myFile == null ? 'Click to Select File' : "$myFile",
                style: const TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                    fontSize: 25),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            fetchSups(),
            const SizedBox(
              height: 25,
            ),
            Container(
              height: 40,
              width: 200,
              child: ElevatedButton(
                onPressed: () async {
                  //add form key above

                  //checknif file is null
                  if (myFile == null) {
                    Fluttertoast.showToast(msg: 'Please select a file');
                  } else {
                    if (_formKey.currentState!.validate()) {
                      Fluttertoast.showToast(msg: "Uploading");
                      var downloadUrl =
                          await firebaseHelper.uploadFile(proposal);
                      log("uploading");
                      Fluttertoast.showToast(msg: "Just a moment");
                      createProjectBloc.add(StartProjectEvent(ProjectModel(
                          comp: false,
                          fProposal: downloadUrl,
                          uid: user!.uid,
                          profId: profSelected!.uid,
                          profName: profSelected!.fullName,
                          pTitle: projectTile.text,
                          status: 'pend',
                          sName: user!.displayName,
                          fData: '',
                          fDatan: '',
                          fDataint: '',
                          fReport: '')));
                    } else {
                      Fluttertoast.showToast(msg: 'Fill in all the fields');
                    }
                  }
                },
                child: const Text(
                  "Submit",
                  style: TextStyle(fontSize: 25),
                ),
                style: ElevatedButton.styleFrom(
                    primary: Colors.blueGrey, shape: const StadiumBorder()),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }

  Widget fetchSups() {
    return Container(
        child: BlocBuilder<FetchSupsBloc, FetchSupsState>(
      bloc: fetchSupsBloc,
      builder: (context, state) {
        if (state is FetchSupsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is FetchSupsInitial) {
          return const Center(
            child: Text("No Data"),
          );
        }
        if (state is FetchSupsSuccess) {
          return Column(
            children: [
              const Text('Please Select Supervisor:',
                  style: TextStyle(fontSize: 25)),
              const SizedBox(
                height: 18,
              ),
              SizedBox(
                height: 36,
                child: DropdownButton<UserModel>(
                  value: profSelected,
                  hint: const Text(
                    'Please Select A Supervisor',
                    style: TextStyle(color: Colors.black),
                  ),
                  onChanged: (UserModel? value) {
                    setState(() {
                      profSelected = value!;
                    });
                  },
                  items: state.userModelList!
                      .map<DropdownMenuItem<UserModel>>((UserModel? userModel) {
                    return DropdownMenuItem<UserModel>(
                        value: userModel, child: Text(userModel!.fullName!));
                  }).toList(),
                ),
              )
            ],
          );
        }
        return Container();
      },
    ));
  }

  Widget dateMeeting(ProjectModel? projectModel) {
    return Expanded(
        flex: 2,
        child: Column(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const Text(
                    'My Meetings',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Text(
                        'Supervisor',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Time',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Card(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Container(
                          height: 55.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              Text('Prof. X'),
                              Text('24-12-2020'),
                              Text('12:45 pm'),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )),
            const Text(
              'Open Slots',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    CheckboxListTile(
                        title: const Text('25-14-2021        12:45pm'),
                        value: isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            isChecked = value!;
                          });
                        }),
                  ],
                ),
              ),
            ))
          ],
        ));
  }

  //Stepper method
  List<Step> _mySteps(ProjectModel? projectModel) {
    List<Step> _steps = [
      Step(
          title: const Text(
            'Submit Proposal',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: projectModel!.fProposal!.isNotEmpty
              ? const SizedBox(
                  child: Text("Completed"),
                )
              : startProject(),
          // _currentStep >= 1
          isActive: true),
      Step(
        title: const Text(
          'Data Collection',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: projectModel.fData!.isNotEmpty
            ? const SizedBox(
                child: Text("Completed"),
              )
            : dataCollection(projectModel),
      ),
      Step(
        title: const Text(
          'Data Analysis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: projectModel.fDatan!.isNotEmpty
            ? const SizedBox(
                child: Text("Completed"),
              )
            : dataAnalysis(projectModel),
      ),
      Step(
        title: const Text(
          'Data Interpretation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: projectModel.fDataint!.isNotEmpty
            ? const SizedBox(
                child: Text("Completed"),
              )
            : dataInterpretation(projectModel),
      ),
      Step(
        title: const Text(
          'Final Report',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: projectModel.fReport!.isNotEmpty
            ? const SizedBox(
                child: Text("Completed"),
              )
            : finalReport(projectModel),
      ),
    ];
    return _steps;
  }

  Widget dataCollection(ProjectModel? projectModel) {
    return Container(
      color: projectModel!.status == "pend" ? Colors.amber : Colors.white,
      height: 150,
      width: MediaQuery.of(context).size.width,
      child: projectModel.status == "acc"
          ? Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () async {
                    var fl = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['docx', 'pdf', 'doc', 'xlsx'],
                    );

                    if (fl != null) {
                      setState(() {
                        dataCollect = fl;
                        dataColl = fl.files.first.name;
                      });
                    } else {
                      // User canceled the picker
                    }
                  },
                  child: Text(
                    dataColl == null ? 'Click to Select File' : "$dataColl",
                    style: const TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: () async {
                    //add form key above

                    //checknif file is null
                    if (dataCollect == null) {
                      Fluttertoast.showToast(msg: 'Please select a file');
                    } else {
                      Fluttertoast.showToast(msg: "Uploading");
                      var downloadUrl =
                          await firebaseHelper.uploadFile(dataCollect);
                      log("uploading");
                      Fluttertoast.showToast(msg: "Uploading2");
                      createProjectBloc.add(StartProjectUpdate(ProjectModel(
                          comp: false,
                          fProposal: projectModel.fProposal,
                          uid: user!.uid,
                          pId: projectModel.pId,
                          profId: projectModel.profId,
                          profName: projectModel.profName,
                          pTitle: projectModel.pTitle,
                          status: projectModel.status,
                          sName: projectModel.sName,
                          fData: downloadUrl,
                          fDatan: '',
                          fDataint: '',
                          fReport: '')));
                    }
                  },
                  child: const Text("Submit"),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blueGrey, shape: const StadiumBorder()),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            )
          : SizedBox(
              child: Center(
                child: projectModel.status == "pend"
                    ? const Text("Pending acceptance")
                    : Column(
                        children: [
                          const Text("Select a new sup"),
                          fetchSups(),
                          ElevatedButton(
                              onPressed: () {
                                if (profSelected != null) {
                                  createProjectBloc.add(StartProjectUpdate(
                                      ProjectModel(
                                          comp: false,
                                          fProposal: projectModel.fProposal,
                                          uid: user!.uid,
                                          pId: projectModel.pId,
                                          profId: profSelected!.uid,
                                          profName: profSelected!.fullName,
                                          pTitle: projectModel.pTitle,
                                          status: projectModel.status,
                                          sName: projectModel.sName,
                                          fData: projectModel.fData,
                                          fDatan: '',
                                          fDataint: '',
                                          fReport: '')));
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Select a supervisor");
                                }
                              },
                              child: const Text("Save"))
                        ],
                      ),
              ),
            ),
    );
  }

  Widget dataAnalysis(ProjectModel? projectModel) {
    return SizedBox(
      height: 150,
      width: MediaQuery.of(context).size.width,
      child: projectModel!.fData!.isEmpty
          ? const Text("Complete prev step")
          : Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                GestureDetector(
                  onTap: () async {
                    proposal = null;
                    var fl = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['docx', 'pdf', 'doc', 'xlsx'],
                    );

                    if (fl != null) {
                      setState(() {
                        dataanalysis = fl;
                        data_Analysis = fl.files.first.name;
                      });
                    } else {
                      // User canceled the picker
                    }
                  },
                  child: Text(
                    data_Analysis == null
                        ? 'Click to Select File'
                        : "$data_Analysis",
                    style: const TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: () async {
                    //add form key above

                    //checknif file is null
                    if (data_Analysis == null) {
                      Fluttertoast.showToast(msg: 'Please select a file');
                    } else {
                      Fluttertoast.showToast(msg: 'Uploading');
                      var downloadUrl =
                          await firebaseHelper.uploadFile(dataanalysis);
                      log("uploading");

                      createProjectBloc.add(StartProjectUpdate(ProjectModel(
                          comp: false,
                          fProposal: projectModel.fProposal,
                          uid: user!.uid,
                          pId: projectModel.pId,
                          profId: projectModel.profId,
                          profName: projectModel.profName,
                          pTitle: projectModel.pTitle,
                          status: projectModel.status,
                          sName: projectModel.sName,
                          fData: projectModel.fData,
                          fDatan: downloadUrl,
                          fDataint: '',
                          fReport: '')));
                      Fluttertoast.showToast(msg: 'Done');
                    }
                  },
                  child: const Text("Submit"),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blueGrey, shape: const StadiumBorder()),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
    );
  }

  Widget dataInterpretation(ProjectModel? projectModel) {
    return SizedBox(
      height: 150,
      width: MediaQuery.of(context).size.width,
      child: projectModel!.fDatan!.isEmpty
          ? const Text("Complete prev step")
          : Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                GestureDetector(
                  onTap: () async {
                    var fl = await firebaseHelper.pickFile();

                    if (fl != null) {
                      setState(() {
                        proposal = fl;
                        dataint = fl.files.first.name;
                      });
                    } else {
                      // User canceled the picker
                    }
                  },
                  child: Text(
                    dataint == null ? 'Click to Select File' : "$dataint",
                    style: const TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: () async {
                    //add form key above

                    //checknif file is null
                    if (dataint == null) {
                      Fluttertoast.showToast(msg: 'Please select a file');
                    } else {
                      Fluttertoast.showToast(msg: 'Uploading');
                      var downloadUrl =
                          await firebaseHelper.uploadFile(proposal);
                      log("uploading");

                      createProjectBloc.add(StartProjectUpdate(ProjectModel(
                          comp: false,
                          fProposal: projectModel.fProposal,
                          uid: user!.uid,
                          pId: projectModel.pId,
                          profId: projectModel.profId,
                          profName: projectModel.profName,
                          pTitle: projectModel.pTitle,
                          status: projectModel.status,
                          sName: user!.displayName,
                          fData: projectModel.fData,
                          fDatan: projectModel.fDatan,
                          fDataint: downloadUrl,
                          fReport: '')));
                      Fluttertoast.showToast(msg: 'Done');
                    }
                  },
                  child: const Text("Submit"),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blueGrey, shape: const StadiumBorder()),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
    );
  }

  Widget finalReport(ProjectModel? projectModel) {
    return SizedBox(
      height: 150,
      width: MediaQuery.of(context).size.width,
      child: projectModel!.fDataint!.isEmpty
          ? const Text("Complete prev step")
          : Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () async {
                    var fl = await firebaseHelper.pickFile();

                    if (fl != null) {
                      setState(() {
                        proposal = fl;
                        myFile = fl.files.first.name;
                      });
                    } else {
                      // User canceled the picker
                    }
                  },
                  child: Text(
                    myFile == null ? 'Click to Select File' : "$myFile",
                    style: const TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: () async {
                    //add form key above

                    //checknif file is null
                    if (myFile == null) {
                      Fluttertoast.showToast(msg: 'Please select a file');
                    } else {
                      Fluttertoast.showToast(msg: 'Uploading');
                      var downloadUrl =
                          await firebaseHelper.uploadFile(proposal);
                      log("uploading");

                      createProjectBloc.add(StartProjectUpdate(ProjectModel(
                          comp: true,
                          fProposal: projectModel.fProposal,
                          uid: user!.uid,
                          profId: projectModel.profId,
                          profName: projectModel.profName,
                          pTitle: projectModel.pTitle,
                          status: projectModel.status,
                          pId: projectModel.pId,
                          sName: projectModel.sName,
                          fData: projectModel.fData,
                          fDatan: projectModel.fDatan,
                          fDataint: projectModel.fDataint,
                          fReport: downloadUrl)));
                      Fluttertoast.showToast(msg: 'Uploading');
                    }
                  },
                  child: const Text("Submit"),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blueGrey, shape: const StadiumBorder()),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            margin: const EdgeInsets.only(left: 20.0),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: Row(
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                const Spacer(
                  flex: 5,
                ),
                Expanded(
                    child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications,
                          color: Colors.blueGrey,
                        ))),
                Expanded(
                    child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.person,
                          color: Colors.blueGrey,
                        ))),
              ],
            ),
          ),
          const SizedBox(
            height: 40.0,
          ),
          Expanded(
            flex: 4,
            child: BlocBuilder(
              bloc: createProjectBloc,
              builder: (context, state) {
                if (state is ProjectCreatorLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection("projects")
                        .where("uid", isEqualTo: user!.uid)
                        .where("comp", isEqualTo: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var projModel = ProjectModel();
                        var ds = projModel.dataListFromSnapshot(snapshot.data!);
                        if (snapshot.data!.docs.isNotEmpty) {
                          log("ds[0].pId ${ds[0].pId}");
                          return stepperWidget(ds[0]);
                        } else {
                          return startProject();
                        }
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    });
              },
            ),
          ),
        ],
      ),
    ));
  }

  /// to check if step complete check file in above step
  Widget stepperWidget(ProjectModel? projId) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection("projects")
                  .doc(projId!.pId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  DocumentSnapshot<Map<String, dynamic>>? projData =
                      snapshot.data;
                  var projectModel = ProjectModel(
                    uid: projData!['uid'] as String?,
                    sName: projData['s_name'] as String?,
                    pId: projData['p_id'] as String?,
                    comp: projData['comp'] as bool?,
                    pTitle: projData['p_title'] as String?,
                    status: projData['status'] as String?,
                    profId: projData['prof_id'] as String?,
                    profName: projData['prof_name'] as String?,
                    fProposal: projData['f_Proposal'] as String?,
                    fData: projData['f_data'] as String?,
                    fDatan: projData['f_datan'] as String?,
                    fDataint: projData['f_dataint'] as String?,
                    fReport: projData['f_report'] as String?,
                    tm: projData['tm'] as String?,
                  );
                  return Theme(
                    data: ThemeData(
                        accentColor: Colors.blueGrey,
                        primarySwatch: Colors.blueGrey,
                        colorScheme:
                            const ColorScheme.light(primary: Colors.blueGrey)),
                    child: Stepper(
                      steps: _mySteps(projectModel),
                      currentStep: _currentStep,
                      onStepTapped: (step) {
                        setState(() {
                          _currentStep = step;
                        });
                      },
                      onStepContinue: () {
                        setState(() {
                          if (_currentStep <
                              _mySteps(projectModel).length - 1) {
                            _currentStep = _currentStep + 1;
                          } else {
                            //check if everything is completed

                          }
                        });
                      },
                      onStepCancel: () {
                        setState(() {
                          if (_currentStep > 0) {
                            _currentStep = _currentStep - 1;
                          } else {
                            _currentStep = 0;
                          }
                        });
                      },
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ),
        //fetch sup schedules
        Expanded(
            flex: 2,
            child: Column(
              children: [
                const Text(
                  "Available Slots",
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                // TODO: fetch meetings use below strmb as example
                SizedBox(
                  height: kToolbarHeight * 1.4,
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection("sc")
                          .where("prof_id", isEqualTo: projId.profId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var scheduleModel = ScheduleModel();
                          var ds = scheduleModel
                              .dataListFromSnapshot(snapshot.data!);
                          if (snapshot.data!.docs.isNotEmpty) {
                            return ListView.builder(
                                itemCount: ds.length,
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemBuilder: (_, i) {
                                  return GestureDetector(
                                    onTap: () async {
                                      /// fill in fields.
                                      Fluttertoast.showToast(
                                          msg: "Creating a request");
                                      await firebaseHelper
                                          .createAMeetingRequest(
                                              meetingsModel: MeetingsModel(
                                                  uid: user!.uid,
                                                  sName: user!.displayName,
                                                  date: ds[i].date,
                                                  pTitle: projId.pTitle,
                                                  profId: projId.profId,
                                                  profName: projId.profName,
                                                  projId: projId.pId,
                                                  comp: false));
                                      Fluttertoast.showToast(msg: "Created");
                                    },
                                    child: Card(
                                      elevation: 2.0,
                                      child: Center(
                                        child: RichText(
                                          text: TextSpan(
                                              text: ds[i].profName!,
                                              children: [
                                                TextSpan(
                                                    text: "\n" +
                                                        ds[i].time.toString())
                                              ]),
                                        ),
                                      ),
                                    ),
                                  );
                                });
                          } else {
                            return Container();
                          }
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                ),
                const Text(
                  "Upcoming Meetings",
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                const SizedBox(
                  height: 20,
                ),
                Card(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection("meetings")
                          .where('uid', isEqualTo: user!.uid)
                          .where("comp", isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var projModel = MeetingsModel();
                          var ds =
                              projModel.dataListFromSnapshot(snapshot.data!);
                          if (snapshot.data!.docs.isNotEmpty) {
                            log(ds.length.toString());
                            return newCalendar(ds);
                          } else {
                            return const Text("No meetings to see here!");
                          }
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                ),
              ],
            ))
      ],
    );
  }
}
