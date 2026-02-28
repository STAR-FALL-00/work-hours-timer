import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/shop_item.dart';
import '../../providers/providers.dart';
import '../../core/services/economy_service.dart';

/// 商店页面
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(adventurerProfileProvider);
    final inventory = ref.watch(inventoryProvider);
    final shopRepo = ref.watch(shopRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('商店'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    EconomyService.formatGold(profile.gold),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '全部', icon: Icon(Icons.store)),
            Tab(text: '主题', icon: Icon(Icons.palette)),
            Tab(text: '道具', icon: Icon(Icons.card_giftcard)),
            Tab(text: '装饰', icon: Icon(Icons.emoji_objects)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildItemGrid(shopRepo.getAllItems(), inventory, profile),
          _buildItemGrid(shopRepo.getItemsByType('theme'), inventory, profile),
          _buildItemGrid(
            [
              ...shopRepo.getItemsByType('ticket'),
              ...shopRepo.getItemsByType('boost'),
            ],
            inventory,
            profile,
          ),
          _buildItemGrid(
              shopRepo.getItemsByType('decoration'), inventory, profile),
        ],
      ),
    );
  }

  Widget _buildItemGrid(items, inventory, profile) {
    if (items.isEmpty) {
      return const Center(
        child: Text('暂无商品'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final owned = inventory.hasItem(item.id);
        final count = inventory.getConsumableCount(item.id);
        final canAfford = profile.canAfford(item.price);

        return _buildItemCard(item, owned, count, canAfford);
      },
    );
  }

  Widget _buildItemCard(ShopItem item, bool owned, int count, bool canAfford) {
    final isConsumable = item.type == 'ticket' || item.type == 'boost';

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showItemDetails(item, owned, count, canAfford),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getTypeColor(item.type).withOpacity(0.3),
                      _getTypeColor(item.type).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        item.icon,
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                    if (owned && !isConsumable)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    if (isConsumable && count > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'x$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.price}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: canAfford ? Colors.black87 : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      if (owned && !isConsumable)
                        const Text(
                          '已拥有',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDetails(ShopItem item, bool owned, int count, bool canAfford) {
    final isConsumable = item.type == 'ticket' || item.type == 'boost';

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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '价格',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on,
                          color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${item.price}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isConsumable && count > 0) ...[
              const SizedBox(height: 8),
              Text(
                '当前拥有：$count 个',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
            if (!canAfford) ...[
              const SizedBox(height: 8),
              const Text(
                '金币不足',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
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
            FilledButton(
              onPressed:
                  canAfford ? () => _purchaseItem(item, isConsumable) : null,
              child: const Text('购买'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('成功购买 ${item.name}！')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('购买失败：$e')),
        );
      }
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'theme':
        return Colors.purple;
      case 'ticket':
        return Colors.orange;
      case 'decoration':
        return Colors.green;
      case 'boost':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
