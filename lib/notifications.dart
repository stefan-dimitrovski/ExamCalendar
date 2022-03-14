import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

Future<void> createExamNotification(
    NotificationWeekAndTime notificationSchedule) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: createUniqueId(),
      channelKey: "scheduled_channel",
      title: "Exam Soon",
      body:
          "Your have an exam in ${notificationSchedule.timeOfDay.hour}:${notificationSchedule.timeOfDay.minute} on ${notificationSchedule.day}",
      notificationLayout: NotificationLayout.Default,
    ),
    actionButtons: [NotificationActionButton(key: 'MARK_DONE', label: 'Okay')],
    schedule: NotificationCalendar(
      day: notificationSchedule.day,
      hour: notificationSchedule.timeOfDay.hour,
      minute: notificationSchedule.timeOfDay.minute,
      second: 0,
      millisecond: 0,
    ),
  );
}

Future<void> createLocatioNotification(String lat, String lng) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: createUniqueId(),
      channelKey: 'location_channel',
      title: "Your Location is fetched",
      body: "Lat: $lat, Lng: $lng",
      notificationLayout: NotificationLayout.Default,
    ),
  );
}

Future<void> cancelScheduledNotifications() async {
  await AwesomeNotifications().cancelAllSchedules();
}

createUniqueId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(100000);
}

class NotificationWeekAndTime {
  final int day;
  final TimeOfDay timeOfDay;

  NotificationWeekAndTime({required this.day, required this.timeOfDay});
}
