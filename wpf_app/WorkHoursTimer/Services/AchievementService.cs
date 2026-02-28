using System;
using System.Collections.Generic;
using System.Linq;
using WorkHoursTimer.Models;

namespace WorkHoursTimer.Services
{
    /// <summary>
    /// 成就系统服务
    /// </summary>
    public class AchievementService
    {
        private static AchievementService? _instance;
        public static AchievementService Instance => _instance ??= new AchievementService();

        /// <summary>
        /// 所有成就列表
        /// </summary>
        public List<Achievement> AllAchievements { get; private set; }

        /// <summary>
        /// 成就解锁事件
        /// </summary>
        public event EventHandler<AchievementUnlockedEventArgs>? AchievementUnlocked;

        private AchievementService()
        {
            AllAchievements = InitializeAchievements();
            LoadProgress();
        }

        /// <summary>
        /// 初始化成就列表
        /// </summary>
        private List<Achievement> InitializeAchievements()
        {
            return new List<Achievement>
            {
                // 工作时长成就
                new Achievement
                {
                    Id = "work_1h",
                    Name = "初出茅庐",
                    Description = "累计工作1小时",
                    Icon = "🌱",
                    Type = AchievementType.WorkHours,
                    TargetValue = 3600,
                    RewardGold = 50,
                    RewardExp = 25
                },
                new Achievement
                {
                    Id = "work_10h",
                    Name = "勤奋工作者",
                    Description = "累计工作10小时",
                    Icon = "💼",
                    Type = AchievementType.WorkHours,
                    TargetValue = 36000,
                    RewardGold = 200,
                    RewardExp = 100
                },
                new Achievement
                {
                    Id = "work_100h",
                    Name = "时间大师",
                    Description = "累计工作100小时",
                    Icon = "⏰",
                    Type = AchievementType.WorkHours,
                    TargetValue = 360000,
                    RewardGold = 1000,
                    RewardExp = 500
                },
                new Achievement
                {
                    Id = "work_1000h",
                    Name = "传奇工匠",
                    Description = "累计工作1000小时",
                    Icon = "👑",
                    Type = AchievementType.WorkHours,
                    TargetValue = 3600000,
                    RewardGold = 5000,
                    RewardExp = 2500
                },

                // 连续工作成就
                new Achievement
                {
                    Id = "consecutive_3",
                    Name = "三日之约",
                    Description = "连续工作3天",
                    Icon = "🔥",
                    Type = AchievementType.Consecutive,
                    TargetValue = 3,
                    RewardGold = 100,
                    RewardExp = 50
                },
                new Achievement
                {
                    Id = "consecutive_7",
                    Name = "一周坚持",
                    Description = "连续工作7天",
                    Icon = "⭐",
                    Type = AchievementType.Consecutive,
                    TargetValue = 7,
                    RewardGold = 300,
                    RewardExp = 150
                },
                new Achievement
                {
                    Id = "consecutive_30",
                    Name = "月度冠军",
                    Description = "连续工作30天",
                    Icon = "🏆",
                    Type = AchievementType.Consecutive,
                    TargetValue = 30,
                    RewardGold = 1500,
                    RewardExp = 750
                },
                new Achievement
                {
                    Id = "consecutive_100",
                    Name = "百日修行",
                    Description = "连续工作100天",
                    Icon = "💎",
                    Type = AchievementType.Consecutive,
                    TargetValue = 100,
                    RewardGold = 5000,
                    RewardExp = 2500
                },

                // 收益成就
                new Achievement
                {
                    Id = "gold_1000",
                    Name = "小富即安",
                    Description = "累计获得1000金币",
                    Icon = "💰",
                    Type = AchievementType.Earnings,
                    TargetValue = 1000,
                    RewardGold = 100,
                    RewardExp = 50
                },
                new Achievement
                {
                    Id = "gold_10000",
                    Name = "财源广进",
                    Description = "累计获得10000金币",
                    Icon = "💸",
                    Type = AchievementType.Earnings,
                    TargetValue = 10000,
                    RewardGold = 500,
                    RewardExp = 250
                },
                new Achievement
                {
                    Id = "gold_100000",
                    Name = "富甲一方",
                    Description = "累计获得100000金币",
                    Icon = "🏦",
                    Type = AchievementType.Earnings,
                    TargetValue = 100000,
                    RewardGold = 2000,
                    RewardExp = 1000
                },

                // 特殊成就
                new Achievement
                {
                    Id = "first_work",
                    Name = "新的开始",
                    Description = "完成第一次工作记录",
                    Icon = "🎉",
                    Type = AchievementType.Special,
                    TargetValue = 1,
                    RewardGold = 50,
                    RewardExp = 25
                },
                new Achievement
                {
                    Id = "early_bird",
                    Name = "早起的鸟儿",
                    Description = "在早上6点前开始工作",
                    Icon = "🌅",
                    Type = AchievementType.Special,
                    TargetValue = 1,
                    RewardGold = 100,
                    RewardExp = 50
                },
                new Achievement
                {
                    Id = "night_owl",
                    Name = "夜猫子",
                    Description = "在晚上10点后还在工作",
                    Icon = "🦉",
                    Type = AchievementType.Special,
                    TargetValue = 1,
                    RewardGold = 100,
                    RewardExp = 50
                },
                new Achievement
                {
                    Id = "workaholic",
                    Name = "工作狂",
                    Description = "单次工作超过8小时",
                    Icon = "🔋",
                    Type = AchievementType.Special,
                    TargetValue = 28800,
                    RewardGold = 200,
                    RewardExp = 100
                }
            };
        }

        /// <summary>
        /// 加载成就进度
        /// </summary>
        private void LoadProgress()
        {
            var profile = EconomyService.Instance.Profile;
            
            foreach (var achievement in AllAchievements)
            {
                // 检查是否已解锁
                achievement.IsUnlocked = profile.UnlockedAchievements.Contains(achievement.Id);
                
                // 更新进度
                switch (achievement.Type)
                {
                    case AchievementType.WorkHours:
                        achievement.CurrentProgress = (int)profile.TotalWorkSeconds;
                        break;
                    
                    case AchievementType.Consecutive:
                        achievement.CurrentProgress = profile.ConsecutiveDays;
                        break;
                    
                    case AchievementType.Earnings:
                        achievement.CurrentProgress = profile.Gold;
                        break;
                }
            }
        }

        /// <summary>
        /// 检查并解锁成就
        /// </summary>
        public void CheckAchievements()
        {
            LoadProgress();
            
            foreach (var achievement in AllAchievements)
            {
                if (!achievement.IsUnlocked && achievement.CurrentProgress >= achievement.TargetValue)
                {
                    UnlockAchievement(achievement);
                }
            }
        }

        /// <summary>
        /// 解锁成就
        /// </summary>
        private void UnlockAchievement(Achievement achievement)
        {
            achievement.IsUnlocked = true;
            achievement.UnlockedAt = DateTime.Now;
            
            // 添加到已解锁列表
            var profile = EconomyService.Instance.Profile;
            profile.UnlockAchievement(achievement.Id);
            
            // 发放奖励
            EconomyService.Instance.AddGold(achievement.RewardGold);
            EconomyService.Instance.AddExperience(achievement.RewardExp);
            
            // 触发事件
            AchievementUnlocked?.Invoke(this, new AchievementUnlockedEventArgs
            {
                Achievement = achievement
            });
        }

        /// <summary>
        /// 获取已解锁成就
        /// </summary>
        public List<Achievement> GetUnlockedAchievements()
        {
            return AllAchievements.Where(a => a.IsUnlocked).ToList();
        }

        /// <summary>
        /// 获取未解锁成就
        /// </summary>
        public List<Achievement> GetLockedAchievements()
        {
            return AllAchievements.Where(a => !a.IsUnlocked).ToList();
        }

        /// <summary>
        /// 获取成就统计
        /// </summary>
        public (int total, int unlocked, double percentage) GetStatistics()
        {
            var total = AllAchievements.Count;
            var unlocked = AllAchievements.Count(a => a.IsUnlocked);
            var percentage = (double)unlocked / total * 100;
            
            return (total, unlocked, percentage);
        }
    }

    /// <summary>
    /// 成就解锁事件参数
    /// </summary>
    public class AchievementUnlockedEventArgs : EventArgs
    {
        public Achievement Achievement { get; set; } = null!;
    }
}
