// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetModelAdapter extends TypeAdapter<PetModel> {
  @override
  final int typeId = 1;

  @override
  PetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PetModel(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      age: fields[3] as int,
      description: fields[4] as String,
      price: fields[5] as double,
      ownerName: fields[6] as String,
      ownerContact: fields[7] as String,
      city: fields[20] as String?,
      ownerId: fields[9] as String,
      imagePath: fields[8] as String?,
      createdAt: fields[10] as DateTime?,
      isAvailable: fields[11] as bool,
      buyerName: fields[12] as String?,
      buyerContact: fields[13] as String?,
      buyerAddress: fields[14] as String?,
      soldAt: fields[15] as DateTime?,
      buyerId: fields[16] as String?,
      deliveryStatus: fields[17] as String?,
      deliveredAt: fields[18] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PetModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.age)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.price)
      ..writeByte(6)
      ..write(obj.ownerName)
      ..writeByte(7)
      ..write(obj.ownerContact)
      ..writeByte(20)
      ..write(obj.city)
      ..writeByte(8)
      ..write(obj.imagePath)
      ..writeByte(9)
      ..write(obj.ownerId)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.isAvailable)
      ..writeByte(12)
      ..write(obj.buyerName)
      ..writeByte(13)
      ..write(obj.buyerContact)
      ..writeByte(14)
      ..write(obj.buyerAddress)
      ..writeByte(15)
      ..write(obj.soldAt)
      ..writeByte(16)
      ..write(obj.buyerId)
      ..writeByte(17)
      ..write(obj.deliveryStatus)
      ..writeByte(18)
      ..write(obj.deliveredAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
