import 'package:flutter/material.dart';
import '../models/shop_item.dart';
import '../../ui/theme/app_colors.dart';

/// 主题服务
/// 负责主题的加载、应用和管理
class ThemeService {
  // 单例模式
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  /// 根据主题ID获取主题颜色
  Color getThemeColor(String? themeId) {
    if (themeId == null) return AppColors.primaryLight;

    final theme = ShopItem.defaultItems.firstWhere(
      (item) => item.id == themeId && item.type == 'theme',
      orElse: () => ShopItem.defaultItems.first,
    );

    if (theme.data != null && theme.data!.containsKey('primaryColor')) {
      final colorString = theme.data!['primaryColor'] as String;
      return Color(int.parse(colorString));
    }

    return AppColors.primaryLight;
  }

  /// 获取主题名称
  String getThemeName(String? themeId) {
    if (themeId == null) return '默认主题';

    final theme = ShopItem.defaultItems.firstWhere(
      (item) => item.id == themeId && item.type == 'theme',
      orElse: () => ShopItem(
        id: 'default',
        name: '默认主题',
        description: '',
        type: 'theme',
        price: 0,
        icon: '🎨',
      ),
    );

    return theme.name;
  }

  /// 获取主题图标
  String getThemeIcon(String? themeId) {
    if (themeId == null) return '🎨';

    final theme = ShopItem.defaultItems.firstWhere(
      (item) => item.id == themeId && item.type == 'theme',
      orElse: () => ShopItem(
        id: 'default',
        name: '默认主题',
        description: '',
        type: 'theme',
        price: 0,
        icon: '🎨',
      ),
    );

    return theme.icon;
  }

  /// 获取所有可用主题
  List<ShopItem> getAllThemes() {
    return ShopItem.defaultItems.where((item) => item.type == 'theme').toList();
  }

  /// 检查主题是否已解锁
  bool isThemeUnlocked(String themeId, List<String> ownedItemIds) {
    return ownedItemIds.contains(themeId);
  }

  /// 获取主题预览数据
  Map<String, dynamic> getThemePreviewData(String themeId) {
    final theme = ShopItem.defaultItems.firstWhere(
      (item) => item.id == themeId,
      orElse: () => ShopItem(
        id: 'default',
        name: '默认主题',
        description: '',
        type: 'theme',
        price: 0,
        icon: '🎨',
      ),
    );

    return {
      'id': theme.id,
      'name': theme.name,
      'description': theme.description,
      'icon': theme.icon,
      'price': theme.price,
      'color': getThemeColor(themeId),
      'features': _getThemeFeatures(themeId),
    };
  }

  List<String> _getThemeFeatures(String themeId) {
    switch (themeId) {
      case 'theme_cyberpunk':
        return [
          '紫色霓虹主色调',
          '未来科技感设计',
          '适合夜间使用',
          '高对比度界面',
        ];
      case 'theme_matrix':
        return [
          '经典绿色主色调',
          '黑客帝国风格',
          '护眼配色方案',
          '极客专属主题',
        ];
      case 'theme_ocean':
        return [
          '宁静蓝色主色调',
          '海洋风格设计',
          '舒缓视觉体验',
          '适合长时间工作',
        ];
      case 'theme_sunset':
        return [
          '温暖橙色主色调',
          '日落渐变效果',
          '温馨舒适氛围',
          '提升工作热情',
        ];
      default:
        return [
          '独特的配色方案',
          '精心设计的界面',
          '提升使用体验',
          '个性化定制',
        ];
    }
  }

  /// 应用主题（实际上只是保存选择，需要重启应用）
  /// 返回是否需要重启
  bool applyTheme(String themeId) {
    // 在实际应用中，这里会保存主题选择到本地存储
    // 并在下次启动时加载
    return true; // 需要重启
  }

  /// 获取主题的渐变色
  LinearGradient getThemeGradient(String? themeId) {
    final color = getThemeColor(themeId);
    return LinearGradient(
      colors: [
        color,
        color.withValues(alpha: 0.8),
        color.withValues(alpha: 0.6),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// 获取主题的浅色背景
  Color getThemeLightBackground(String? themeId) {
    final color = getThemeColor(themeId);
    return color.withValues(alpha: 0.1);
  }

  /// 获取主题的边框颜色
  Color getThemeBorderColor(String? themeId) {
    final color = getThemeColor(themeId);
    return color.withValues(alpha: 0.3);
  }
}
