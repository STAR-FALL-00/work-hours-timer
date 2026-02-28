import 'package:hive/hive.dart';
import '../core/models/project.dart';

class ProjectRepository {
  static const String _boxName = 'projects';
  late Box<Project> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Project>(_boxName);
  }

  // 获取所有项目
  List<Project> getAllProjects() {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // 获取活跃项目
  List<Project> getActiveProjects() {
    return _box.values.where((p) => p.status == 'active').toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // 获取已完成项目
  List<Project> getCompletedProjects() {
    return _box.values.where((p) => p.status == 'completed').toList()
      ..sort((a, b) => (b.completedAt ?? b.createdAt)
          .compareTo(a.completedAt ?? a.createdAt));
  }

  // 获取单个项目
  Project? getProject(String id) {
    return _box.get(id);
  }

  // 创建项目
  Future<void> createProject(Project project) async {
    await _box.put(project.id, project);
  }

  // 更新项目
  Future<void> updateProject(Project project) async {
    await _box.put(project.id, project);
  }

  // 删除项目
  Future<void> deleteProject(String id) async {
    await _box.delete(id);
  }

  // 添加工时到项目
  Future<Project?> addHoursToProject(String projectId, double hours) async {
    final project = getProject(projectId);
    if (project == null) return null;

    final newActualHours = project.actualHours + hours;
    final isNowCompleted = newActualHours >= project.estimatedHours;

    final updated = project.copyWith(
      actualHours: newActualHours,
      status: isNowCompleted ? 'completed' : 'active',
      completedAt: isNowCompleted && project.completedAt == null
          ? DateTime.now()
          : project.completedAt,
    );

    await updateProject(updated);
    return updated;
  }

  // 归档项目
  Future<void> archiveProject(String id) async {
    final project = getProject(id);
    if (project == null) return;

    final updated = project.copyWith(status: 'archived');
    await updateProject(updated);
  }

  // 重新激活项目
  Future<void> reactivateProject(String id) async {
    final project = getProject(id);
    if (project == null) return;

    final updated = project.copyWith(
      status: 'active',
      completedAt: null,
    );
    await updateProject(updated);
  }

  // 获取项目统计
  Map<String, dynamic> getProjectStats() {
    final all = getAllProjects();
    final active = all.where((p) => p.status == 'active').length;
    final completed = all.where((p) => p.status == 'completed').length;
    final totalHours = all.fold<double>(
      0,
      (sum, p) => sum + p.actualHours,
    );

    return {
      'total': all.length,
      'active': active,
      'completed': completed,
      'totalHours': totalHours,
    };
  }
}
