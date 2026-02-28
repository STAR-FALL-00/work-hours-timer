import 'package:flutter/material.dart';
import 'package:work_hours_timer/ui/theme/app_colors.dart';
import 'package:work_hours_timer/ui/theme/app_text_styles.dart';
import 'package:work_hours_timer/ui/theme/modern_hud_theme.dart';

/// 商品卡片 - 用于商店网格布局
/// 显示物品图标、名称、价格、已拥有状态
class ItemCard extends StatelessWidget {
  final String emoji; // 物品图标（emoji）
  final String name;
  final int price;
  final bool isOwned;
  final bool isEquipped;
  final VoidCallback? onTap;

  const ItemCard({
    super.key,
    required this.emoji,
    required this.name,
    required this.price,
    this.isOwned = false,
    this.isEquipped = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shadowColor: AppColors.getShadow(brightness).withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: ModernHudTheme.cardBorderRadius,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: ModernHudTheme.cardBorderRadius,
            color: AppColors.getCardBackground(brightness),
            border: isEquipped
                ? Border.all(
                    color: AppColors.getPrimary(brightness),
                    width: 2,
                  )
                : null,
          ),
          child: Column(
            children: [
              // 上部：图标区域
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // 物品图标
                      Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),

                      // 已拥有徽章
                      if (isOwned)
                        Positioned(
                          top: ModernHudTheme.spacingS,
                          right: ModernHudTheme.spacingS,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.success.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),

                      // 装备中标识
                      if (isEquipped)
                        Positioned(
                          top: ModernHudTheme.spacingS,
                          left: ModernHudTheme.spacingS,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: ModernHudTheme.spacingS,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.getPrimary(brightness),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '装备中',
                              style:
                                  AppTextStyles.labelSmall(brightness).copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 下部：信息区域
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(ModernHudTheme.spacingM),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 名称
                      Text(
                        name,
                        style: AppTextStyles.headline5(brightness),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: ModernHudTheme.spacingXS),

                      // 价格或状态
                      if (isOwned)
                        Text(
                          isEquipped ? '已装备' : '已拥有',
                          style: AppTextStyles.labelSmall(brightness).copyWith(
                            color: AppColors.success,
                          ),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$price',
                              style: AppTextStyles.goldAmount(brightness),
                            ),
                            const SizedBox(width: 4),
                            const Text('💰', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
