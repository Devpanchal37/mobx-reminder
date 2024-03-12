// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_reminder_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderHiveAdapter extends TypeAdapter<ReminderHive> {
  @override
  final int typeId = 0;

  @override
  ReminderHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReminderHive(
      id: fields[0] as String,
      creationDate: fields[1] as DateTime,
      text: fields[2] as String,
      isDone: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ReminderHive obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.creationDate)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.isDone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
