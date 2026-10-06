// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final int typeId = 2;

  @override
  Player read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Player(
      id: fields[0] as String,
      name: fields[1] as String,
      country: fields[2] as String,
      grade: fields[3] as String,
      positions: (fields[4] as List).cast<PlayerPosition>(),
      avatarUrl: fields[6] as String?,
      number: fields[7] as int?,
      ovr: fields[8] as int?,
      team: fields[9] as String,
      goals: fields[10] as int,
      assists: fields[11] as int,
      cleanSheets: fields[12] == null ? 0 : fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.country)
      ..writeByte(3)
      ..write(obj.grade)
      ..writeByte(4)
      ..write(obj.positions)
      ..writeByte(6)
      ..write(obj.avatarUrl)
      ..writeByte(7)
      ..write(obj.number)
      ..writeByte(8)
      ..write(obj.ovr)
      ..writeByte(9)
      ..write(obj.team)
      ..writeByte(10)
      ..write(obj.goals)
      ..writeByte(11)
      ..write(obj.assists)
      ..writeByte(12)
      ..write(obj.cleanSheets);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlayerPositionAdapter extends TypeAdapter<PlayerPosition> {
  @override
  final int typeId = 0;

  @override
  PlayerPosition read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PlayerPosition.def;
      case 1:
        return PlayerPosition.mid;
      case 2:
        return PlayerPosition.fwd;
      default:
        return PlayerPosition.def;
    }
  }

  @override
  void write(BinaryWriter writer, PlayerPosition obj) {
    switch (obj) {
      case PlayerPosition.def:
        writer.writeByte(0);
        break;
      case PlayerPosition.mid:
        writer.writeByte(1);
        break;
      case PlayerPosition.fwd:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerPositionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
