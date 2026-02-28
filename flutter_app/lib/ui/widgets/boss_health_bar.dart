import 'package:flutter/material.dart';
import '../../core/models/project.dart';

/// BOSS 血条组件
/// 显示项目进度的可视化血条
class BossHealthBar extends StatelessWidget {
  final Project project;
  final bool showDetails;
  final double height;

  const BossHealthBar({
    super.key,
    required this.project,
    this.showDetails = true,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    final progress = project.progress.clamp(0.0, 1.0);
    final healthPercentage = project.healthPercentage;

    // 根据血量选择颜色
    Color getHealthColor() {
      if (healthPercentage > 0.6) {
        return Colors.green;
      } else if (healthPercentage > 0.3) {
        return Colors.orange;
      } else {
        return Colors.red;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDetails) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(
              color: Colors.grey[400]!,
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              // 血条背景
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
              // 血条填充（从右到左减少）
              FractionallySizedBox(
                widthFactor: healthPercentage,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        getHealthColor(),
                        getHealthColor().withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(height / 2),
                    boxShadow: [
                      BoxShadow(
                        color: getHealthColor().withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              // 文字显示
              Center(
                child: Text(
                  '${project.actualHours.toStringAsFixed(1)}h / ${project.estimatedHours.toStringAsFixed(1)}h',
                  style: TextStyle(
                    color:
                        healthPercentage > 0.5 ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    shadows: healthPercentage > 0.5
                        ? [
                            const Shadow(
                              color: Colors.black26,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDetails) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '剩余: ${project.remainingHours.toStringAsFixed(1)}h',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.emoji_events, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${project.rewardGold} 金币 + ${project.rewardExp} 经验',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// 迷你 BOSS 血条（用于主页显示）
class MiniBossHealthBar extends StatelessWidget {
  final Project project;

  const MiniBossHealthBar({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return BossHealthBar(
      project: project,
      showDetails: false,
      height: 24,
    );
  }
}
