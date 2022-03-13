import 'package:exam_calendar/notifications.dart';
import 'package:exam_calendar/screens/auth_screen.dart';
import 'package:exam_calendar/screens/map_screen.dart';
import 'package:exam_calendar/screens/new_exam_screen.dart';
import 'package:exam_calendar/widget/calendar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _subjectController;
  late TextEditingController _addressController;

  _signOut() {
    cancelScheduledNotifications();
    FirebaseAuth.instance.signOut();
  }

  _isLoggedIn() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AuthPage(),
          ),
        );
      } else {
        print('User is signed in!');
      }
    });
  }

  _navigateToNewExamScreen() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const NewExam()));
  }

  @override
  void initState() {
    super.initState();
    _isLoggedIn();
    _subjectController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              _navigateToNewExamScreen();
            },
            tooltip: "Add new Exam",
            icon: const Icon(
              Icons.add,
            ),
          ),
          IconButton(
            tooltip: "Exams Locations",
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MapScreen()));
            },
            icon: const Icon(Icons.map),
          ),
          IconButton(
            tooltip: "Sign out",
            onPressed: () {
              _signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Calendar(),
    );
  }
}
