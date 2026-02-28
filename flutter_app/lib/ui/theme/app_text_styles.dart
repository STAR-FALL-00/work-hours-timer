import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Modern HUD 文本样式
/// v1.2.0 UI Redesign
class AppTextStyles {
  // 防止实例化
  AppTextStyles._();

  // ==================== 标题样式 ====================

  /// 超大标题 - 用于欢迎页、空状态
  static TextStyle headline1(Brightness brightness) => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.getTextPrimary(brightness),
        letterSpacing: -0.5,
      );

  /// 大标题 - 用于页面标题
  static TextStyle headline2(Brightness brightness) => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.getTextPrimary(brightness),
        letterSpacing: -0.3,
      );

  /// 中标题 - 用于卡片标题
  static TextStyle headline3(Brightness brightness) => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.getTextPrimary(brightness),
      );

  /// 小标题 - 用于列表项标题
  static TextStyle headline4(Brightness brightness) => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.getTextPrimary(brightness),
      );

  /// 迷你标题 - 用于小组件标题
  static TextStyle headline5(Brightness brightness) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.getTextPrimary(brightness),
      );

  // ==================== 正文样式 ====================

  /// 正文 - 大号
  static TextStyle bodyLarge(Brightness brightness) => GoogleFonts.notoSans(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.getTextPrimary(brightness),
        height: 1.5,
      );

  /// 正文 - 中号（默认）
  static TextStyle bodyMedium(Brightness brightness) => GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.getTextPrimary(brightness),
        height: 1.5,
      );

  /// 正文 - 小号
  static TextStyle bodySmall(Brightness brightness) => GoogleFonts.notoSans(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // ==================== 按钮样式 ====================

  /// 按钮文字 - 大号
  static TextStyle buttonLarge(Brightness brightness) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      );

  /// 按钮文字 - 中号
  static TextStyle buttonMedium(Brightness brightness) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.3,
      );

  /// 按钮文字 - 小号
  static TextStyle buttonSmall(Brightness brightness) => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  // ==================== 特殊样式 ====================

  /// 计时器数字 - 超大号
  static TextStyle timerLarge(Brightness brightness) => GoogleFonts.robotoMono(
        fontSize: 64,
        fontWeight: FontWeight.w600,
        color: AppColors.getTextPrimary(brightness),
        letterSpacing: 4,
        height: 1.0,
      );

  /// 计时器数字 - 中号
  static TextStyle timerMedium(Brightness brightness) => GoogleFonts.robotoMono(
        fontSize: 48,
        fontWeight: FontWeight.w600,
        color: AppColors.getTextPrimary(brightness),
        letterSpacing: 3,
        height: 1.0,
      );

  /// 计时器数字 - 小号
  static TextStyle timerSmall(Brightness brightness) => GoogleFonts.robotoMono(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppColors.getTextPrimary(brightness),
        letterSpacing: 2,
        height: 1.0,
      );

  /// 金币数字
  static TextStyle goldAmount(Brightness brightness) => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.accent,
        letterSpacing: 0.5,
      );

  /// 经验值数字
  static TextStyle expAmount(Brightness brightness) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.expBar,
      );

  /// 等级数字
  static TextStyle levelNumber(Brightness brightness) => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.getPrimary(brightness),
      );

  /// 称号文字
  static TextStyle titleText(Brightness brightness) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      );

  // ==================== 标签样式 ====================

  /// 标签 - 大号
  static TextStyle labelLarge(Brightness brightness) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  /// 标签 - 中号
  static TextStyle labelMedium(Brightness brightness) => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  /// 标签 - 小号
  static TextStyle labelSmall(Brightness brightness) => GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
      );

  // ==================== 状态文字样式 ====================

  /// 战斗中状态
  static TextStyle statusCombat(Brightness brightness) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.combat,
      );

  /// 休息中状态
  static TextStyle statusRest(Brightness brightness) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.rest,
      );

  /// 成功状态
  static TextStyle statusSuccess(Brightness brightness) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.success,
      );

  /// 警告状态
  static TextStyle statusWarning(Brightness brightness) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.warning,
      );

  /// 错误状态
  static TextStyle statusError(Brightness brightness) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.error,
      );

  // ==================== 飘字动画样式 ====================

  /// 金币飘字
  static TextStyle floatingGold() => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.accent,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      );

  /// 经验值飘字
  static TextStyle floatingExp() => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.expBar,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      );

  /// 升级飘字
  static TextStyle floatingLevelUp() => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.accent,
        shadows: [
          Shadow(
            color: AppColors.accent.withOpacity(0.5),
            offset: const Offset(0, 0),
            blurRadius: 20,
          ),
        ],
      );

  // ==================== 辅助方法 ====================

  /// 获取带颜色的文本样式
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// 获取加粗的文本样式
  static TextStyle withBold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.bold);
  }

  /// 获取斜体的文本样式
  static TextStyle withItalic(TextStyle style) {
    return style.copyWith(fontStyle: FontStyle.italic);
  }

  /// 获取带下划线的文本样式
  static TextStyle withUnderline(TextStyle style) {
    return style.copyWith(decoration: TextDecoration.underline);
  }
}
