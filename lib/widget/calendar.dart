import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_calendar/domain/exam.dart';
import 'package:exam_calendar/notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({
    Key? key,
  }) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  List<Appointment> exams = [];
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _deleteExam(String subject) async {
    var collection = FirebaseFirestore.instance.collection('exams');
    String userId = FirebaseAuth.instance.currentUser!.uid;
    var snapshot = await collection
        .where('userId', isEqualTo: userId)
        .where('subject', isEqualTo: subject)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  _onRefresh() async {
    exams.clear();
    await _readExams();
    setState(() {});
    _refreshController.refreshCompleted();
  }

  _readExams() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    final examRef = firestore.collection('exams').withConverter<Exam>(
          fromFirestore: (snapshot, _) => Exam.fromJson(snapshot.data()!),
          toFirestore: (exam, _) => exam.toJson(),
        );

    examRef
        .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        setState(
          () {
            exams.add(
              Appointment(
                subject: doc.data().subject,
                startTime: DateTime(
                  doc.data().year,
                  doc.data().month,
                  doc.data().day,
                  doc.data().hour,
                  doc.data().minute,
                ),
                endTime: DateTime(
                  doc.data().year,
                  doc.data().month,
                  doc.data().day,
                  doc.data().hour,
                  doc.data().minute,
                ).add(
                  const Duration(minutes: 30),
                ),
              ),
            );
          },
        );
      }
    });
  }

  _showDialogInfo(Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Exam Info"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Subject: " + appointment.subject.toString(),
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                "Date: ${Exam.addZero(appointment.startTime.day.toString())}/${Exam.addZero(appointment.startTime.month.toString())}/${Exam.addZero(appointment.startTime.year.toString())}",
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                "Time: ${Exam.addZero(appointment.startTime.hour.toString())}:${Exam.addZero(appointment.startTime.minute.toString())}",
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _deleteExam(appointment.subject);
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
            TextButton(
              onPressed: () {
                NotificationWeekAndTime? pickedSchedule =
                    NotificationWeekAndTime(
                  day: appointment.startTime.day,
                  timeOfDay: TimeOfDay(
                      hour: appointment.startTime.hour,
                      minute: appointment.startTime.minute),
                );

                createExamNotification(pickedSchedule);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Scheduled Notification Created'),
                  ),
                );

                Navigator.of(context).pop();
              },
              child: const Text("Add reminder"),
            ),
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    _readExams();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      child: SfCalendar(
        firstDayOfWeek: 1,
        view: CalendarView.month,
        dataSource: MeetingDataSource(exams),
        showDatePickerButton: true,
        onTap: (date) {
          if (date.appointments!.isNotEmpty) {
            _showDialogInfo(date.appointments![0]);
          }
        },
        monthViewSettings: const MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
      ),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
