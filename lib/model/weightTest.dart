import 'dart:ffi';

final String tableWeightTest = 'weightTest';
//todo
//fix to save left right total timestamp
class WeightTestFields {
  static final List<String> values = [
    /// Add all fields
    id, userId, time, deviceId, type, leftKilogram , rightKilogram ,total
  ];

  static final String id = '_id';
  static final String userId = 'userId';
  static final String time = 'time';
  static final String deviceId = 'deviceId';
  static final String type = 'type';
  static final String leftKilogram = 'leftKilogram';
  static final String rightKilogram = 'rightKilogram';
  static final String total = 'total';
}

class WeightTest {
  final int? id;
  final int? userId;
  final DateTime time;
  final int? deviceId;
  final String type;
  final double leftKilogram;
  final double rightKilogram;
  final double total;

  const WeightTest({
    this.id,
    required this.userId,
    required this.time,
    required this.deviceId,
    required this.type,
    required this.leftKilogram,
    required this.rightKilogram,
    required this.total
  });

  WeightTest copy({
    int? id,
    int? userId,
    DateTime? time,
    int? deviceId,
    String? type,
    double? leftKilogram,
    double? rightKilogram,
    double? total
  }) =>
      WeightTest(
          id: id ?? this.id,
          userId: userId ?? this.userId,
          time: time ?? this.time,
          deviceId: deviceId ?? this.deviceId,
          type: type ?? this.type,
          leftKilogram: leftKilogram ?? this.leftKilogram,
          rightKilogram: rightKilogram ?? this.rightKilogram,
          total: total ?? this.total
      );

  static WeightTest fromJson(Map<String, Object?> json) => WeightTest(
    id: json[WeightTestFields.id] as int?,
    userId: json[WeightTestFields.userId] as int?,
    time: DateTime.parse(json[WeightTestFields.time] as String),
    deviceId: json[WeightTestFields.deviceId] as int?,
    type: json[WeightTestFields.type] as String,
    leftKilogram: json[WeightTestFields.leftKilogram] as double,
    rightKilogram: json[WeightTestFields.rightKilogram] as double,
    total: json[WeightTestFields.total] as double
  );

  Map<String, Object?> toJson() => {
    WeightTestFields.id: id,
    WeightTestFields.userId: userId,
    WeightTestFields.time: time.toIso8601String(),
    WeightTestFields.deviceId: deviceId,
    WeightTestFields.type: type,
    WeightTestFields.leftKilogram: leftKilogram,
    WeightTestFields.rightKilogram:rightKilogram,
    WeightTestFields.total:total
  };
}
