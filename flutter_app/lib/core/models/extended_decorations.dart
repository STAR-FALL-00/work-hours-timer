/// 扩展装饰品集合
///
/// 新增装饰品：
/// - 相框
/// - 音响
/// - 书架
/// - 大型植物
/// - 挂钟
/// - 显示器
class ExtendedDecorations {
  /// 获取所有扩展装饰品
  static List<DecorationInfo> getAllDecorations() {
    return [
      // 相框
      DecorationInfo(
        id: 'decoration_photo_frame',
        name: '相框',
        icon: '🖼️',
        description: '桌面装饰：精美相框',
        price: 1800,
        rarity: 'common',
        category: 'desk',
      ),

      // 音响
      DecorationInfo(
        id: 'decoration_speaker',
        name: '音响',
        icon: '🎵',
        description: '桌面装饰：高品质音响',
        price: 3500,
        rarity: 'rare',
        category: 'desk',
      ),

      // 书架
      DecorationInfo(
        id: 'decoration_bookshelf',
        name: '书架',
        icon: '📚',
        description: '房间装饰：实木书架',
        price: 4500,
        rarity: 'rare',
        category: 'room',
      ),

      // 大型植物
      DecorationInfo(
        id: 'decoration_large_plant',
        name: '大型植物',
        icon: '🪴',
        description: '房间装饰：大型观叶植物',
        price: 3000,
        rarity: 'rare',
        category: 'room',
      ),

      // 挂钟
      DecorationInfo(
        id: 'decoration_wall_clock',
        name: '挂钟',
        icon: '🕰️',
        description: '墙面装饰：复古挂钟',
        price: 2200,
        rarity: 'common',
        category: 'wall',
      ),

      // 显示器
      DecorationInfo(
        id: 'decoration_monitor',
        name: '显示器',
        icon: '🖥️',
        description: '桌面装饰：专业显示器',
        price: 5000,
        rarity: 'epic',
        category: 'desk',
      ),

      // 台灯（高级版）
      DecorationInfo(
        id: 'decoration_desk_lamp_pro',
        name: '智能台灯',
        icon: '💡',
        description: '桌面装饰：智能调光台灯',
        price: 3500,
        rarity: 'rare',
        category: 'desk',
      ),

      // 地毯
      DecorationInfo(
        id: 'decoration_carpet',
        name: '地毯',
        icon: '🧶',
        description: '地面装饰：舒适地毯',
        price: 2800,
        rarity: 'common',
        category: 'floor',
      ),
    ];
  }
}

/// 装饰品信息
class DecorationInfo {
  final String id;
  final String name;
  final String icon;
  final String description;
  final int price;
  final String rarity;
  final String category;

  DecorationInfo({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.price,
    required this.rarity,
    required this.category,
  });
}
