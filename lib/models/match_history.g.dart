// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MatchHistoryAdapter extends TypeAdapter<MatchHistory> {
  @override
  final int typeId = 4;

  @override
  MatchHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MatchHistory(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      teams: (fields[2] as List)
          .map((dynamic e) => (e as List).cast<Player>())
          .toList(),
      teamNames: (fields[5] as List).cast<String>(),
      teamColors: (fields[6] as List).cast<int>(),
      playerGoals: (fields[3] as Map).cast<String, int>(),
      playerAssists: (fields[4] as Map).cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, MatchHistory obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.teams)
      ..writeByte(3)
      ..write(obj.playerGoals)
      ..writeByte(4)
      ..write(obj.playerAssists)
      ..writeByte(5)
      ..write(obj.teamNames)
      ..writeByte(6)
      ..write(obj.teamColors);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
