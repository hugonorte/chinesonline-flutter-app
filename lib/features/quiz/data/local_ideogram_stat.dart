import 'package:hive/hive.dart';

class LocalIdeogramStat extends HiveObject {
  final int ideogramId;
  final String gameType;
  int correctAttempts;
  int wrongAttempts;
  DateTime lastReviewed;

  LocalIdeogramStat({
    required this.ideogramId,
    required this.gameType,
    this.correctAttempts = 0,
    this.wrongAttempts = 0,
    required this.lastReviewed,
  });

  String get boxKey => '${ideogramId}_$gameType';
}

class LocalIdeogramStatAdapter extends TypeAdapter<LocalIdeogramStat> {
  @override
  final int typeId = 1;

  @override
  LocalIdeogramStat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalIdeogramStat(
      ideogramId: fields[0] as int,
      gameType: fields[1] as String,
      correctAttempts: fields[2] as int,
      wrongAttempts: fields[3] as int,
      lastReviewed: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LocalIdeogramStat obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.ideogramId)
      ..writeByte(1)
      ..write(obj.gameType)
      ..writeByte(2)
      ..write(obj.correctAttempts)
      ..writeByte(3)
      ..write(obj.wrongAttempts)
      ..writeByte(4)
      ..write(obj.lastReviewed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalIdeogramStatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
