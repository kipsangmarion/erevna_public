import 'package:erevna/Student_Screens/student_projects.dart';
import 'package:erevna/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../root_screen.dart';
import 'search_screen_students.dart';
import 'student_home.dart';

class StudentsMainScreens extends StatefulWidget {
  const StudentsMainScreens({Key? key}) : super(key: key);

  @override
  _StudentsMainScreensState createState() => _StudentsMainScreensState();
}

class _StudentsMainScreensState extends State<StudentsMainScreens> {
  int? selectedIndex = 0;
  //list your pages here and add a NavigationRailDestination item matching index to nav

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const StudentHome(),
      const SearchScreenStudents(),
      const StudentProjects(),
      Center(
        child: Container(
          height: 55,
          width: 300,
          child: ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => RootScreen()),
                  (Route<dynamic> route) => false);
            },
            child: const Text("Logout", style: TextStyle(fontSize: 30)),
            style: ElevatedButton.styleFrom(
                primary: Colors.blueGrey, shape: const StadiumBorder()),
          ),
        ),
      )
    ];
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
              backgroundColor: Colors.brown.shade50,
              extended: true,
              elevation: 4.0,
              selectedIconTheme: IconThemeData(color: Colors.blueGrey.shade900),
              selectedLabelTextStyle:
                  TextStyle(color: Colors.blueGrey.shade900),
              onDestinationSelected: (int index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              destinations: const [
                NavigationRailDestination(
                  label: Text("Home"),
                  icon: Icon(Icons.home),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search),
                  selectedIcon: Icon(Icons.search),
                  label: Text('Search'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.file_copy),
                  selectedIcon: Icon(Icons.file_copy),
                  label: Text('My Projects'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.logout),
                  selectedIcon: Icon(Icons.logout),
                  label: Text('Logout'),
                ),
              ],
              selectedIndex: selectedIndex!),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _pages[selectedIndex!])
        ],
      ),
    );
  }
}
