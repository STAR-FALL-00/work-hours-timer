import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../core/models/shop_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/modern_hud_theme.dart';
import '../widgets/modern_hud_widgets.dart';

/// 装饰品管理页面
/// 显示已拥有的装饰品，可以激活/停用
class DecorationManagerScreen extends ConsumerWidget {
  const DecorationManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final inventory = ref.watch(inventoryProvider);
    final shopRepo = ref.watch(shopRepositoryProvider);

    // 获取所有装饰品
    final allDecorations = shopRepo.getItemsByType('decoration');

    // 筛选已拥有的装饰品
    final ownedDecorations =
        allDecorations.where((item) => inventory.hasItem(item.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.getBackground(brightness),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '我的装饰品',
          style: AppTextStyles.headline3(brightness),
        ),
        backgroundColor: AppColors.getPrimary(brightness),
        foregroundColor: Colors.white,
        actions: [
          // 显示激活数量
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(
              horizontal: ModernHudTheme.spacingM,
              vertical: ModernHudTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: AppColors.success, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${inventory.activeDecorations.length}/${ownedDecorations.length}',
                  style: AppTextStyles.bodyMedium(Brightness.dark).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ownedDecorations.isEmpty
          ? _buildEmptyState(brightness)
          : Column(
              children: [
                // 提示信息
                _buildInfoBanner(brightness),
                // 装饰品网格
                Expanded(
                  child: _buildDecorationGrid(
                    ownedDecorations,
                    inventory,
                    brightness,
                    ref,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(Brightness brightness) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_objects_outlined,
            size: 80,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: ModernHudTheme.spacingM),
          Text(
            '暂无装饰品',
            style: AppTextStyles.headline4(brightness).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: ModernHudTheme.spacingS),
          Text(
            '前往商店购买装饰品',
            style: AppTextStyles.bodyMedium(brightness).copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(Brightness brightness) {
    return Container(
      margin: const EdgeInsets.all(ModernHudTheme.spacingL),
      padding: const EdgeInsets.all(ModernHudTheme.spacingM),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.info,
            size: 24,
          ),
          const SizedBox(width: ModernHudTheme.spacingM),
          Expanded(
            child: Text(
              '点击装饰品可以激活或停用，激活的装饰品会显示在界面上',
              style: AppTextStyles.bodySmall(brightness),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorationGrid(
    List<ShopItem> decorations,
    inventory,
    Brightness brightness,
    WidgetRef ref,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: ModernHudTheme.spacingL),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: ModernHudTheme.spacingM,
        mainAxisSpacing: ModernHudTheme.spacingM,
      ),
      itemCount: decorations.length,
      itemBuilder: (context, index) {
        final decoration = decorations[index];
        final isActive = inventory.isDecorationActive(decoration.id);

        return _buildDecorationCard(
          decoration,
          isActive,
          brightness,
          ref,
        );
      },
    );
  }

  Widget _buildDecorationCard(
    ShopItem decoration,
    bool isActive,
    Brightness brightness,
    WidgetRef ref,
  ) {
    return GestureDetector(
      onTap: () => _toggleDecoration(decoration.id, isActive, ref),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? [
                    AppColors.success.withValues(alpha: 0.2),
                    AppColors.success.withValues(alpha: 0.1),
                  ]
                : [
                    AppColors.border.withValues(alpha: 0.1),
                    AppColors.border.withValues(alpha: 0.05),
                  ],
          ),
          borderRadius: ModernHudTheme.cardBorderRadius,
          border: Border.all(
            color: isActive
                ? AppColors.success
                : AppColors.border.withValues(alpha: 0.3),
            width: isActive ? 2.5 : 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : ModernHudTheme.cardShadow(brightness),
        ),
        child: Stack(
          children: [
            // 装饰品内容
            Padding(
              padding: const EdgeInsets.all(ModernHudTheme.spacingM),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 图标
                  Text(
                    decoration.icon,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: ModernHudTheme.spacingM),
                  // 名称
                  Text(
                    decoration.name,
                    style: AppTextStyles.headline5(brightness),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: ModernHudTheme.spacingS),
                  // 描述
                  Text(
                    decoration.description,
                    style: AppTextStyles.bodySmall(brightness),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleDecoration(
      String decorationId, bool isActive, WidgetRef ref) async {
    try {
      await ref.read(inventoryProvider.notifier).toggleDecoration(decorationId);

      final context = ref.context;
      if (context.mounted) {
        FloatingTextManager.show(
          context,
          text: isActive ? '✓ 已停用' : '✓ 已激活',
          type: FloatingTextType.exp,
        );
      }
    } catch (e) {
      final context = ref.context;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败：$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
