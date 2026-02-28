import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'project.g.dart';

@HiveType(typeId: 4)
class Project extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double estimatedHours;

  @HiveField(3)
  final double actualHours;

  @HiveField(4)
  final String status; // 'active', 'completed', 'archived'

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime? completedAt;

  @HiveField(7)
  final String? description;

  @HiveField(8)
  final int rewardGold;

  @HiveField(9)
  final int rewardExp;

  Project({
    String? id,
    required this.name,
    required this.estimatedHours,
    this.actualHours = 0,
    this.status = 'active',
    DateTime? createdAt,
    this.completedAt,
    this.description,
    int? rewardGold,
    int? rewardExp,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        rewardGold = rewardGold ?? (estimatedHours * 10).toInt(),
        rewardExp = rewardExp ?? (estimatedHours * 50).toInt();

  // 计算进度百分比
  double get progress => actualHours / estimatedHours;

  // 是否完成
  bool get isCompleted => actualHours >= estimatedHours;

  // 剩余工时
  double get remainingHours => estimatedHours - actualHours;

  // BOSS 血量百分比（用于显示）
  double get healthPercentage => 1.0 - progress.clamp(0.0, 1.0);

  Project copyWith({
    String? name,
    double? estimatedHours,
    double? actualHours,
    String? status,
    DateTime? completedAt,
    String? description,
    int? rewardGold,
    int? rewardExp,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      status: status ?? this.status,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      description: description ?? this.description,
      rewardGold: rewardGold ?? this.rewardGold,
      rewardExp: rewardExp ?? this.rewardExp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'estimatedHours': estimatedHours,
      'actualHours': actualHours,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'description': description,
      'rewardGold': rewardGold,
      'rewardExp': rewardExp,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      estimatedHours: (json['estimatedHours'] as num).toDouble(),
      actualHours: (json['actualHours'] as num?)?.toDouble() ?? 0,
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      description: json['description'],
      rewardGold: json['rewardGold'],
      rewardExp: json['rewardExp'],
    );
  }
}
