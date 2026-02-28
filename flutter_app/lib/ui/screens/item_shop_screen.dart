import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/item.dart';
import '../../core/services/item_service.dart';
import '../../providers/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/modern_hud_theme.dart';
import '../widgets/modern_hud_widgets.dart';

/// 道具商店界面
class ItemShopScreen extends ConsumerWidget {
  const ItemShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(adventurerProfileProvider);
    final brightness = Theme.of(context).brightness;
    final items = PredefinedItems.getConsumables();

    return Scaffold(
      backgroundColor: AppColors.getBackground(brightness),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '道具商店',
          style: AppTextStyles.headline3(brightness),
        ),
        backgroundColor: AppColors.getPrimary(brightness),
        foregroundColor: Colors.white,
        actions: [
          // 金币显示
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: ResourceCapsule(
                type: ResourceType.gold,
                current: profile.gold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ModernHudTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 说明卡片
            _buildInfoCard(brightness),

            const SizedBox(height: ModernHudTheme.spacingL),

            // 道具网格
            _buildItemGrid(context, ref, items, profile, brightness),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(ModernHudTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight.withValues(alpha: 0.1),
            AppColors.primaryDark.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: ModernHudTheme.cardBorderRadius,
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.primaryLight,
            size: 24,
          ),
          const SizedBox(width: ModernHudTheme.spacingM),
          Expanded(
            child: Text(
              '道具可以提升工作效率，获得更多奖励！',
              style: AppTextStyles.bodyMedium(brightness),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemGrid(
    BuildContext context,
    WidgetRef ref,
    List<Item> items,
    profile,
    Brightness brightness,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: ModernHudTheme.spacingM,
        mainAxisSpacing: ModernHudTheme.spacingM,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(context, ref, item, profile, brightness);
      },
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    WidgetRef ref,
    Item item,
    profile,
    Brightness brightness,
  ) {
    final canAfford = profile.gold >= item.price;

    return GestureDetector(
      onTap: () => _showItemDialog(context, ref, item, profile),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(brightness),
          borderRadius: ModernHudTheme.cardBorderRadius,
          border: Border.all(
            color: Color(int.parse(item.rarityColor.replaceFirst('#', '0xFF'))),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            Text(
              item.icon,
              style: const TextStyle(fontSize: 48),
            ),

            const SizedBox(height: ModernHudTheme.spacingS),

            // 名称
            Text(
              item.name,
              style: AppTextStyles.headline5(brightness).copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: ModernHudTheme.spacingXS),

            // 稀有度
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color:
                    Color(int.parse(item.rarityColor.replaceFirst('#', '0xFF')))
                        .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.rarityName,
                style: AppTextStyles.labelSmall(brightness).copyWith(
                  color: Color(
                      int.parse(item.rarityColor.replaceFirst('#', '0xFF'))),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: ModernHudTheme.spacingS),

            // 效果
            Text(
              item.effectDescription,
              style: AppTextStyles.bodySmall(brightness),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: ModernHudTheme.spacingS),

            // 价格
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: canAfford
                    ? AppColors.accent.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.monetization_on,
                    size: 16,
                    color: canAfford ? AppColors.accent : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.price.toString(),
                    style: AppTextStyles.bodyMedium(brightness).copyWith(
                      color: canAfford ? AppColors.accent : Colors.grey,
                      fontWeight: FontWeight.bold,
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

  void _showItemDialog(
    BuildContext context,
    WidgetRef ref,
    Item item,
    profile,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(item.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(child: Text(item.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description),
            const SizedBox(height: 16),
            Text('效果: ${item.effectDescription}'),
            Text('持续时间: ${item.durationDescription}'),
            Text('稀有度: ${item.rarityName}'),
            const SizedBox(height: 16),
            Text(
              '价格: ${item.price} 金币',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: profile.gold >= item.price
                ? () => _purchaseItem(context, ref, item)
                : null,
            child: const Text('购买'),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseItem(
    BuildContext context,
    WidgetRef ref,
    Item item,
  ) async {
    try {
      final profile = ref.read(adventurerProfileProvider);
      final itemService = ItemService();

      // 购买道具
      final instance = await itemService.purchaseItem(
        itemId: item.id,
        currentGold: profile.gold,
      );

      if (instance != null) {
        // 扣除金币
        final newProfile = profile.copyWith(
          gold: profile.gold - item.price,
        );
        ref.read(adventurerProfileProvider.notifier).updateProfile(newProfile);

        // TODO: 保存道具实例到库存

        if (context.mounted) {
          Navigator.pop(context);

          // 显示成功提示
          FloatingTextManager.show(
            context,
            text: '✓ 购买成功',
            type: FloatingTextType.gold,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('成功购买 ${item.name}！')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('购买失败: $e')),
        );
      }
    }
  }
}
