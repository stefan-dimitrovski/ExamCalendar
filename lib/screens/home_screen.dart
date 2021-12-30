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

  late TextEditingController _subjectController;

  @override
  void initState() {
    super.initState();

    _subjectController = TextEditingController();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
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
                    String day = date.day.toString();
                    dateText =
                        "$year-${Exam.addZero(month)}-${Exam.addZero(day)}";
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
                      String minute = date.minute.toString();
                      timeText =
                          "${Exam.addZero(hour)}:${Exam.addZero(minute)}";
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
                      elements.add(Exam(_subjectController.text, dateTime));
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
