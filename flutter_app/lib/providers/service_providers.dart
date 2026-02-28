import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/item_service.dart';
import '../core/services/export_service.dart';
import '../core/services/dark_mode_service.dart';
import '../core/services/floating_window_service.dart';
import '../core/models/item.dart';
import '../ui/theme/extended_themes.dart';

/// 道具服务 Provider
final itemServiceProvider = Provider<ItemService>((ref) {
  return ItemService();
});

/// 导出服务 Provider
final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});

/// 暗色模式服务 Provider
final darkModeServiceProvider = Provider<DarkModeService>((ref) {
  return DarkModeService();
});

/// 悬浮窗服务 Provider
final floatingWindowServiceProvider = Provider<FloatingWindowService>((ref) {
  return FloatingWindowService();
});

/// 主题管理器 Provider
final themeManagerProvider = Provider<ThemeManager>((ref) {
  return ThemeManager();
});

/// 激活的道具效果 Provider
final activeItemEffectsProvider =
    Provider<Map<ItemEffectType, ItemInstance>>((ref) {
  final itemService = ref.watch(itemServiceProvider);
  return itemService.getActiveEffects();
});
