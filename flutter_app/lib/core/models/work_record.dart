import 'package:hive/hive.dart';

part 'work_record.g.dart';

@HiveType(typeId: 0)
class WorkRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startTime;

  @HiveField(2)
  final DateTime endTime;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final int durationInMilliseconds; // 存储为毫秒数

  @HiveField(5)
  final String? notes;

  WorkRecord({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.durationInMilliseconds,
    this.notes,
  });

  // 便捷的工厂方法，接受 Duration
  factory WorkRecord.fromDuration({
    required String id,
    required DateTime startTime,
    required DateTime endTime,
    required DateTime date,
    required Duration duration,
    String? notes,
  }) {
    return WorkRecord(
      id: id,
      startTime: startTime,
      endTime: endTime,
      date: date,
      durationInMilliseconds: duration.inMilliseconds,
      notes: notes,
    );
  }

  // 便捷的 getter 来获取 Duration
  Duration get duration => Duration(milliseconds: durationInMilliseconds);

  factory WorkRecord.fromJson(Map<String, dynamic> json) {
    return WorkRecord(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      date: DateTime.parse(json['date'] as String),
      durationInMilliseconds: (json['duration'] as num).toInt(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'date': date.toIso8601String(),
      'duration': durationInMilliseconds,
      'notes': notes,
    };
  }

  static Duration calculateDuration(DateTime start, DateTime end) {
    return end.difference(start);
  }

  WorkRecord copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? date,
    int? durationInMilliseconds,
    String? notes,
  }) {
    return WorkRecord(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      date: date ?? this.date,
      durationInMilliseconds:
          durationInMilliseconds ?? this.durationInMilliseconds,
      notes: notes ?? this.notes,
    );
  }
}
