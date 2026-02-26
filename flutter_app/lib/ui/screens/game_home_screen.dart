import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../providers/providers.dart';
import '../../core/models/work_record.dart';
import '../../ui/theme/game_theme.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import 'achievements_screen.dart';

class GameHomeScreen extends ConsumerStatefulWidget {
  const GameHomeScreen({super.key});

  @override
  ConsumerState<GameHomeScreen> createState() => _GameHomeScreenState();
}

class _GameHomeScreenState extends ConsumerState<GameHomeScreen> {
  Timer? _timer;
  DateTime? _currentStartTime;
  Duration _currentDuration = Duration.zero;
  bool _isWorking = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startWork() {
    setState(() {
      _currentStartTime = DateTime.now();
      _isWorking = true;
      _currentDuration = Duration.zero;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentStartTime != null) {
        setState(() {
          _currentDuration = DateTime.now().difference(_currentStartTime!);
        });
      }
    });
  }

  void _pauseWork() {
    _timer?.cancel();
    setState(() {
      _isWorking = false;
    });
  }

  Future<void> _completeWork() async {
    if (_currentStartTime == null) return;

    _timer?.cancel();

    final calculator = ref.read(calculatorServiceProvider);
    final settings = ref.read(workSettingsProvider);
    
    final record = WorkRecord.fromDuration(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _currentStartTime!,
      startTime: _currentStartTime!,
      endTime: DateTime.now(),
      duration: _currentDuration,
    );

    await calculator.addWorkRecord(record);

    // 计算金币和经验
    final hours = _currentDuration.inMinutes / 60.0;
    final gold = (hours * (settings.hourlySalary ?? 0)).round();
    
    // 更新冒险者资料
    await ref.read(adventurerProfileProvider.notifier).addWorkExperience(
      _currentDuration.inHours,
      gold,
    );

    setState(() {
      _currentStartTime = null;
      _currentDuration = Duration.zero;
      _isWorking = false;
    });

    ref.invalidate(todayRecordsProvider);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours}h ${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(adventurerProfileProvider);
    final todayRecordsAsync = ref.watch(todayRecordsProvider);
    final settings = ref.watch(workSettingsProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              GameTheme.darkBrown,
              GameTheme.lightBrown,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // 标题栏
                    _buildHeader(),
                    const SizedBox(height: 8),
                    
                    // 主要内容区域 - 使用 Expanded 填充剩余空间
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 左侧：冒险者信息 + 今日战绩
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                // 冒险者信息卡
                                Expanded(
                                  flex: 3,
                                  child: _buildAdventurerCard(profile),
                                ),
                                const SizedBox(height: 8),
                                // 今日战绩
                                Expanded(
                                  flex: 2,
                                  child: todayRecordsAsync.when(
                                    data: (records) => _buildTodayStats(records, settings),
                                    loading: () => const Center(child: CircularProgressIndicator()),
                                    error: (_, __) => const Center(child: Text('加载失败')),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // 右侧：当前任务卡
                          Expanded(
                            flex: 3,
                            child: _buildCurrentQuestCard(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [GameTheme.darkBrown, GameTheme.lightBrown],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GameTheme.primaryGold, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('🏰', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                '冒险者工会',
                style: GameTheme.titleStyle.copyWith(
                  color: GameTheme.primaryGold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.emoji_events, color: GameTheme.primaryGold, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: '成就',
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.bar_chart, color: GameTheme.primaryGold, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: '统计',
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.settings, color: GameTheme.primaryGold, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: '设置',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdventurerCard(profile) {
    return Container(
      decoration: GameTheme.parchmentDecoration,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 头像和基本信息
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: GameTheme.badgeDecoration(GameTheme.primaryGold),
                child: Center(
                  child: Text(
                    profile.rankIcon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profile.name,
                      style: GameTheme.questTitleStyle.copyWith(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Lv.${profile.level} ${profile.title}',
                      style: GameTheme.bodyStyle.copyWith(
                        color: GameTheme.lightBrown,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // 金币显示
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: GameTheme.darkParchment,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: GameTheme.primaryGold, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💰', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      '${profile.totalGold}',
                      style: GameTheme.bodyStyle.copyWith(
                        color: GameTheme.primaryGold,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // 经验条
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '✨ 经验',
                    style: GameTheme.bodyStyle.copyWith(fontSize: 12),
                  ),
                  Text(
                    '${profile.experience}/${profile.experienceToNextLevel}',
                    style: GameTheme.bodyStyle.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: profile.experienceProgress,
                  minHeight: 16,
                  backgroundColor: GameTheme.darkParchment,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    GameTheme.primaryGold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentQuestCard() {
    return Container(
      decoration: GameTheme.questBoardDecoration,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题
          Center(
            child: Text(
              '📜 当前任务',
              style: GameTheme.questTitleStyle.copyWith(
                color: GameTheme.primaryGold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // 任务状态卡片
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GameTheme.parchment,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GameTheme.darkBrown, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 状态指示器
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isWorking ? '🟢' : '⚪',
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isWorking ? '进行中' : '待命',
                        style: GameTheme.questTitleStyle.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // 计时器
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _formatDuration(_currentDuration),
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: GameTheme.darkBrown,
                        shadows: [
                          Shadow(
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 按钮组
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (!_isWorking && _currentStartTime == null)
                        _buildWoodButton(
                          '⚔️ 接受任务',
                          _startWork,
                        ),
                      if (_isWorking)
                        _buildWoodButton(
                          '⏸️ 暂停',
                          _pauseWork,
                        ),
                      if (!_isWorking && _currentStartTime != null)
                        _buildWoodButton(
                          '▶️ 继续',
                          _startWork,
                        ),
                      if (_currentStartTime != null)
                        _buildWoodButton(
                          '✅ 完成',
                          _completeWork,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWoodButton(String text, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: GameTheme.woodButtonDecoration,
        child: Text(
          text,
          style: GameTheme.bodyStyle.copyWith(
            color: GameTheme.parchment,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTodayStats(List<WorkRecord> records, settings) {
    final totalDuration = records.fold<Duration>(
      Duration.zero,
      (sum, record) => sum + record.duration,
    );
    
    final hours = totalDuration.inMinutes / 60.0;
    final todayGold = (hours * (settings.hourlySalary ?? 0)).round();

    return Container(
      decoration: GameTheme.parchmentDecoration,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 今日战绩',
            style: GameTheme.questTitleStyle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 8),
          
          // 使用横向滚动的列表布局
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '⚔️',
                    '任务',
                    '${records.length}',
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildStatItem(
                    '⏱️',
                    '时长',
                    '${totalDuration.inHours}h${totalDuration.inMinutes.remainder(60)}m',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '💰',
                    '战利品',
                    '$todayGold',
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildStatItem(
                    '🔥',
                    '连续',
                    '${ref.watch(adventurerProfileProvider).consecutiveWorkDays}天',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: GameTheme.darkParchment,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GameTheme.darkBrown),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: GameTheme.bodyStyle.copyWith(fontSize: 10),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GameTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
