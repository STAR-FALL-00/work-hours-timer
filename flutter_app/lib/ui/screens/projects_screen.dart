import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/project.dart';
import '../../providers/providers.dart';
import '../widgets/boss_health_bar.dart';

/// 项目管理页面
class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(allProjectsProvider);
    final activeProjects = projects.where((p) => p.status == 'active').toList();
    final completedProjects =
        projects.where((p) => p.status == 'completed').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('项目管理'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: '进行中 (${activeProjects.length})',
              icon: const Icon(Icons.work),
            ),
            Tab(
              text: '已完成 (${completedProjects.length})',
              icon: const Icon(Icons.check_circle),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProjectList(activeProjects, isActive: true),
          _buildProjectList(completedProjects, isActive: false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateProjectDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('新建项目'),
      ),
    );
  }

  Widget _buildProjectList(List<Project> projects, {required bool isActive}) {
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.work_off : Icons.check_circle_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? '暂无进行中的项目' : '暂无已完成的项目',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (isActive) ...[
              const SizedBox(height: 8),
              Text(
                '点击右下角按钮创建新项目',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectCard(project, isActive: isActive);
      },
    );
  }

  Widget _buildProjectCard(Project project, {required bool isActive}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => _showProjectDetails(project),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.blue[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isActive ? Icons.psychology : Icons.emoji_events,
                      color: isActive ? Colors.blue[700] : Colors.green[700],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (project.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            project.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isActive)
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showProjectMenu(project),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              BossHealthBar(project: project),
              if (project.status == 'completed' &&
                  project.completedAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle,
                        size: 16, color: Colors.green[600]),
                    const SizedBox(width: 4),
                    Text(
                      '完成于 ${_formatDate(project.completedAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    final hoursController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建项目'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '项目名称',
                  hintText: '例如：重构登录页',
                  prefixIcon: Icon(Icons.title),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hoursController,
                decoration: const InputDecoration(
                  labelText: '预估工时（小时）',
                  hintText: '例如：10',
                  prefixIcon: Icon(Icons.access_time),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: '项目描述（可选）',
                  hintText: '简要描述项目内容',
                  prefixIcon: Icon(Icons.description),
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
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final hoursText = hoursController.text.trim();
              final desc = descController.text.trim();

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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('项目 "$name" 创建成功！')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('创建失败：$e')),
                  );
                }
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showProjectDetails(Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(project.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (project.description != null) ...[
                Text(
                  project.description!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const Divider(height: 24),
              ],
              BossHealthBar(project: project),
              const SizedBox(height: 16),
              _buildDetailRow('创建时间', _formatDate(project.createdAt)),
              if (project.completedAt != null)
                _buildDetailRow('完成时间', _formatDate(project.completedAt!)),
              _buildDetailRow('状态', _getStatusText(project.status)),
              const Divider(height: 24),
              _buildDetailRow('预估工时', '${project.estimatedHours}h'),
              _buildDetailRow(
                  '实际工时', '${project.actualHours.toStringAsFixed(1)}h'),
              _buildDetailRow(
                  '剩余工时', '${project.remainingHours.toStringAsFixed(1)}h'),
              const Divider(height: 24),
              _buildDetailRow('金币奖励', '${project.rewardGold} 💰'),
              _buildDetailRow('经验奖励', '${project.rewardExp} ⭐'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showProjectMenu(Project project) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑项目'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现编辑功能
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('编辑功能开发中...')),
                );
              },
            ),
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
                    const SnackBar(content: Text('项目已归档')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除项目', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(project);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除项目"${project.name}"吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              await ref
                  .read(allProjectsProvider.notifier)
                  .deleteProject(project.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('项目已删除')),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
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
