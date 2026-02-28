import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/shop_item.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/modern_hud_theme.dart';
import '../modern_hud_widgets.dart';

/// 装饰品预览对话框
/// 显示装饰品效果和购买按钮
class DecorationPreviewDialog extends ConsumerWidget {
  final ShopItem decoration;
  final bool isOwned;
  final bool isActive;
  final int currentGold;
  final VoidCallback? onPurchase;
  final VoidCallback? onToggle;

  const DecorationPreviewDialog({
    super.key,
    required this.decoration,
    required this.isOwned,
    required this.isActive,
    required this.currentGold,
    this.onPurchase,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final canAfford = currentGold >= decoration.price;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ModernHudTheme.borderRadius),
      ),
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(ModernHudTheme.spacingL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent,
                    AppColors.accent.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(ModernHudTheme.borderRadius),
                  topRight: Radius.circular(ModernHudTheme.borderRadius),
                ),
              ),
              child: Row(
                children: [
                  Text(decoration.icon, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: ModernHudTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          decoration.name,
                          style:
                              AppTextStyles.headline3(Brightness.dark).copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          decoration.description,
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
                    // 装饰品预览
                    _buildDecorationPreview(brightness),

                    const SizedBox(height: ModernHudTheme.spacingL),

                    // 装饰品说明
                    _buildDecorationInfo(brightness),

                    const SizedBox(height: ModernHudTheme.spacingL),

                    // 价格信息
                    if (!isOwned) _buildPriceCard(canAfford, brightness),

                    // 状态提示
                    if (isOwned && isActive) _buildActiveIndicator(brightness),
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
                  else
                    ActionButton(
                      text: isActive ? '停用' : '激活',
                      icon: isActive ? Icons.close : Icons.check_circle,
                      type: isActive
                          ? ActionButtonType.rest
                          : ActionButtonType.primary,
                      onPressed: onToggle,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorationPreview(Brightness brightness) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withValues(alpha: 0.1),
            AppColors.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(ModernHudTheme.borderRadius),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          decoration.icon,
          style: const TextStyle(fontSize: 80),
        ),
      ),
    );
  }

  Widget _buildDecorationInfo(Brightness brightness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '装饰品说明',
          style: AppTextStyles.headline5(brightness),
        ),
        const SizedBox(height: ModernHudTheme.spacingM),
        Container(
          padding: const EdgeInsets.all(ModernHudTheme.spacingM),
          decoration: BoxDecoration(
            color: AppColors.getCardBackground(brightness),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(Icons.category, '类型', '桌面装饰', brightness),
              const SizedBox(height: ModernHudTheme.spacingS),
              _buildInfoRow(Icons.visibility, '显示', '界面装饰元素', brightness),
              const SizedBox(height: ModernHudTheme.spacingS),
              _buildInfoRow(Icons.layers, '叠加', '可与其他装饰品同时使用', brightness),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value, Brightness brightness) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: ModernHudTheme.spacingS),
        Text(
          '$label：',
          style: AppTextStyles.labelMedium(brightness),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall(brightness),
          ),
        ),
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
                  Text('${decoration.price}',
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
                    '金币不足（还差 ${decoration.price - currentGold}）',
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
                  '已激活',
                  style: AppTextStyles.labelLarge(brightness).copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '此装饰品正在界面上显示',
                  style: AppTextStyles.bodySmall(brightness),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
