import 'package:mobx/mobx.dart';
part 'reminder.g.dart';

class Reminder = _Reminder with _$Reminder;

abstract class _Reminder with Store {
  final String id;
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
