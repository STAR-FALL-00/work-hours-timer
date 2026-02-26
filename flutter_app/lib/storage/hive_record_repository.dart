import 'package:hive/hive.dart';
import '../core/models/work_record.dart';
import 'record_repository.dart';

class HiveRecordRepository implements RecordRepository {
  late Box<WorkRecord> _recordBox;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    _recordBox = await Hive.openBox<WorkRecord>('work_records');
    _initialized = true;
  }

  @override
  Future<void> save(WorkRecord record) async {
    if (!_initialized) {
      await init();
    }
    await _recordBox.put(record.id, record);
  }

  @override
  Future<List<WorkRecord>> findByDate(DateTime date) async {
    if (!_initialized) {
      await init();
    }
    return _recordBox.values
        .where((record) => _isSameDay(record.date, date))
        .toList();
  }

  @override
  Future<List<WorkRecord>> findByDateRange(DateTime start, DateTime end) async {
    if (!_initialized) {
      await init();
    }

    // Normalize dates to compare only date parts (ignore time)
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);

    return _recordBox.values.where((record) {
      final recordDate =
          DateTime(record.date.year, record.date.month, record.date.day);
      return (recordDate.isAtSameMomentAs(normalizedStart) ||
              recordDate.isAfter(normalizedStart)) &&
          (recordDate.isAtSameMomentAs(normalizedEnd) ||
              recordDate.isBefore(normalizedEnd));
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Future<List<WorkRecord>> findAll() async {
    if (!_initialized) {
      await init();
    }
    return _recordBox.values.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  @override
  Future<void> delete(String id) async {
    if (!_initialized) {
      await init();
    }
    await _recordBox.delete(id);
  }

  @override
  Future<void> update(WorkRecord record) async {
    if (!_initialized) {
      await init();
    }
    await _recordBox.put(record.id, record);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
