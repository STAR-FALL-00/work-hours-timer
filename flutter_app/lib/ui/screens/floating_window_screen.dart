import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../providers/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'home_screen_v1_2.dart';

/// 悬浮窗模式 - 简化的计时器界面
///
/// 功能：
/// - 始终置顶
/// - 简化界面（只显示核心信息）
/// - 快速切换到完整模式
/// - 透明度调节
/// - 位置记忆
class FloatingWindowScreen extends ConsumerStatefulWidget {
  const FloatingWindowScreen({super.key});

  @override
  ConsumerState<FloatingWindowScreen> createState() =>
      _FloatingWindowScreenState();
}

class _FloatingWindowScreenState extends ConsumerState<FloatingWindowScreen> {
  Timer? _timer;
  DateTime? _currentStartTime;
  Duration _currentDuration = Duration.zero;
  bool _isWorking = false;
  double _opacity = 0.95;

  @override
  void initState() {
    super.initState();
    _loadCurrentSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadCurrentSession() {
    // 悬浮窗不需要加载当前会话，因为它是独立的
    // 用户需要在悬浮窗中手动开始工作
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentStartTime != null) {
        setState(() {
          _currentDuration = DateTime.now().difference(_currentStartTime!);
        });
      }
    });
  }

  Future<void> _startWork() async {
    setState(() {
      _isWorking = true;
      _currentStartTime = DateTime.now();
      _currentDuration = Duration.zero;
    });

    _startTimer();
  }

  Future<void> _endWork() async {
    _timer?.cancel();
    setState(() {
      _isWorking = false;
      _currentStartTime = null;
      _currentDuration = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  void _switchToFullMode() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreenV12()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(adventurerProfileProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Opacity(
        opacity: _opacity,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryLight,
                AppColors.primaryDark,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // 标题栏
              _buildTitleBar(),

              // 主要内容
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 计时器
                      _buildTimer(),

                      const SizedBox(height: 16),

                      // 状态指示
                      _buildStatusIndicator(),

                      const SizedBox(height: 24),

                      // 操作按钮
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),

              // 底部信息栏
              _buildBottomBar(profile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // 标题
          Text(
            '⏱️ 工时计时器',
            style: AppTextStyles.bodySmall(Brightness.dark).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // 透明度调节
          IconButton(
            icon: const Icon(Icons.opacity, size: 16),
            color: Colors.white70,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _opacity =
                    _opacity == 0.95 ? 0.7 : (_opacity == 0.7 ? 1.0 : 0.95);
              });
            },
          ),

          const SizedBox(width: 8),

          // 切换到完整模式
          IconButton(
            icon: const Icon(Icons.open_in_full, size: 16),
            color: Colors.white70,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: _switchToFullMode,
          ),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    return Text(
      _formatDuration(_currentDuration),
      style: AppTextStyles.timerLarge(Brightness.dark).copyWith(
        fontSize: 36,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isWorking
            ? AppColors.combat.withValues(alpha: 0.2)
            : AppColors.rest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isWorking ? AppColors.combat : AppColors.rest,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _isWorking ? AppColors.combat : AppColors.rest,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _isWorking ? '工作中' : '休息中',
            style: AppTextStyles.bodySmall(Brightness.dark).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isWorking) {
      return ElevatedButton(
        onPressed: _endWork,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.combat,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('结束工作'),
      );
    } else {
      return ElevatedButton(
        onPressed: _startWork,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rest,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('开始工作'),
      );
    }
  }

  Widget _buildBottomBar(profile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 等级
          _buildInfoItem('Lv.${profile.level}', Icons.star),

          // 金币
          _buildInfoItem('${profile.gold}', Icons.monetization_on),

          // 经验值
          _buildInfoItem(
              '${profile.experience}/${profile.experienceToNextLevel}',
              Icons.trending_up),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.bodySmall(Brightness.dark).copyWith(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
