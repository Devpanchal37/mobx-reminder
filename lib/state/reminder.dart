import 'package:mobx/mobx.dart';
import 'package:mobx_reminder/hive_service/hive_reminder_model.dart';
part 'reminder.g.dart';

class Reminder = _Reminder with _$Reminder;

abstract class _Reminder with Store {
  String id;
  final DateTime creationDate;

  @observable
  String text;

  @observable
  bool isDone;

  _Reminder(
      {required this.id,
      required this.creationDate,
      required this.text,
      required this.isDone});

  // factory Reminder.fromReminderHive(ReminderHive reminderHive) {
  //   return Reminder(
  //       id: reminderHive.id,
  //       creationDate: reminderHive.creationDate,
  //       text: reminderHive.text,
  //       isDone: reminderHive.isDone);
  // }
  @override
  bool operator ==(covariant _Reminder other) =>
      id == other.id &&
      creationDate == other.creationDate &&
      text == other.text &&
      isDone == other.isDone;

  @override
  // TODO: implement hashCode
  int get hashCode => Object.hash(id, creationDate, text, isDone);
}
