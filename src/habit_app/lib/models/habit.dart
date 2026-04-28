import 'package:hive/hive.dart';

class Habit {
  Habit({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.createdAt,
    Set<String>? checkIns,
  }) : checkIns = checkIns ?? <String>{};

  String id;
  String name;
  int colorValue;
  DateTime createdAt;
  Set<String> checkIns;
}

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final colorValue = reader.readInt();
    final createdAtMs = reader.readInt();
    final checkInList = reader.readStringList();
    return Habit(
      id: id,
      name: name,
      colorValue: colorValue,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
      checkIns: checkInList.toSet(),
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.colorValue);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeStringList(obj.checkIns.toList());
  }
}
