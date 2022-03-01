class Exam {
  Exam(
      {required this.subject,
      required this.year,
      required this.month,
      required this.day,
      required this.hour,
      required this.minute,
      required this.userId});

  Exam.fromJson(Map<String, Object?> json)
      : this(
          subject: json['subject']! as String,
          year: json['year']! as int,
          month: json['month']! as int,
          day: json['day']! as int,
          hour: json['hour']! as int,
          minute: json['minute']! as int,
          userId: json['userId']! as String,
        );

  String subject;
  String userId;
  int year;
  int month;
  int day;
  int hour;
  int minute;

  Map<String, Object?> toJson() => {
        'subject': subject,
        'year': year,
        'month': month,
        'day': day,
        'hour': hour,
        'minute': minute,
        'userId': userId,
      };

  static addZero(String s) {
    if (s.length == 1) {
      return "0" + s;
    }
    return s;
  }
}
