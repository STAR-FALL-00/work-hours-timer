import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/project.dart';
import '../../providers/providers.dart';
import '../widgets/modern_hud_widgets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/modern_hud_theme.dart';

/// v1.2.0 Modern HUD 风格项目管理页面
/// 使用 QuestTile 组件，悬赏令风格
class ProjectsScreenV12 extends ConsumerStatefulWidget {
  const ProjectsScreenV12({super.key});

  @override
  ConsumerState<ProjectsScreenV12> createState() => _ProjectsScreenV12State();
}

class _ProjectsScreenV12State extends ConsumerState<ProjectsScreenV12> {
  String _selectedTab = 'active';

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(allProjectsProvider);
    final activeProjects = projects.where((p) => p.status == 'active').toList();
    final completedProjects =
        projects.where((p) => p.status == 'completed').toList();
    final brightness = Theme.of(context).brightness;

    // 按进度排序（接近完成的优先）
    activeProjects.sort((a, b) => b.progress.compareTo(a.progress));

    return Scaffold(
      backgroundColor: AppColors.getBackground(brightness),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '项目管理',
          style: AppTextStyles.headline3(brightness),
        ),
        backgroundColor: AppColors.getPrimary(brightness),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 分类导航
          _buildTabNav(
              activeProjects.length, completedProjects.length, brightness),

          // 项目列表
          Expanded(
            child: _selectedTab == 'active'
                ? _buildProjectList(activeProjects,
                    isActive: true, brightness: brightness)
                : _buildProjectList(completedProjects,
                    isActive: false, brightness: brightness),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateProjectDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('新建项目'),
        backgroundColor: AppColors.getPrimary(brightness),
      ),
    );
  }

  Widget _buildTabNav(
      int activeCount, int completedCount, Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(ModernHudTheme.spacingM),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(brightness),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(brightness).withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              '进行中',
              Icons.work,
              activeCount,
              _selectedTab == 'active',
              () => setState(() => _selectedTab = 'active'),
              brightness,
            ),
          ),
          const SizedBox(width: ModernHudTheme.spacingM),
          Expanded(
            child: _buildTabButton(
              '已完成',
              Icons.check_circle,
              completedCount,
              _selectedTab == 'completed',
              () => setState(() => _selectedTab = 'completed'),
              brightness,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    String label,
    IconData icon,
    int count,
    bool isSelected,
    VoidCallback onTap,
    Brightness brightness,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: ModernHudTheme.spacingM,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.getPrimaryGradient() : null,
          color: isSelected
              ? null
              : AppColors.getPrimary(brightness).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.getPrimary(brightness).withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  isSelected ? Colors.white : AppColors.getPrimary(brightness),
              size: 24,
            ),
            const SizedBox(height: ModernHudTheme.spacingXS),
            Text(
              label,
              style: AppTextStyles.labelLarge(brightness).copyWith(
                color: isSelected
                    ? Colors.white
                    : AppColors.getPrimary(brightness),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: ModernHudTheme.spacingXS),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ModernHudTheme.spacingS,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.getPrimary(brightness).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.labelSmall(brightness).copyWith(
                  color: isSelected
                      ? Colors.white
                      : AppColors.getPrimary(brightness),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectList(List<Project> projects,
      {required bool isActive, required Brightness brightness}) {
    if (projects.isEmpty) {
      return _buildEmptyState(isActive, brightness);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(ModernHudTheme.spacingL),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: ModernHudTheme.spacingM),
          child: QuestTile(
            projectName: project.name,
            progress: project.progress,
            progressText: '${project.actualHours.toStringAsFixed(1)}h',
            monsterIcon: _getProjectIcon(index),
            onTap: () => _showProjectDetails(project),
            onStart: isActive ? () => _startProject(project) : null,
            onMore: isActive ? () => _showProjectMenu(project) : null,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isActive, Brightness brightness) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isActive ? '📋' : '🏆',
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: ModernHudTheme.spacingM),
          Text(
            isActive ? '暂无进行中的项目' : '暂无已完成的项目',
            style: AppTextStyles.headline4(brightness).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (isActive) ...[
            const SizedBox(height: ModernHudTheme.spacingS),
            Text(
              '点击右下角按钮创建新项目',
              style: AppTextStyles.bodySmall(brightness),
            ),
          ],
        ],
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    final hoursController = TextEditingController();
    final descController = TextEditingController();
    final brightness = Theme.of(context).brightness;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(ModernHudTheme.cardBorderRadius.topLeft.x),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(ModernHudTheme.spacingS),
              decoration: BoxDecoration(
                color: AppColors.getPrimary(brightness).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add_task,
                color: AppColors.getPrimary(brightness),
              ),
            ),
            const SizedBox(width: ModernHudTheme.spacingM),
            Text(
              '新建项目',
              style: AppTextStyles.headline4(brightness),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: '项目名称',
                  hintText: '例如：重构登录页',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: ModernHudTheme.spacingM),
              TextField(
                controller: hoursController,
                decoration: InputDecoration(
                  labelText: '预估工时（小时）',
                  hintText: '例如：10',
                  prefixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: ModernHudTheme.spacingM),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: '项目描述（可选）',
                  hintText: '简要描述项目内容',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ActionButton(
            text: '创建',
            icon: Icons.check,
            type: ActionButtonType.primary,
            onPressed: () => _createProject(
              context,
              nameController.text,
              hoursController.text,
              descController.text,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createProject(
    BuildContext context,
    String name,
    String hoursText,
    String desc,
  ) async {
    name = name.trim();
    hoursText = hoursText.trim();
    desc = desc.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入项目名称')),
      );
      return;
    }

    if (hoursText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入预估工时')),
      );
      return;
    }

    final hours = double.tryParse(hoursText);
    if (hours == null || hours <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的工时数')),
      );
      return;
    }

    try {
      final projectService = ref.read(projectServiceProvider);
      await projectService.createProject(
        name: name,
        estimatedHours: hours,
        description: desc.isEmpty ? null : desc,
      );

      ref.read(allProjectsProvider.notifier).refresh();

      if (context.mounted) {
        Navigator.pop(context);

        // 显示成功动画
        FloatingTextManager.show(
          context,
          text: '✨ 新项目创建！',
          type: FloatingTextType.levelUp,
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('项目 "$name" 创建成功！'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('创建失败：$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showProjectDetails(Project project) {
    final brightness = Theme.of(context).brightness;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(ModernHudTheme.cardBorderRadius.topLeft.x),
        ),
        title: Row(
          children: [
            Text(
              _getProjectIcon(0),
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: ModernHudTheme.spacingM),
            Expanded(
              child: Text(
                project.name,
                style: AppTextStyles.headline4(brightness),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (project.description != null) ...[
                Text(
                  project.description!,
                  style: AppTextStyles.bodyMedium(brightness),
                ),
                const SizedBox(height: ModernHudTheme.spacingL),
              ],

              // HP血条
              Container(
                padding: const EdgeInsets.all(ModernHudTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppColors.getBossHealthColor(project.progress)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.getBossHealthColor(project.progress)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'HP',
                          style: AppTextStyles.labelLarge(brightness).copyWith(
                            color:
                                AppColors.getBossHealthColor(project.progress),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(project.progress * 100).toInt()}%',
                          style: AppTextStyles.labelLarge(brightness).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ModernHudTheme.spacingS),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: project.progress,
                        minHeight: 12,
                        backgroundColor:
                            AppColors.getBossHealthColor(project.progress)
                                .withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.getBossHealthColor(project.progress),
                        ),
                      ),
                    ),
                    const SizedBox(height: ModernHudTheme.spacingS),
                    Text(
                      '${project.actualHours.toStringAsFixed(1)}h / ${project.estimatedHours.toStringAsFixed(1)}h',
                      style: AppTextStyles.labelMedium(brightness),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: ModernHudTheme.spacingL),

              // 详细信息
              _buildDetailRow(
                  '创建时间', _formatDate(project.createdAt), brightness),
              if (project.completedAt != null)
                _buildDetailRow(
                    '完成时间', _formatDate(project.completedAt!), brightness),
              _buildDetailRow('状态', _getStatusText(project.status), brightness),

              const Divider(height: ModernHudTheme.spacingL),

              _buildDetailRow('预估工时', '${project.estimatedHours}h', brightness),
              _buildDetailRow('实际工时',
                  '${project.actualHours.toStringAsFixed(1)}h', brightness),
              _buildDetailRow('剩余工时',
                  '${project.remainingHours.toStringAsFixed(1)}h', brightness),

              const Divider(height: ModernHudTheme.spacingL),

              _buildDetailRow('金币奖励', '${project.rewardGold} 💰', brightness),
              _buildDetailRow('经验奖励', '${project.rewardExp} ⭐', brightness),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ModernHudTheme.spacingXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.labelMedium(brightness).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.labelMedium(brightness).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showProjectMenu(Project project) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: ModernHudTheme.spacingS),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: ModernHudTheme.spacingM),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('归档项目'),
              onTap: () async {
                Navigator.pop(context);
                await ref
                    .read(allProjectsProvider.notifier)
                    .archiveProject(project.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('项目已归档'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title:
                  const Text('删除项目', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(project);
              },
            ),
            const SizedBox(height: ModernHudTheme.spacingM),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(ModernHudTheme.cardBorderRadius.topLeft.x),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.error),
            SizedBox(width: ModernHudTheme.spacingM),
            Text('确认删除'),
          ],
        ),
        content: Text('确定要删除项目"${project.name}"吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ActionButton(
            text: '删除',
            icon: Icons.delete,
            type: ActionButtonType.combat,
            onPressed: () async {
              await ref
                  .read(allProjectsProvider.notifier)
                  .deleteProject(project.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('项目已删除'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _startProject(Project project) {
    // 设置为当前项目
    ref.read(currentProjectIdProvider.notifier).state = project.id;

    // 返回主页
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已选择项目：${project.name}'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String _getProjectIcon(int index) {
    final icons = ['🐉', '🦁', '🐯', '🦅', '🐺', '🦈', '🐙', '🦂', '🐍', '🦖'];
    return icons[index % icons.length];
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return '进行中';
      case 'completed':
        return '已完成';
      case 'archived':
        return '已归档';
      default:
        return status;
    }
  }
}
