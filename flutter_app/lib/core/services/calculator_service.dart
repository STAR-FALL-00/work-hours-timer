import '../models/work_record.dart';
import '../models/daily_work_hours.dart';
import '../../storage/record_repository.dart';
import 'validation_service.dart';

class CalculatorService {
  final RecordRepository _repository;
  final ValidationService _validationService;

  CalculatorService(this._repository, this._validationService);

  Future<ValidationResult> addWorkRecord(WorkRecord record) async {
    final validation = _validationService.validateWorkRecord(
      record.startTime,
      record.endTime,
    );

    if (!validation.isValid) {
      return validation;
    }

    await _repository.save(record);
    return ValidationResult(isValid: true, errors: []);
  }

  Future<DailyWorkHours> getDailyWorkHours(DateTime date) async {
    try {
      final records = await _repository.findByDate(date);

      if (records.isEmpty) {
        return DailyWorkHours.empty(date);
      }

      final totalDuration = records.fold<Duration>(
        Duration.zero,
        (sum, record) => sum + record.duration,
      );

      const standardHours = Duration(hours: 8);
      final remaining = standardHours - totalDuration;
      final overtime = totalDuration > standardHours
          ? totalDuration - standardHours
          : Duration.zero;

      return DailyWorkHours(
        date: date,
        totalHours: totalDuration,
        workedHours: totalDuration,
        remainingHours: remaining.isNegative ? Duration.zero : remaining,
        overtimeHours: overtime,
        standardHours: standardHours,
      );
    } catch (e) {
      print('Error in getDailyWorkHours: $e');
      return DailyWorkHours.empty(date);
    }
  }

  Future<List<WorkRecord>> getWorkRecords({
    DateTime? date,
    DateTimeRange? dateRange,
  }) async {
    if (date != null) {
      return await _repository.findByDate(date);
    } else if (dateRange != null) {
      return await _repository.findByDateRange(
        dateRange.start,
        dateRange.end,
      );
    } else {
      return await _repository.findAll();
    }
  }

  Future<void> deleteWorkRecord(String id) async {
    await _repository.delete(id);
  }

  Future<ValidationResult> updateWorkRecord(WorkRecord record) async {
    final validation = _validationService.validateWorkRecord(
      record.startTime,
      record.endTime,
    );

    if (!validation.isValid) {
      return validation;
    }

    await _repository.update(record);
    return ValidationResult(isValid: true, errors: []);
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  DateTimeRange({required this.start, required this.end});
}
