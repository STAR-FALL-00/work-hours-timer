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

  @HiveField(6)
  final String? projectId; // v1.1.0 新增：关联项目ID

  @HiveField(7)
  final int goldEarned; // v1.1.0 新增：本次获得金币

  @HiveField(8)
  final int expEarned; // v1.1.0 新增：本次获得经验

  WorkRecord({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.durationInMilliseconds,
    this.notes,
    this.projectId,
    this.goldEarned = 0,
    this.expEarned = 0,
  });

  // 便捷的工厂方法，接受 Duration
  factory WorkRecord.fromDuration({
    required String id,
    required DateTime startTime,
    required DateTime endTime,
    required DateTime date,
    required Duration duration,
    String? notes,
    String? projectId,
    int goldEarned = 0,
    int expEarned = 0,
  }) {
    return WorkRecord(
      id: id,
      startTime: startTime,
      endTime: endTime,
      date: date,
      durationInMilliseconds: duration.inMilliseconds,
      notes: notes,
      projectId: projectId,
      goldEarned: goldEarned,
      expEarned: expEarned,
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
      projectId: json['projectId'] as String?,
      goldEarned: (json['goldEarned'] as num?)?.toInt() ?? 0,
      expEarned: (json['expEarned'] as num?)?.toInt() ?? 0,
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
      'projectId': projectId,
      'goldEarned': goldEarned,
      'expEarned': expEarned,
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
    String? projectId,
    int? goldEarned,
    int? expEarned,
  }) {
    return WorkRecord(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      date: date ?? this.date,
      durationInMilliseconds:
          durationInMilliseconds ?? this.durationInMilliseconds,
      notes: notes ?? this.notes,
      projectId: projectId ?? this.projectId,
      goldEarned: goldEarned ?? this.goldEarned,
      expEarned: expEarned ?? this.expEarned,
    );
  }
}
