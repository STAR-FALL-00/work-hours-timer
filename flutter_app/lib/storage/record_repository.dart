import '../core/models/work_record.dart';

abstract class RecordRepository {
  Future<void> save(WorkRecord record);
  Future<List<WorkRecord>> findByDate(DateTime date);
  Future<List<WorkRecord>> findByDateRange(DateTime start, DateTime end);
  Future<List<WorkRecord>> findAll();
  Future<void> delete(String id);
  Future<void> update(WorkRecord record);
}
