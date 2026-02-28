import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../core/services/theme_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/modern_hud_theme.dart';
import '../widgets/modern_hud_widgets.dart';

/// 主题管理页面
/// 显示已拥有的主题，可以切换和预览
class ThemeManagerScreen extends ConsumerWidget {
  const ThemeManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final inventory = ref.watch(inventoryProvider);
    final themeService = ThemeService();
    final allThemes = themeService.getAllThemes();

    // 筛选已拥有的主题
    final ownedThemes =
        allThemes.where((theme) => inventory.hasItem(theme.id)).toList();

    // 添加默认主题
    final themes = [
      ...ownedThemes,
    ];

    return Scaffold(
      backgroundColor: AppColors.getBackground(brightness),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '我的主题',
          style: AppTextStyles.headline3(brightness),
        ),
        backgroundColor: AppColors.getPrimary(brightness),
        foregroundColor: Colors.white,
      ),
      body: themes.isEmpty
          ? _buildEmptyState(brightness)
          : _buildThemeGrid(themes, inventory, themeService, brightness, ref),
    );
  }

  Widget _buildEmptyState(Brightness brightness) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.palette_outlined,
            size: 80,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: ModernHudTheme.spacingM),
          Text(
            '暂无主题',
            style: AppTextStyles.headline4(brightness).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: ModernHudTheme.spacingS),
          Text(
            '前往商店购买主题',
            style: AppTextStyles.bodyMedium(brightness).copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeGrid(
    List themes,
    inventory,
    ThemeService themeService,
    Brightness brightness,
    WidgetRef ref,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(ModernHudTheme.spacingL),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: ModernHudTheme.spacingM,
        mainAxisSpacing: ModernHudTheme.spacingM,
      ),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        final isActive = inventory.activeTheme == theme.id;
        final themeColor = themeService.getThemeColor(theme.id);

        return _buildThemeCard(
          theme,
          isActive,
          themeColor,
          brightness,
          ref,
        );
      },
    );
  }

  Widget _buildThemeCard(
    theme,
    bool isActive,
    Color themeColor,
    Brightness brightness,
    WidgetRef ref,
  ) {
    return GestureDetector(
      onTap: () => _showThemeOptions(theme, isActive, ref),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeColor.withValues(alpha: 0.2),
              themeColor.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: ModernHudTheme.cardBorderRadius,
          border: Border.all(
            color: isActive ? themeColor : themeColor.withValues(alpha: 0.3),
            width: isActive ? 2.5 : 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: themeColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : ModernHudTheme.cardShadow(brightness),
        ),
        child: Stack(
          children: [
            // 主题内容
            Padding(
              padding: const EdgeInsets.all(ModernHudTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 图标和名称
                  Row(
                    children: [
                      Text(theme.icon, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: ModernHudTheme.spacingS),
                      Expanded(
                        child: Text(
                          theme.name,
                          style: AppTextStyles.headline5(brightness),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ModernHudTheme.spacingS),
                  // 描述
                  Expanded(
                    child: Text(
                      theme.description,
                      style: AppTextStyles.bodySmall(brightness),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 预览色块
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 激活标记
            if (isActive)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ModernHudTheme.spacingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '使用中',
                        style:
                            AppTextStyles.labelSmall(Brightness.dark).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showThemeOptions(theme, bool isActive, WidgetRef ref) {
    final context = ref.context;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ModernHudTheme.borderRadius),
        ),
      ),
      builder: (context) {
        final brightness = Theme.of(context).brightness;

        return Container(
          padding: const EdgeInsets.all(ModernHudTheme.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 主题信息
              Row(
                children: [
                  Text(theme.icon, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: ModernHudTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          theme.name,
                          style: AppTextStyles.headline4(brightness),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          theme.description,
                          style: AppTextStyles.bodyMedium(brightness),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ModernHudTheme.spacingL),

              // 操作按钮
              if (!isActive)
                ActionButton(
                  text: '应用主题',
                  icon: Icons.check_circle,
                  type: ActionButtonType.primary,
                  onPressed: () {
                    Navigator.pop(context);
                    _activateTheme(theme.id, ref);
                  },
                )
              else
                Container(
                  padding: const EdgeInsets.all(ModernHudTheme.spacingM),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(ModernHudTheme.borderRadius),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: ModernHudTheme.spacingS),
                      Text(
                        '当前使用中',
                        style: AppTextStyles.labelLarge(brightness).copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _activateTheme(String themeId, WidgetRef ref) async {
    try {
      await ref.read(inventoryProvider.notifier).activateTheme(themeId);

      final context = ref.context;
      if (context.mounted) {
        FloatingTextManager.show(
          context,
          text: '✨ 主题已应用',
          type: FloatingTextType.levelUp,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('主题已应用！重启应用后生效'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      final context = ref.context;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('应用主题失败：$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
