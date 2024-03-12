import 'package:hive/hive.dart';

part 'hive_reminder_model.g.dart';

@HiveType(typeId: 0)
class ReminderHive {
  @HiveField(0)
  String id;
  @HiveField(1)
  DateTime creationDate;
  @HiveField(2)
  String text;
  @HiveField(3)
  bool isDone;

  ReminderHive(
      {required this.id,
      required this.creationDate,
      required this.text,
      required this.isDone});
}
