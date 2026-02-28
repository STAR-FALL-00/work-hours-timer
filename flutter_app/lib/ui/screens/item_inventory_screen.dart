import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/item.dart';
import '../../core/services/item_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/modern_hud_theme.dart';

/// 道具背包界面
class ItemInventoryScreen extends ConsumerWidget {
  const ItemInventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final itemService = ItemService();
    final activeEffects = itemService.getActiveEffects();

    return Scaffold(
      backgroundColor: AppColors.getBackground(brightness),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '我的道具',
          style: AppTextStyles.headline3(brightness),
        ),
        backgroundColor: AppColors.getPrimary(brightness),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ModernHudTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 激活的道具效果
            if (activeEffects.isNotEmpty) ...[
              _buildActiveEffectsSection(context, activeEffects, brightness),
              const SizedBox(height: ModernHudTheme.spacingL),
            ],

            // 道具列表（示例）
            _buildInventorySection(context, brightness),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveEffectsSection(
    BuildContext context,
    Map<ItemEffectType, ItemInstance> activeEffects,
    Brightness brightness,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '激活中的道具',
          style: AppTextStyles.headline4(brightness).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: ModernHudTheme.spacingM),
        ...activeEffects.entries.map((entry) {
          final item = PredefinedItems.getItemById(entry.value.itemId);
          if (item == null) return const SizedBox.shrink();

          final remainingTime = ItemService().getItemRemainingTime(entry.key);

          return Container(
            margin: const EdgeInsets.only(bottom: ModernHudTheme.spacingM),
            padding: const EdgeInsets.all(ModernHudTheme.spacingM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.rest.withValues(alpha: 0.2),
                  AppColors.rest.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: ModernHudTheme.cardBorderRadius,
              border: Border.all(
                color: AppColors.rest,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Text(item.icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: ModernHudTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: AppTextStyles.headline5(brightness).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item.effectDescription,
                        style: AppTextStyles.bodySmall(brightness),
                      ),
                      if (remainingTime != null)
                        Text(
                          '剩余时间: ${_formatDuration(remainingTime)}',
                          style: AppTextStyles.labelSmall(brightness).copyWith(
                            color: AppColors.rest,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.check_circle,
                  color: AppColors.rest,
                  size: 24,
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildInventorySection(BuildContext context, Brightness brightness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '道具库存',
          style: AppTextStyles.headline4(brightness).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: ModernHudTheme.spacingM),
        Container(
          padding: const EdgeInsets.all(ModernHudTheme.spacingXL),
          decoration: BoxDecoration(
            color: AppColors.getCardBackground(brightness),
            borderRadius: ModernHudTheme.cardBorderRadius,
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: ModernHudTheme.spacingM),
                Text(
                  '暂无道具',
                  style: AppTextStyles.bodyLarge(brightness).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: ModernHudTheme.spacingS),
                Text(
                  '前往商店购买道具',
                  style: AppTextStyles.bodySmall(brightness).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}小时${duration.inMinutes.remainder(60)}分钟';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}分钟';
    } else {
      return '${duration.inSeconds}秒';
    }
  }
}
