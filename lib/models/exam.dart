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
    String day = date.day.toString();
    String hour = date.hour.toString();
    String minute = date.minute.toString();
    return "${addZero(day)}/${addZero(month)}/$year ${addZero(hour)}:${addZero(minute)}";
  }

  static addZero(String s) {
    if (s.length == 1) {
      return "0" + s;
    }
    return s;
  }
}
