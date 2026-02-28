import '../models/project.dart';
import '../models/adventurer_profile.dart';
import '../../storage/project_repository.dart';
import 'economy_service.dart';

/// 项目管理服务
/// 负责项目的业务逻辑，包括工时分配、完成检测、奖励结算等
class ProjectService {
  final ProjectRepository _repository;

  ProjectService(this._repository);

  /// 创建新项目
  /// [name] 项目名称（BOSS名称）
  /// [estimatedHours] 预估工时（BOSS总HP）
  /// [description] 项目描述
  Future<Project> createProject({
    required String name,
    required double estimatedHours,
    String? description,
  }) async {
    // 验证输入
    if (name.trim().isEmpty) {
      throw ProjectValidationException('项目名称不能为空');
    }

    if (estimatedHours <= 0) {
      throw ProjectValidationException('预估工时必须大于0');
    }

    if (estimatedHours > 1000) {
      throw ProjectValidationException('预估工时不能超过1000小时');
    }

    // 计算奖励
    final rewards = EconomyService.calculateProjectRewards(estimatedHours);

    final project = Project(
      name: name,
      estimatedHours: estimatedHours,
      description: description,
      rewardGold: rewards['gold']!,
      rewardExp: rewards['exp']!,
    );

    await _repository.createProject(project);
    return project;
  }

  /// 更新项目信息
  Future<void> updateProject(Project project) async {
    await _repository.updateProject(project);
  }

  /// 删除项目
  Future<void> deleteProject(String projectId) async {
    await _repository.deleteProject(projectId);
  }

  /// 向项目添加工时（攻击BOSS）
  /// [projectId] 项目ID
  /// [hours] 工作小时数
  /// 返回更新后的项目，如果项目完成则返回完成信息
  Future<ProjectWorkResult> addWorkHours(
    String projectId,
    double hours,
  ) async {
    if (hours <= 0) {
      throw ProjectValidationException('工作时长必须大于0');
    }

    final project = _repository.getProject(projectId);
    if (project == null) {
      throw ProjectNotFoundException(projectId);
    }

    if (project.status == 'completed') {
      throw ProjectAlreadyCompletedException(projectId);
    }

    // 添加工时
    final updated = await _repository.addHoursToProject(projectId, hours);
    if (updated == null) {
      throw ProjectNotFoundException(projectId);
    }

    // 检查是否完成
    final isJustCompleted =
        updated.status == 'completed' && project.status != 'completed';

    return ProjectWorkResult(
      project: updated,
      hoursAdded: hours,
      isCompleted: isJustCompleted,
      rewardGold: isJustCompleted ? updated.rewardGold : 0,
      rewardExp: isJustCompleted ? updated.rewardExp : 0,
    );
  }

  /// 完成项目并结算奖励
  /// [projectId] 项目ID
  /// [profile] 冒险者资料
  /// 返回更新后的资料和项目
  Future<ProjectCompletionResult> completeProject(
    String projectId,
    AdventurerProfile profile,
  ) async {
    final project = _repository.getProject(projectId);
    if (project == null) {
      throw ProjectNotFoundException(projectId);
    }

    if (project.status != 'completed') {
      throw ProjectNotCompletedException(projectId);
    }

    // 发放奖励
    var updatedProfile = profile.earnGold(project.rewardGold);

    // 添加经验（可能升级）
    final expToAdd = project.rewardExp;
    var currentExp = updatedProfile.experience + expToAdd;
    var currentLevel = updatedProfile.level;
    var leveledUp = false;

    // 检查升级
    while (currentExp >= currentLevel * 100) {
      currentExp -= currentLevel * 100;
      currentLevel++;
      leveledUp = true;
    }

    updatedProfile = updatedProfile.copyWith(
      level: currentLevel,
      experience: currentExp,
    );

    return ProjectCompletionResult(
      project: project,
      profile: updatedProfile,
      goldEarned: project.rewardGold,
      expEarned: project.rewardExp,
      leveledUp: leveledUp,
      newLevel: leveledUp ? currentLevel : null,
    );
  }

  /// 归档项目
  Future<void> archiveProject(String projectId) async {
    await _repository.archiveProject(projectId);
  }

  /// 重新激活项目
  Future<void> reactivateProject(String projectId) async {
    await _repository.reactivateProject(projectId);
  }

  /// 获取所有活跃项目
  List<Project> getActiveProjects() {
    return _repository.getActiveProjects();
  }

  /// 获取所有已完成项目
  List<Project> getCompletedProjects() {
    return _repository.getCompletedProjects();
  }

  /// 获取项目统计
  Map<String, dynamic> getProjectStats() {
    return _repository.getProjectStats();
  }

  /// 获取推荐的下一个项目
  /// 基于优先级：接近完成的项目 > 新创建的项目
  Project? getRecommendedProject() {
    final active = getActiveProjects();
    if (active.isEmpty) return null;

    // 按进度排序，优先推荐接近完成的
    active.sort((a, b) => b.progress.compareTo(a.progress));
    return active.first;
  }

  /// 计算项目剩余时间预估
  /// [project] 项目
  /// [avgHoursPerDay] 平均每天工作小时数
  /// 返回预计完成天数
  double estimateCompletionDays(Project project, double avgHoursPerDay) {
    if (avgHoursPerDay <= 0) return double.infinity;
    return project.remainingHours / avgHoursPerDay;
  }

  /// 验证项目名称是否重复
  bool isProjectNameDuplicate(String name) {
    final all = _repository.getAllProjects();
    return all.any((p) =>
        p.name.toLowerCase() == name.toLowerCase() && p.status == 'active');
  }
}

/// 项目工作结果
class ProjectWorkResult {
  final Project project;
  final double hoursAdded;
  final bool isCompleted;
  final int rewardGold;
  final int rewardExp;

  ProjectWorkResult({
    required this.project,
    required this.hoursAdded,
    required this.isCompleted,
    required this.rewardGold,
    required this.rewardExp,
  });
}

/// 项目完成结果
class ProjectCompletionResult {
  final Project project;
  final AdventurerProfile profile;
  final int goldEarned;
  final int expEarned;
  final bool leveledUp;
  final int? newLevel;

  ProjectCompletionResult({
    required this.project,
    required this.profile,
    required this.goldEarned,
    required this.expEarned,
    required this.leveledUp,
    this.newLevel,
  });
}

/// 项目验证异常
class ProjectValidationException implements Exception {
  final String message;
  ProjectValidationException(this.message);

  @override
  String toString() => '项目验证失败：$message';
}

/// 项目未找到异常
class ProjectNotFoundException implements Exception {
  final String projectId;
  ProjectNotFoundException(this.projectId);

  @override
  String toString() => '项目未找到：$projectId';
}

/// 项目已完成异常
class ProjectAlreadyCompletedException implements Exception {
  final String projectId;
  ProjectAlreadyCompletedException(this.projectId);

  @override
  String toString() => '项目已完成：$projectId';
}

/// 项目未完成异常
class ProjectNotCompletedException implements Exception {
  final String projectId;
  ProjectNotCompletedException(this.projectId);

  @override
  String toString() => '项目尚未完成：$projectId';
}
