class DailyWorkHours {
  final DateTime date;
  final Duration totalHours;
  final Duration workedHours;
  final Duration remainingHours;
  final Duration overtimeHours;
  final Duration standardHours;

  DailyWorkHours({
    required this.date,
    required this.totalHours,
    required this.workedHours,
    required this.remainingHours,
    required this.overtimeHours,
    Duration? standardHours,
  }) : standardHours = standardHours ?? const Duration(hours: 8);

  factory DailyWorkHours.empty(DateTime date) {
    return DailyWorkHours(
      date: date,
      totalHours: Duration.zero,
      workedHours: Duration.zero,
      remainingHours: const Duration(hours: 8),
      overtimeHours: Duration.zero,
    );
  }
}
