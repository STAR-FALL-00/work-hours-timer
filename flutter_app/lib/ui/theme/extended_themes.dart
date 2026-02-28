import 'package:flutter/material.dart';

/// 扩展主题集合
///
/// 新增主题：
/// - 樱花粉主题
/// - 活力橙主题
/// - 森林绿主题
/// - 极简黑主题
/// - 薰衣草紫主题
/// - 天空蓝主题
/// - 日落红主题
/// - 薄荷绿主题
class ExtendedThemes {
  /// 樱花粉主题
  static ThemeData sakuraPink = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFFB7C5),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFFFFB7C5),
      secondary: const Color(0xFFFF69B4),
      surface: const Color(0xFFFFF0F5),
      error: const Color(0xFFFF1744),
    ),
    scaffoldBackgroundColor: const Color(0xFFFFF5F7),
  );

  /// 活力橙主题
  static ThemeData vibrantOrange = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF6B35),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFFFF6B35),
      secondary: const Color(0xFFFF9F1C),
      surface: const Color(0xFFFFF8F0),
      error: const Color(0xFFD32F2F),
    ),
    scaffoldBackgroundColor: const Color(0xFFFFFAF5),
  );

  /// 森林绿主题
  static ThemeData forestGreen = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2D6A4F),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF2D6A4F),
      secondary: const Color(0xFF52B788),
      surface: const Color(0xFFF1F8F4),
      error: const Color(0xFFD32F2F),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5FBF7),
  );

  /// 极简黑主题
  static ThemeData minimalistBlack = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1A1A1A),
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF1A1A1A),
      secondary: const Color(0xFF404040),
      surface: const Color(0xFF2A2A2A),
      error: const Color(0xFFFF5252),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
  );

  /// 薰衣草紫主题
  static ThemeData lavenderPurple = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF9D84B7),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF9D84B7),
      secondary: const Color(0xFFB8A9C9),
      surface: const Color(0xFFF5F3F7),
      error: const Color(0xFFD32F2F),
    ),
    scaffoldBackgroundColor: const Color(0xFFFAF8FC),
  );

  /// 天空蓝主题
  static ThemeData skyBlue = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF87CEEB),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF87CEEB),
      secondary: const Color(0xFF4FC3F7),
      surface: const Color(0xFFF0F8FF),
      error: const Color(0xFFD32F2F),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5FAFF),
  );

  /// 日落红主题
  static ThemeData sunsetRed = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF6B6B),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFFFF6B6B),
      secondary: const Color(0xFFFF8E53),
      surface: const Color(0xFFFFF5F5),
      error: const Color(0xFFD32F2F),
    ),
    scaffoldBackgroundColor: const Color(0xFFFFFAFA),
  );

  /// 薄荷绿主题
  static ThemeData mintGreen = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF98D8C8),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF98D8C8),
      secondary: const Color(0xFF6BCF9F),
      surface: const Color(0xFFF0FAF7),
      error: const Color(0xFFD32F2F),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5FBF9),
  );

  /// 获取所有扩展主题
  static Map<String, ThemeData> getAllThemes() {
    return {
      'sakura_pink': sakuraPink,
      'vibrant_orange': vibrantOrange,
      'forest_green': forestGreen,
      'minimalist_black': minimalistBlack,
      'lavender_purple': lavenderPurple,
      'sky_blue': skyBlue,
      'sunset_red': sunsetRed,
      'mint_green': mintGreen,
    };
  }

  /// 获取主题信息
  static Map<String, ThemeInfo> getThemeInfos() {
    return {
      'sakura_pink': ThemeInfo(
        id: 'sakura_pink',
        name: '樱花粉',
        icon: '🌸',
        description: '温柔浪漫的樱花粉色主题',
        primaryColor: const Color(0xFFFFB7C5),
        price: 5000,
        rarity: 'rare',
      ),
      'vibrant_orange': ThemeInfo(
        id: 'vibrant_orange',
        name: '活力橙',
        icon: '🍊',
        description: '充满活力的橙色主题',
        primaryColor: const Color(0xFFFF6B35),
        price: 5000,
        rarity: 'rare',
      ),
      'forest_green': ThemeInfo(
        id: 'forest_green',
        name: '森林绿',
        icon: '🌲',
        description: '清新自然的森林绿主题',
        primaryColor: const Color(0xFF2D6A4F),
        price: 5000,
        rarity: 'rare',
      ),
      'minimalist_black': ThemeInfo(
        id: 'minimalist_black',
        name: '极简黑',
        icon: '⚫',
        description: '简约优雅的黑色主题',
        primaryColor: const Color(0xFF1A1A1A),
        price: 8000,
        rarity: 'epic',
      ),
      'lavender_purple': ThemeInfo(
        id: 'lavender_purple',
        name: '薰衣草紫',
        icon: '💜',
        description: '优雅梦幻的紫色主题',
        primaryColor: const Color(0xFF9D84B7),
        price: 5000,
        rarity: 'rare',
      ),
      'sky_blue': ThemeInfo(
        id: 'sky_blue',
        name: '天空蓝',
        icon: '☁️',
        description: '清爽明亮的天空蓝主题',
        primaryColor: const Color(0xFF87CEEB),
        price: 5000,
        rarity: 'rare',
      ),
      'sunset_red': ThemeInfo(
        id: 'sunset_red',
        name: '日落红',
        icon: '🌅',
        description: '温暖浪漫的日落红主题',
        primaryColor: const Color(0xFFFF6B6B),
        price: 5000,
        rarity: 'rare',
      ),
      'mint_green': ThemeInfo(
        id: 'mint_green',
        name: '薄荷绿',
        icon: '🍃',
        description: '清新舒适的薄荷绿主题',
        primaryColor: const Color(0xFF98D8C8),
        price: 5000,
        rarity: 'rare',
      ),
    };
  }
}

/// 主题信息
class ThemeInfo {
  final String id;
  final String name;
  final String icon;
  final String description;
  final Color primaryColor;
  final int price;
  final String rarity;

  ThemeInfo({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.primaryColor,
    required this.price,
    required this.rarity,
  });

  /// 获取稀有度颜色
  Color get rarityColor {
    switch (rarity) {
      case 'rare':
        return const Color(0xFF3B82F6); // 蓝色
      case 'epic':
        return const Color(0xFFA855F7); // 紫色
      case 'legendary':
        return const Color(0xFFF59E0B); // 金色
      default:
        return const Color(0xFF6B7280); // 灰色
    }
  }

  /// 获取稀有度名称
  String get rarityName {
    switch (rarity) {
      case 'rare':
        return '稀有';
      case 'epic':
        return '史诗';
      case 'legendary':
        return '传说';
      default:
        return '普通';
    }
  }
}

/// 主题管理器
class ThemeManager {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  String _currentThemeId = 'default';
  final Set<String> _ownedThemes = {'default'};

  /// 获取当前主题ID
  String get currentThemeId => _currentThemeId;

  /// 获取已拥有的主题
  Set<String> get ownedThemes => Set.from(_ownedThemes);

  /// 设置当前主题
  Future<void> setTheme(String themeId) async {
    if (!_ownedThemes.contains(themeId)) {
      throw Exception('主题未拥有');
    }

    _currentThemeId = themeId;
    // TODO: 保存到本地存储
    print('✅ 主题已切换: $themeId');
  }

  /// 购买主题
  Future<void> purchaseTheme(String themeId, int currentGold) async {
    final themeInfo = ExtendedThemes.getThemeInfos()[themeId];
    if (themeInfo == null) {
      throw Exception('主题不存在');
    }

    if (currentGold < themeInfo.price) {
      throw Exception('金币不足');
    }

    if (_ownedThemes.contains(themeId)) {
      throw Exception('已拥有该主题');
    }

    _ownedThemes.add(themeId);
    // TODO: 保存到本地存储
    print('✅ 主题已购买: $themeId');
  }

  /// 检查是否拥有主题
  bool ownsTheme(String themeId) {
    return _ownedThemes.contains(themeId);
  }

  /// 获取主题数据
  ThemeData? getThemeData(String themeId) {
    return ExtendedThemes.getAllThemes()[themeId];
  }

  /// 初始化
  Future<void> init() async {
    // TODO: 从本地存储加载
    print('✅ 主题管理器已初始化');
  }
}
