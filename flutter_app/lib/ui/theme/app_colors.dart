import 'package:flutter/material.dart';

/// Modern HUD 配色方案
/// v1.2.0 UI Redesign
class AppColors {
  // 防止实例化
  AppColors._();

  // ==================== 主色调 (Primary) ====================
  /// Deep Indigo - 导航栏、主按钮、进度条
  static const primaryLight = Color(0xFF4F46E5);
  static const primaryDark = Color(0xFF6366F1);

  // 主色调变体
  static const primary50 = Color(0xFFEEF2FF);
  static const primary100 = Color(0xFFE0E7FF);
  static const primary200 = Color(0xFFC7D2FE);
  static const primary300 = Color(0xFFA5B4FC);
  static const primary400 = Color(0xFF818CF8);
  static const primary500 = Color(0xFF6366F1);
  static const primary600 = Color(0xFF4F46E5);
  static const primary700 = Color(0xFF4338CA);
  static const primary800 = Color(0xFF3730A3);
  static const primary900 = Color(0xFF312E81);

  // ==================== 背景色 (Background) ====================
  /// Off-White / Gunmetal
  static const backgroundLight = Color(0xFFF3F4F6);
  static const backgroundDark = Color(0xFF111827);

  // 背景色变体
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF1F2937);

  // ==================== 强调色 (Accent) ====================
  /// Amber - 金币、经验值、商店价格
  static const accent = Color(0xFFF59E0B);
  static const accentLight = Color(0xFFFBBF24);
  static const accentDark = Color(0xFFD97706);

  // 金币专用渐变色
  static const goldGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== 功能色 ====================
  /// 战斗/计时 - Coral Red
  static const combat = Color(0xFFEF4444);
  static const combatLight = Color(0xFFF87171);
  static const combatDark = Color(0xFFDC2626);

  /// 休息/恢复 - Emerald Green
  static const rest = Color(0xFF10B981);
  static const restLight = Color(0xFF34D399);
  static const restDark = Color(0xFF059669);

  // ==================== 卡片背景 ====================
  static const cardBackground = Color(0xFFFFFFFF);
  static const cardBackgroundDark = Color(0xFF1F2937);

  // ==================== 文本颜色 ====================
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);

  static const textPrimaryDark = Color(0xFFF9FAFB);
  static const textSecondaryDark = Color(0xFFD1D5DB);
  static const textTertiaryDark = Color(0xFF9CA3AF);

  // ==================== 边框颜色 ====================
  static const border = Color(0xFFE5E7EB);
  static const borderDark = Color(0xFF374151);

  // ==================== 阴影颜色 ====================
  static Color shadowLight = Colors.black.withOpacity(0.05);
  static Color shadowDark = Colors.black.withOpacity(0.3);

  // ==================== 状态颜色 ====================
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // ==================== BOSS 血条颜色 ====================
  static const bossHealthHigh = Color(0xFF10B981); // > 50%
  static const bossHealthMedium = Color(0xFFF59E0B); // 20-50%
  static const bossHealthLow = Color(0xFFEF4444); // < 20%

  // ==================== 经验值颜色 ====================
  static const expBar = Color(0xFF8B5CF6); // Purple
  static const expBarLight = Color(0xFFA78BFA);
  static const expBarDark = Color(0xFF7C3AED);

  // ==================== 辅助方法 ====================

  /// 根据亮度模式获取主色调
  static Color getPrimary(Brightness brightness) {
    return brightness == Brightness.light ? primaryLight : primaryDark;
  }

  /// 根据亮度模式获取背景色
  static Color getBackground(Brightness brightness) {
    return brightness == Brightness.light ? backgroundLight : backgroundDark;
  }

  /// 根据亮度模式获取卡片背景色
  static Color getCardBackground(Brightness brightness) {
    return brightness == Brightness.light ? cardBackground : cardBackgroundDark;
  }

  /// 根据亮度模式获取文本颜色
  static Color getTextPrimary(Brightness brightness) {
    return brightness == Brightness.light ? textPrimary : textPrimaryDark;
  }

  /// 根据亮度模式获取阴影颜色
  static Color getShadow(Brightness brightness) {
    return brightness == Brightness.light ? shadowLight : shadowDark;
  }

  /// 根据血量百分比获取 BOSS 血条颜色
  static Color getBossHealthColor(double percentage) {
    if (percentage > 0.5) {
      return bossHealthHigh;
    } else if (percentage > 0.2) {
      return bossHealthMedium;
    } else {
      return bossHealthLow;
    }
  }

  /// 获取渐变背景（用于按钮等）
  static LinearGradient getPrimaryGradient() {
    return const LinearGradient(
      colors: [primary500, primary600, primary700],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// 获取战斗状态渐变
  static LinearGradient getCombatGradient() {
    return const LinearGradient(
      colors: [combatLight, combat, combatDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// 获取休息状态渐变
  static LinearGradient getRestGradient() {
    return const LinearGradient(
      colors: [restLight, rest, restDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
