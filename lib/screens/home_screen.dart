import 'package:exam_calendar/models/exam.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Exam> elements = <Exam>[];

  _openDialog() {
    final _subjectController = TextEditingController();
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
              ElevatedButton(
                onPressed: () => showDatePicker(
                  initialDate: DateTime.now(),
                  firstDate: DateTime(DateTime.now().year - 1),
                  lastDate: DateTime(DateTime.now().year + 10),
                  context: context,
                ).then((date) {
                  if (date != null) {
                    String year = date.year.toString();
                    String month = date.month.toString();
                    if (date.month < 10) {
                      month = "0$month";
                    }
                    String day = date.day.toString();
                    if (date.day < 10) {
                      day = "0$day";
                    }
                    dateText = "$year-$month-$day";
                  }
                }),
                child: const Text("Select date"),
              ),
              ElevatedButton(
                onPressed: () => showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                ).then(
                  (date) {
                    if (date != null) {
                      String hour = date.hour.toString();
                      if (hour.length == 1) {
                        hour = "0$hour";
                      }
                      String minute = date.minute.toString();
                      if (minute.length == 1) {
                        minute = "0$minute";
                      }
                      timeText = "$hour:$minute";
                    }
                  },
                ),
                child: const Text("Select time"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
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
                      elements.add(Exam(_subjectController.text, dateTime));
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
        ],
      ),
      body: ListView.builder(
        itemCount: elements.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            child: ListTile(
              title: Text(
                elements[index].getSubject,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(elements[index].getDate),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
