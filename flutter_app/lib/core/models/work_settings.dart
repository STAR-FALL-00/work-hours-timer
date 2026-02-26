import 'package:hive/hive.dart';
import '../services/holiday_service.dart';

part 'work_settings.g.dart';

@HiveType(typeId: 1)
class WorkSettings extends HiveObject {
  @HiveField(0)
  final int standardWorkHours; // 标准工作时长（小时）

  @HiveField(1)
  final String? startTime; // 规定上班时间 (HH:mm)

  @HiveField(2)
  final String? endTime; // 规定下班时间 (HH:mm)

  @HiveField(3)
  final double? monthlySalary; // 月薪

  WorkSettings({
    this.standardWorkHours = 8,
    this.startTime,
    this.endTime,
    this.monthlySalary,
  });

  Duration get standardDuration => Duration(hours: standardWorkHours);

  // 计算日薪（基于当月实际工作日）
  double? get dailySalary {
    if (monthlySalary == null) return null;
    final now = DateTime.now();
    final workdaysInMonth = HolidayService.getWorkdaysInMonth(now.year, now.month);
    return monthlySalary! / workdaysInMonth;
  }

  // 计算时薪（基于当月实际工作日和标准工作时长）
  double? get hourlySalary {
    if (monthlySalary == null) return null;
    final now = DateTime.now();
    final workdaysInMonth = HolidayService.getWorkdaysInMonth(now.year, now.month);
    return monthlySalary! / (workdaysInMonth * standardWorkHours);
  }

  // 获取当月工作日天数
  int get currentMonthWorkdays {
    final now = DateTime.now();
    return HolidayService.getWorkdaysInMonth(now.year, now.month);
  }

  WorkSettings copyWith({
    int? standardWorkHours,
    String? startTime,
    String? endTime,
    double? monthlySalary,
  }) {
    return WorkSettings(
      standardWorkHours: standardWorkHours ?? this.standardWorkHours,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      monthlySalary: monthlySalary ?? this.monthlySalary,
    );
  }

  // 计算预计下班时间
  DateTime? calculateExpectedEndTime(DateTime startTime) {
    if (this.startTime != null && this.endTime != null) {
      // 如果设置了固定上下班时间，使用固定下班时间
      final parts = this.endTime!.split(':');
      return DateTime(
        startTime.year,
        startTime.month,
        startTime.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } else {
      // 否则，基于开始时间 + 标准工作时长
      return startTime.add(standardDuration);
    }
  }
}
