import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_calendar/models/exam.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class NewExam extends StatefulWidget {
  const NewExam({Key? key}) : super(key: key);

  @override
  State<NewExam> createState() => _NewExamState();
}

class _NewExamState extends State<NewExam> {
  late TextEditingController _subjectController;
  late TextEditingController _addressController;
  String dateText = '';
  String timeText = '';
  late DateTime dateTime;

  _createAppointment(
      String subject, String addressInput, DateTime dateTime) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    final examRef = firestore.collection('exams').withConverter<Exam>(
          fromFirestore: (snapshot, _) => Exam.fromJson(snapshot.data()!),
          toFirestore: (exam, _) => exam.toJson(),
        );

    var coordinates = await _getCoordinates(addressInput) as Location;
    var address = await _getAddress(coordinates) as Placemark;

    await examRef.add(Exam(
      subject: subject,
      lat: coordinates.latitude,
      lng: coordinates.longitude,
      administrativeArea: address.administrativeArea!,
      locality: address.locality!,
      country: address.country!,
      name: address.name!,
      postalcode: address.postalCode!,
      street: address.street!,
      subadministrativeArea: address.subAdministrativeArea!,
      sublocality: address.subLocality!,
      year: dateTime.year,
      month: dateTime.month,
      day: dateTime.day,
      hour: dateTime.hour,
      minute: dateTime.minute,
      userId: FirebaseAuth.instance.currentUser!.uid,
    ));
  }

  _getCoordinates(String address) async {
    if (address.isEmpty) {
      return;
    }

    List<Location> locations = await locationFromAddress(address);

    return locations.first;
  }

  _getAddress(Location coordinates) async {
    if (coordinates == null) {
      return;
    }

    List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates.latitude, coordinates.longitude);

    return placemarks.first;
  }

  @override
  void initState() {
    super.initState();
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
        title: const Text('Create Exam'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              final subject = _subjectController.text;
              final address = _addressController.text;
              dateTime = DateTime.parse('$dateText $timeText:00');

              if (subject.isEmpty) {
                return;
              }

              _createAppointment(subject, address, dateTime);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                autofocus: true,
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: "Subject",
                ),
              ),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Address",
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
      ),
    );
  }
}
