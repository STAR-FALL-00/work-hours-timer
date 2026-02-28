import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/shop_item.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/modern_hud_theme.dart';
import '../modern_hud_widgets.dart';

/// 主题预览对话框
/// 显示主题效果预览和购买/应用按钮
class ThemePreviewDialog extends ConsumerWidget {
  final ShopItem theme;
  final bool isOwned;
  final bool isActive;
  final int currentGold;
  final VoidCallback? onPurchase;
  final VoidCallback? onActivate;

  const ThemePreviewDialog({
    super.key,
    required this.theme,
    required this.isOwned,
    required this.isActive,
    required this.currentGold,
    this.onPurchase,
    this.onActivate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final themeColor = _getThemeColor();
    final canAfford = currentGold >= theme.price;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ModernHudTheme.borderRadius),
      ),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(ModernHudTheme.spacingL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [themeColor, themeColor.withValues(alpha: 0.8)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(ModernHudTheme.borderRadius),
                  topRight: Radius.circular(ModernHudTheme.borderRadius),
                ),
              ),
              child: Row(
                children: [
                  Text(theme.icon, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: ModernHudTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          theme.name,
                          style:
                              AppTextStyles.headline3(Brightness.dark).copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          theme.description,
                          style: AppTextStyles.bodyMedium(Brightness.dark)
                              .copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(ModernHudTheme.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 主题预览
                    _buildThemePreview(themeColor, brightness),

                    const SizedBox(height: ModernHudTheme.spacingL),

                    // 主题特性
                    _buildThemeFeatures(themeColor, brightness),

                    const SizedBox(height: ModernHudTheme.spacingL),

                    // 价格信息
                    if (!isOwned) _buildPriceCard(canAfford, brightness),

                    // 状态提示
                    if (isActive) _buildActiveIndicator(brightness),
                  ],
                ),
              ),
            ),

            // 底部按钮
            Container(
              padding: const EdgeInsets.all(ModernHudTheme.spacingL),
              decoration: BoxDecoration(
                color: AppColors.getCardBackground(brightness),
                border: Border(
                  top: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: ModernHudTheme.spacingM),
                  if (!isOwned)
                    ActionButton(
                      text: '购买',
                      icon: Icons.shopping_cart,
                      type: ActionButtonType.gold,
                      onPressed: canAfford ? onPurchase : null,
                    )
                  else if (!isActive)
                    ActionButton(
                      text: '应用主题',
                      icon: Icons.check_circle,
                      type: ActionButtonType.primary,
                      onPressed: onActivate,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ModernHudTheme.spacingL,
                        vertical: ModernHudTheme.spacingM,
                      ),
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.success, size: 20),
                          const SizedBox(width: ModernHudTheme.spacingS),
                          Text(
                            '当前主题',
                            style:
                                AppTextStyles.buttonMedium(brightness).copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemePreview(Color themeColor, Brightness brightness) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeColor.withValues(alpha: 0.2),
            themeColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(ModernHudTheme.borderRadius),
        border: Border.all(
          color: themeColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // 模拟界面元素
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [themeColor, themeColor.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '预览效果',
                  style: AppTextStyles.bodyMedium(Brightness.dark).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.getCardBackground(brightness),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: themeColor.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.star, color: themeColor, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [themeColor, themeColor.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child:
                          Icon(Icons.favorite, color: Colors.white, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.getCardBackground(brightness),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: themeColor.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.settings, color: themeColor, size: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeFeatures(Color themeColor, Brightness brightness) {
    final features = _getThemeFeatures();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '主题特性',
          style: AppTextStyles.headline5(brightness),
        ),
        const SizedBox(height: ModernHudTheme.spacingM),
        ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: ModernHudTheme.spacingS),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: themeColor, size: 20),
                  const SizedBox(width: ModernHudTheme.spacingS),
                  Expanded(
                    child: Text(
                      feature,
                      style: AppTextStyles.bodyMedium(brightness),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildPriceCard(bool canAfford, Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(ModernHudTheme.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.1),
            AppColors.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('价格', style: AppTextStyles.labelLarge(brightness)),
              Row(
                children: [
                  const Icon(Icons.monetization_on,
                      color: AppColors.accent, size: 20),
                  const SizedBox(width: 4),
                  Text('${theme.price}',
                      style: AppTextStyles.goldAmount(brightness)),
                ],
              ),
            ],
          ),
          if (!canAfford) ...[
            const SizedBox(height: ModernHudTheme.spacingM),
            Container(
              padding: const EdgeInsets.all(ModernHudTheme.spacingS),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded,
                      color: AppColors.error, size: 16),
                  const SizedBox(width: ModernHudTheme.spacingS),
                  Text(
                    '金币不足（还差 ${theme.price - currentGold}）',
                    style: AppTextStyles.statusError(brightness),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveIndicator(Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(ModernHudTheme.spacingM),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 24),
          const SizedBox(width: ModernHudTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '当前使用中',
                  style: AppTextStyles.labelLarge(brightness).copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '此主题已应用到您的界面',
                  style: AppTextStyles.bodySmall(brightness),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getThemeColor() {
    if (theme.data != null && theme.data!.containsKey('primaryColor')) {
      final colorString = theme.data!['primaryColor'] as String;
      return Color(int.parse(colorString));
    }
    return AppColors.primaryLight;
  }

  List<String> _getThemeFeatures() {
    switch (theme.id) {
      case 'theme_cyberpunk':
        return [
          '紫色霓虹主色调',
          '未来科技感设计',
          '适合夜间使用',
          '高对比度界面',
        ];
      case 'theme_matrix':
        return [
          '经典绿色主色调',
          '黑客帝国风格',
          '护眼配色方案',
          '极客专属主题',
        ];
      case 'theme_ocean':
        return [
          '宁静蓝色主色调',
          '海洋风格设计',
          '舒缓视觉体验',
          '适合长时间工作',
        ];
      case 'theme_sunset':
        return [
          '温暖橙色主色调',
          '日落渐变效果',
          '温馨舒适氛围',
          '提升工作热情',
        ];
      default:
        return [
          '独特的配色方案',
          '精心设计的界面',
          '提升使用体验',
          '个性化定制',
        ];
    }
  }
}
