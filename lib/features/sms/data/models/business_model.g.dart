// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BusinessModelAdapter extends TypeAdapter<BusinessModel> {
  @override
  final int typeId = 3;

  @override
  BusinessModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BusinessModel(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as ExpenseCategory,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      transactionCount: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BusinessModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.transactionCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
