import 'package:hive/hive.dart';

part 'shop_item.g.dart';

@HiveType(typeId: 5)
class ShopItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String type; // 'theme', 'ticket', 'decoration', 'boost'

  @HiveField(4)
  final int price;

  @HiveField(5)
  final String icon;

  @HiveField(6)
  final Map<String, dynamic>? data;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    required this.icon,
    this.data,
  });

  // 预定义商品
  static final List<ShopItem> defaultItems = [
    ShopItem(
      id: 'theme_cyberpunk',
      name: '赛博朋克主题',
      description: '炫酷的紫色霓虹主题',
      type: 'theme',
      price: 5000,
      icon: '🌃',
      data: {'primaryColor': '0xFF9C27B0'},
    ),
    ShopItem(
      id: 'theme_matrix',
      name: '黑客帝国主题',
      description: '经典的绿色矩阵主题',
      type: 'theme',
      price: 5000,
      icon: '💚',
      data: {'primaryColor': '0xFF4CAF50'},
    ),
    ShopItem(
      id: 'theme_ocean',
      name: '深海主题',
      description: '宁静的蓝色海洋主题',
      type: 'theme',
      price: 5000,
      icon: '🌊',
      data: {'primaryColor': '0xFF2196F3'},
    ),
    ShopItem(
      id: 'theme_sunset',
      name: '日落主题',
      description: '温暖的橙色日落主题',
      type: 'theme',
      price: 5000,
      icon: '🌅',
      data: {'primaryColor': '0xFFFF9800'},
    ),
    ShopItem(
      id: 'ticket_restore',
      name: '免签卡',
      description: '恢复一天的连续签到',
      type: 'ticket',
      price: 1000,
      icon: '🎫',
    ),
    ShopItem(
      id: 'decoration_keyboard',
      name: '机械键盘',
      description: '桌面装饰：机械键盘',
      type: 'decoration',
      price: 2000,
      icon: '⌨️',
    ),
    ShopItem(
      id: 'decoration_coffee',
      name: '咖啡机',
      description: '桌面装饰：咖啡机',
      type: 'decoration',
      price: 3000,
      icon: '☕',
    ),
    ShopItem(
      id: 'decoration_plant',
      name: '绿植',
      description: '桌面装饰：小盆栽',
      type: 'decoration',
      price: 1500,
      icon: '🌱',
    ),
    ShopItem(
      id: 'decoration_lamp',
      name: '台灯',
      description: '桌面装饰：护眼台灯',
      type: 'decoration',
      price: 2500,
      icon: '💡',
    ),
    ShopItem(
      id: 'boost_exp_2x',
      name: '经验加倍卡',
      description: '1小时内经验获取翻倍',
      type: 'boost',
      price: 500,
      icon: '⚡',
      data: {'duration': 60, 'multiplier': 2.0},
    ),
    ShopItem(
      id: 'boost_gold_2x',
      name: '金币加倍卡',
      description: '1小时内金币获取翻倍',
      type: 'boost',
      price: 500,
      icon: '💰',
      data: {'duration': 60, 'multiplier': 2.0},
    ),
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'price': price,
      'icon': icon,
      'data': data,
    };
  }

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      price: json['price'],
      icon: json['icon'],
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}
