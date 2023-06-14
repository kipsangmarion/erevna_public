import 'package:erevna/Supervisor_Screens/supervisor_ongoing_projects.dart';
import 'package:erevna/Supervisor_Screens/supervisor_schedule.dart';
import 'package:erevna/root_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'supervisor_home.dart';

class SupervisorMainScreens extends StatefulWidget {
  const SupervisorMainScreens({Key? key}) : super(key: key);

  @override
  _SupervisorMainScreensState createState() => _SupervisorMainScreensState();
}

class _SupervisorMainScreensState extends State<SupervisorMainScreens> {
  int? selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const SupervisorHome(),
      const SupervisorSchedule(),
      const SupervisorProjects(),
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
            selectedLabelTextStyle: TextStyle(color: Colors.blueGrey.shade900),
            onDestinationSelected: (int index) {
              setState(() {
                selectedIndex = index;
              });
            },
            destinations: const [
              NavigationRailDestination(
                label: Text('Home'),
                icon: Icon(Icons.home),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.schedule),
                selectedIcon: Icon(Icons.schedule),
                label: Text('Post Schedule'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.file_copy),
                selectedIcon: Icon(Icons.file_copy),
                label: Text('Ongoing Projects'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.logout),
                selectedIcon: Icon(Icons.logout),
                label: Text('Logout'),
              ),
            ],
            selectedIndex: selectedIndex!,
          ),
          const VerticalDivider(
            thickness: 1,
            width: 1,
          ),
          Expanded(child: _pages[selectedIndex!])
        ],
      ),
    );
  }
}
