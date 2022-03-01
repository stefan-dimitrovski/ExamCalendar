import 'package:exam_calendar/models/exam.dart';
import 'package:exam_calendar/notifications.dart';
import 'package:exam_calendar/screens/auth_screen.dart';
import 'package:exam_calendar/widget/calendar.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _subjectController;

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

  _createAppointment(String subject, DateTime dateTime) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    final examRef = firestore.collection('exams').withConverter<Exam>(
          fromFirestore: (snapshot, _) => Exam.fromJson(snapshot.data()!),
          toFirestore: (exam, _) => exam.toJson(),
        );

    await examRef.add(Exam(
      subject: subject,
      year: dateTime.year,
      month: dateTime.month,
      day: dateTime.day,
      hour: dateTime.hour,
      minute: dateTime.minute,
      userId: FirebaseAuth.instance.currentUser!.uid,
    ));
  }

  _openDialog() {
    String dateText = '';
    String timeText = '';

    late DateTime dateTime;

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Create new exam"),
        content: SizedBox(
          height: 200,
          width: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextField(
                autofocus: true,
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: "Subject",
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => showDatePicker(
                    initialDate: DateTime.now(),
                    firstDate: DateTime(DateTime.now().year - 1),
                    lastDate: DateTime(DateTime.now().year + 10),
                    context: context,
                  ).then((date) {
                    if (date != null) {
                      String year = date.year.toString();
                      String month = date.month.toString();
                      String day = date.day.toString();
                      dateText =
                          "$year-${Exam.addZero(month)}-${Exam.addZero(day)}";
                    }
                  }),
                  child: const Text("Select date"),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  ).then(
                    (date) {
                      if (date != null) {
                        String hour = date.hour.toString();
                        String minute = date.minute.toString();
                        timeText =
                            "${Exam.addZero(hour)}:${Exam.addZero(minute)}";
                      }
                    },
                  ),
                  child: const Text("Select time"),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _subjectController.clear();
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (_subjectController.text.isNotEmpty) {
                if (dateText.isNotEmpty && timeText.isNotEmpty) {
                  setState(
                    () {
                      dateTime = DateTime.parse('$dateText $timeText:00');
                      _createAppointment(_subjectController.text, dateTime);
                      _subjectController.clear();
                    },
                  );
                  Navigator.of(context).pop();
                }
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _isLoggedIn();
    _subjectController = TextEditingController();
  }

  @override
  void dispose() {
    _subjectController.dispose();
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
              _openDialog();
            },
            tooltip: "Add new Exam",
            icon: const Icon(
              Icons.add,
            ),
          ),
          IconButton(
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
