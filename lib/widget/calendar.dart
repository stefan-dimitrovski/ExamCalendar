import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_calendar/models/exam.dart';
import 'package:exam_calendar/notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
                  //TODO: Add notification
                  // NotificationWeekAndTime?
                },
                child: const Text("Add reminder")),
            TextButton(
              child: const Text("OK"),
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
    return SfCalendar(
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
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
