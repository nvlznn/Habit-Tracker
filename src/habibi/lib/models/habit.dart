import 'package:hive/hive.dart';

class Habit {
  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.colorValue,
    required this.iconCodePoint,
    required this.dateKeys,
    required this.createdAt,
  });

  final String id;
  String name;
  String description;
  int colorValue;
  int iconCodePoint;
  Set<String> dateKeys;
  DateTime createdAt;

  Habit copyWith({
    String? name,
    String? description,
    int? colorValue,
    int? iconCodePoint,
    Set<String>? dateKeys,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      dateKeys: dateKeys ?? this.dateKeys,
      createdAt: createdAt,
    );
  }
}

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final description = reader.readString();
    final colorValue = reader.readInt();
    final iconCodePoint = reader.readInt();
    final keyCount = reader.readInt();
    final keys = <String>{
      for (var i = 0; i < keyCount; i++) reader.readString(),
    };
    final createdAtMs = reader.readInt();
    return Habit(
      id: id,
      name: name,
      description: description,
      colorValue: colorValue,
      iconCodePoint: iconCodePoint,
      dateKeys: keys,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.description);
    writer.writeInt(obj.colorValue);
    writer.writeInt(obj.iconCodePoint);
    writer.writeInt(obj.dateKeys.length);
    for (final k in obj.dateKeys) {
      writer.writeString(k);
    }
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}
