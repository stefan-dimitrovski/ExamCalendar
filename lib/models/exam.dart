class Exam {
  Exam(
      {required this.subject,
      required this.lat,
      required this.lng,
      required this.administrativeArea,
      required this.locality,
      required this.country,
      required this.postalcode,
      required this.street,
      required this.name,
      required this.sublocality,
      required this.subadministrativeArea,
      required this.year,
      required this.month,
      required this.day,
      required this.hour,
      required this.minute,
      required this.userId});

  Exam.fromJson(Map<String, Object?> json)
      : this(
          subject: json['subject']! as String,
          lat: json['lat']! as double,
          lng: json['lng']! as double,
          administrativeArea: json['administrativeArea']! as String,
          locality: json['locality']! as String,
          country: json['country']! as String,
          postalcode: json['postalcode']! as String,
          street: json['street']! as String,
          name: json['name']! as String,
          sublocality: json['sublocality']! as String,
          subadministrativeArea: json['subadministrativeArea']! as String,
          year: json['year']! as int,
          month: json['month']! as int,
          day: json['day']! as int,
          hour: json['hour']! as int,
          minute: json['minute']! as int,
          userId: json['userId']! as String,
        );

  String subject;
  String userId;
  double lat;
  double lng;
  String name;
  String street;
  String country;
  String sublocality;
  String postalcode;
  String administrativeArea;
  String subadministrativeArea;
  String locality;
  int year;
  int month;
  int day;
  int hour;
  int minute;

  Map<String, Object?> toJson() => {
        'subject': subject,
        'lat': lat,
        'lng': lng,
        'administrativeArea': administrativeArea,
        'locality': locality,
        'country': country,
        'postalcode': postalcode,
        'street': street,
        'name': name,
        'sublocality': sublocality,
        'subadministrativeArea': subadministrativeArea,
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
