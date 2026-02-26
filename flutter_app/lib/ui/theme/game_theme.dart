import 'package:flutter/material.dart';

class GameTheme {
  // 冒险者工会配色
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color darkBrown = Color(0xFF3E2723);
  static const Color lightBrown = Color(0xFF8D6E63);
  static const Color parchment = Color(0xFFFFF8DC);
  static const Color darkParchment = Color(0xFFE8DCC0);
  
  // 稀有度颜色
  static const Color common = Color(0xFF9E9E9E);
  static const Color uncommon = Color(0xFF4CAF50);
  static const Color rare = Color(0xFF2196F3);
  static const Color epic = Color(0xFF9C27B0);
  static const Color legendary = Color(0xFFFF9800);
  
  // 文字样式
  static const TextStyle titleStyle = TextStyle(
    fontFamily: 'serif',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: darkBrown,
    shadows: [
      Shadow(
        offset: Offset(1, 1),
        blurRadius: 2,
        color: Colors.black26,
      ),
    ],
  );
  
  static const TextStyle questTitleStyle = TextStyle(
    fontFamily: 'serif',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: darkBrown,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontFamily: 'serif',
    fontSize: 14,
    color: darkBrown,
  );
  
  // 羊皮纸卡片装饰
  static BoxDecoration parchmentDecoration = BoxDecoration(
    color: parchment,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: darkBrown, width: 2),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(2, 4),
      ),
    ],
  );
  
  // 木质按钮装饰
  static BoxDecoration woodButtonDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lightBrown,
        darkBrown,
      ],
    ),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: darkBrown, width: 3),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.4),
        blurRadius: 4,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  // 金币装饰
  static BoxDecoration goldDecoration = BoxDecoration(
    gradient: RadialGradient(
      colors: [
        primaryGold,
        Color(0xFFFFE55C),
        Color(0xFFDAA520),
      ],
    ),
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: primaryGold.withValues(alpha: 0.5),
        blurRadius: 8,
        spreadRadius: 2,
      ),
    ],
  );
  
  // 等级徽章装饰
  static BoxDecoration badgeDecoration(Color color) {
    return BoxDecoration(
      gradient: RadialGradient(
        colors: [
          color.withValues(alpha: 0.8),
          color,
          color.withValues(alpha: 0.6),
        ],
      ),
      shape: BoxShape.circle,
      border: Border.all(color: primaryGold, width: 3),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.5),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ],
    );
  }
  
  // 任务看板背景
  static BoxDecoration questBoardDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF5D4037),
        Color(0xFF3E2723),
      ],
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: primaryGold, width: 4),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.5),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
