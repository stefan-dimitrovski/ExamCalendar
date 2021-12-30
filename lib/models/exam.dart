class Exam {
  String subject;
  DateTime date;

  Exam(this.subject, this.date) {
    subject = subject;
    date = date;
  }

  String get getSubject => subject;
  String get getDate {
    String year = date.year.toString();
    String month = date.month.toString();
    if (month.length == 1) {
      month = "0" + month;
    }
    String day = date.day.toString();
    if (day.length == 1) {
      day = "0" + day;
    }
    String hour = date.hour.toString();
    if (hour.length == 1) {
      hour = "0" + hour;
    }
    String minute = date.minute.toString();
    if (minute.length == 1) {
      minute = "0" + minute;
    }
    return "$day/$month/$year $hour:$minute";
  }
}
