import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/shop_item.dart';
import '../../providers/providers.dart';
import '../widgets/modern_hud_widgets.dart';
import '../widgets/dialogs/theme_preview_dialog.dart';
import '../widgets/dialogs/decoration_preview_dialog.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/modern_hud_theme.dart';
import 'item_shop_screen.dart';

/// v1.2.0 Modern HUD 风格商店页面
/// 使用网格布局和 ItemCard 组件
class ShopScreenV12 extends ConsumerStatefulWidget {
  const ShopScreenV12({super.key});

  @override
  ConsumerState<ShopScreenV12> createState() => _ShopScreenV12State();
}

class _ShopScreenV12State extends ConsumerState<ShopScreenV12> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(adventurerProfileProvider);
    final inventory = ref.watch(inventoryProvider);
    final shopRepo = ref.watch(shopRepositoryProvider);
    final brightness = Theme.of(context).brightness;

    // 获取商品列表
    final items = _getFilteredItems(shopRepo);

    return Scaffold(
      backgroundColor: AppColors.getBackground(brightness),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '商店',
          style: AppTextStyles.headline3(brightness),
        ),
        backgroundColor: AppColors.getPrimary(brightness),
        foregroundColor: Colors.white,
        actions: [
          // 金币显示
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(
              horizontal: ModernHudTheme.spacingM,
              vertical: ModernHudTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on,
                    color: AppColors.accent, size: 20),
                const SizedBox(width: 4),
                Text(
                  _formatGold(profile.gold),
                  style: AppTextStyles.goldAmount(brightness).copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 分类导航
          _buildCategoryNav(brightness),

          // 商品网格
          Expanded(
            child: items.isEmpty
                ? _buildEmptyState(brightness)
                : _buildItemGrid(items, inventory, profile, brightness),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryNav(Brightness brightness) {
    final categories = [
      {'id': 'all', 'name': '全部', 'icon': Icons.store},
      {'id': 'theme', 'name': '主题', 'icon': Icons.palette},
      {'id': 'decoration', 'name': '装饰', 'icon': Icons.emoji_objects},
      {'id': 'item', 'name': '道具', 'icon': Icons.card_giftcard},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: ModernHudTheme.spacingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(brightness),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(brightness).withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: ModernHudTheme.spacingM,
        ),
        child: Row(
          children: categories.map((category) {
            final isSelected = _selectedCategory == category['id'];
            return Padding(
              padding: const EdgeInsets.only(right: ModernHudTheme.spacingS),
              child: _buildCategoryChip(
                category['name'] as String,
                category['icon'] as IconData,
                isSelected,
                () => setState(
                    () => _selectedCategory = category['id'] as String),
                brightness,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    Brightness brightness,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: ModernHudTheme.spacingM,
          vertical: ModernHudTheme.spacingS,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.getPrimaryGradient() : null,
          color: isSelected
              ? null
              : AppColors.getPrimary(brightness).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.getPrimary(brightness).withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isSelected ? Colors.white : AppColors.getPrimary(brightness),
              size: 20,
            ),
            const SizedBox(width: ModernHudTheme.spacingS),
            Text(
              label,
              style: AppTextStyles.labelLarge(brightness).copyWith(
                color: isSelected
                    ? Colors.white
                    : AppColors.getPrimary(brightness),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemGrid(
    List<ShopItem> items,
    inventory,
    profile,
    Brightness brightness,
  ) {
    // 响应式列数
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return GridView.builder(
      padding: const EdgeInsets.all(ModernHudTheme.spacingL),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: ModernHudTheme.spacingM,
        mainAxisSpacing: ModernHudTheme.spacingM,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isConsumable = item.type == 'ticket' || item.type == 'boost';
        final owned = inventory.hasItem(item.id);
        final count = inventory.getConsumableCount(item.id);
        final isEquipped = _isItemEquipped(item, inventory);

        return ItemCard(
          emoji: item.icon,
          name: item.name,
          price: item.price,
          isOwned: owned || (isConsumable && count > 0),
          isEquipped: isEquipped,
          onTap: () => _showItemDetails(item, owned, count, profile),
        );
      },
    );
  }

  Widget _buildEmptyState(Brightness brightness) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: ModernHudTheme.spacingM),
          Text(
            '暂无商品',
            style: AppTextStyles.headline4(brightness).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(
    ShopItem item,
    bool owned,
    int count,
    profile,
  ) {
    // 主题类型使用专门的预览对话框
    if (item.type == 'theme') {
      _showThemePreview(item, owned, profile);
      return;
    }

    // 装饰品类型使用专门的预览对话框
    if (item.type == 'decoration') {
      _showDecorationPreview(item, owned, profile);
      return;
    }

    final isConsumable = item.type == 'ticket' || item.type == 'boost';
    final canAfford = profile.canAfford(item.price);
    final brightness = Theme.of(context).brightness;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(ModernHudTheme.cardBorderRadius.topLeft.x),
        ),
        title: Row(
          children: [
            Text(item.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: ModernHudTheme.spacingM),
            Expanded(
              child: Text(
                item.name,
                style: AppTextStyles.headline4(brightness),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 描述
            Text(
              item.description,
              style: AppTextStyles.bodyMedium(brightness),
            ),

            const SizedBox(height: ModernHudTheme.spacingL),

            // 价格卡片
            Container(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '价格',
                    style: AppTextStyles.labelLarge(brightness),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.price}',
                        style: AppTextStyles.goldAmount(brightness),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 拥有数量（消耗品）
            if (isConsumable && count > 0) ...[
              const SizedBox(height: ModernHudTheme.spacingM),
              Container(
                padding: const EdgeInsets.all(ModernHudTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2, size: 16),
                    const SizedBox(width: ModernHudTheme.spacingS),
                    Text(
                      '当前拥有：$count 个',
                      style: AppTextStyles.labelMedium(brightness),
                    ),
                  ],
                ),
              ),
            ],

            // 金币不足提示
            if (!canAfford) ...[
              const SizedBox(height: ModernHudTheme.spacingM),
              Container(
                padding: const EdgeInsets.all(ModernHudTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_rounded,
                      color: AppColors.error,
                      size: 16,
                    ),
                    const SizedBox(width: ModernHudTheme.spacingS),
                    Text(
                      '金币不足',
                      style: AppTextStyles.statusError(brightness),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          if (!owned || isConsumable)
            ActionButton(
              text: '购买',
              icon: Icons.shopping_cart,
              type: ActionButtonType.gold,
              onPressed:
                  canAfford ? () => _purchaseItem(item, isConsumable) : null,
            ),
        ],
      ),
    );
  }

  Future<void> _purchaseItem(ShopItem item, bool isConsumable) async {
    try {
      final profile = ref.read(adventurerProfileProvider);

      // 扣除金币
      final updatedProfile = profile.spendGold(item.price);
      ref
          .read(adventurerProfileProvider.notifier)
          .updateProfile(updatedProfile);

      // 添加到库存
      await ref
          .read(inventoryProvider.notifier)
          .purchaseItem(item.id, item.price, isConsumable: isConsumable);

      // 播放购买音效
      final audioService = ref.read(audioServiceProvider);
      await audioService.playPurchase();

      if (mounted) {
        Navigator.pop(context);

        // 显示金币飘字动画
        FloatingTextManager.show(
          context,
          text: '-${item.price} 💰',
          type: FloatingTextType.gold,
        );

        // 延迟显示成功提示
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Text(item.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text('成功购买 ${item.name}！'),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('购买失败：$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  List<ShopItem> _getFilteredItems(shopRepo) {
    switch (_selectedCategory) {
      case 'all':
        return shopRepo.getAllItems();
      case 'theme':
        return shopRepo.getItemsByType('theme');
      case 'decoration':
        return shopRepo.getItemsByType('decoration');
      case 'item':
        // 道具分类：跳转到道具商店页面
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ItemShopScreen()),
            );
            // 重置分类为全部
            setState(() => _selectedCategory = 'all');
          }
        });
        return shopRepo.getAllItems();
      default:
        return shopRepo.getAllItems();
    }
  }

  bool _isItemEquipped(ShopItem item, inventory) {
    if (item.type == 'theme') {
      return inventory.activeTheme == item.id;
    } else if (item.type == 'decoration') {
      return inventory.isDecorationActive(item.id);
    }
    return false;
  }

  String _formatGold(int gold) {
    if (gold >= 1000000) {
      return '${(gold / 1000000).toStringAsFixed(1)}M';
    } else if (gold >= 1000) {
      return '${(gold / 1000).toStringAsFixed(1)}K';
    }
    return gold.toString();
  }

  void _showThemePreview(ShopItem theme, bool owned, profile) {
    final inventory = ref.read(inventoryProvider);
    final isActive = inventory.activeTheme == theme.id;

    showDialog(
      context: context,
      builder: (context) => ThemePreviewDialog(
        theme: theme,
        isOwned: owned,
        isActive: isActive,
        currentGold: profile.gold,
        onPurchase: () => _purchaseTheme(theme),
        onActivate: () => _activateTheme(theme.id),
      ),
    );
  }

  Future<void> _purchaseTheme(ShopItem theme) async {
    try {
      final profile = ref.read(adventurerProfileProvider);

      // 扣除金币
      final updatedProfile = profile.spendGold(theme.price);
      ref
          .read(adventurerProfileProvider.notifier)
          .updateProfile(updatedProfile);

      // 添加到库存
      await ref.read(inventoryProvider.notifier).purchaseItem(
            theme.id,
            theme.price,
            isConsumable: false,
          );

      // 播放购买音效
      final audioService = ref.read(audioServiceProvider);
      await audioService.playPurchase();

      if (mounted) {
        Navigator.pop(context);

        // 显示金币飘字动画
        FloatingTextManager.show(
          context,
          text: '-${theme.price} 💰',
          type: FloatingTextType.gold,
        );

        // 延迟显示成功提示
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Text(theme.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text('成功购买 ${theme.name}！'),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );

            // 询问是否立即应用
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                _showApplyThemeDialog(theme.id);
              }
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('购买失败：$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _activateTheme(String themeId) async {
    try {
      await ref.read(inventoryProvider.notifier).activateTheme(themeId);

      if (mounted) {
        Navigator.pop(context);

        // 显示成功提示
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
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('应用主题失败：$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showApplyThemeDialog(String themeId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('应用主题'),
        content: const Text('是否立即应用新购买的主题？\n（重启应用后生效）'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('稍后'),
          ),
          ActionButton(
            text: '立即应用',
            icon: Icons.check,
            type: ActionButtonType.primary,
            onPressed: () {
              Navigator.pop(context);
              _activateTheme(themeId);
            },
          ),
        ],
      ),
    );
  }

  void _showDecorationPreview(ShopItem decoration, bool owned, profile) {
    final inventory = ref.read(inventoryProvider);
    final isActive = inventory.isDecorationActive(decoration.id);

    showDialog(
      context: context,
      builder: (context) => DecorationPreviewDialog(
        decoration: decoration,
        isOwned: owned,
        isActive: isActive,
        currentGold: profile.gold,
        onPurchase: () => _purchaseDecoration(decoration),
        onToggle: () => _toggleDecoration(decoration.id, isActive),
      ),
    );
  }

  Future<void> _purchaseDecoration(ShopItem decoration) async {
    try {
      final profile = ref.read(adventurerProfileProvider);

      // 扣除金币
      final updatedProfile = profile.spendGold(decoration.price);
      ref
          .read(adventurerProfileProvider.notifier)
          .updateProfile(updatedProfile);

      // 添加到库存
      await ref.read(inventoryProvider.notifier).purchaseItem(
            decoration.id,
            decoration.price,
            isConsumable: false,
          );

      // 播放购买音效
      final audioService = ref.read(audioServiceProvider);
      await audioService.playPurchase();

      if (mounted) {
        Navigator.pop(context);

        // 显示金币飘字动画
        FloatingTextManager.show(
          context,
          text: '-${decoration.price} 💰',
          type: FloatingTextType.gold,
        );

        // 延迟显示成功提示
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Text(decoration.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text('成功购买 ${decoration.name}！'),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );

            // 询问是否立即激活
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                _showActivateDecorationDialog(decoration.id);
              }
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('购买失败：$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleDecoration(String decorationId, bool isActive) async {
    try {
      await ref.read(inventoryProvider.notifier).toggleDecoration(decorationId);

      if (mounted) {
        Navigator.pop(context);

        // 显示成功提示
        FloatingTextManager.show(
          context,
          text: isActive ? '✓ 已停用' : '✓ 已激活',
          type: FloatingTextType.exp,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败：$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showActivateDecorationDialog(String decorationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('激活装饰品'),
        content: const Text('是否立即激活新购买的装饰品？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('稍后'),
          ),
          ActionButton(
            text: '立即激活',
            icon: Icons.check,
            type: ActionButtonType.primary,
            onPressed: () {
              Navigator.pop(context);
              _toggleDecoration(decorationId, false);
            },
          ),
        ],
      ),
    );
  }
}
