using System;
using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace WorkHoursTimer.Models
{
    /// <summary>
    /// 冒险者档案（游戏化数据）
    /// </summary>
    public class AdventurerProfile
    {
        /// <summary>
        /// 冒险者名称
        /// </summary>
        [JsonPropertyName("name")]
        public string Name { get; set; } = "勇者";

        /// <summary>
        /// 等级
        /// </summary>
        [JsonPropertyName("level")]
        public int Level { get; set; } = 1;

        /// <summary>
        /// 当前经验值
        /// </summary>
        [JsonPropertyName("experience")]
        public int Experience { get; set; } = 0;

        /// <summary>
        /// 升级所需经验值
        /// </summary>
        [JsonPropertyName("experienceToNextLevel")]
        public int ExperienceToNextLevel => Level * 100;

        /// <summary>
        /// 总金币
        /// </summary>
        [JsonPropertyName("gold")]
        public int Gold { get; set; } = 0;

        /// <summary>
        /// 总工作时长（秒）
        /// </summary>
        [JsonPropertyName("totalWorkSeconds")]
        public long TotalWorkSeconds { get; set; } = 0;

        /// <summary>
        /// 总工作天数
        /// </summary>
        [JsonPropertyName("totalWorkDays")]
        public int TotalWorkDays { get; set; } = 0;

        /// <summary>
        /// 连续工作天数
        /// </summary>
        [JsonPropertyName("consecutiveDays")]
        public int ConsecutiveDays { get; set; } = 0;

        /// <summary>
        /// 最长连续工作天数
        /// </summary>
        [JsonPropertyName("maxConsecutiveDays")]
        public int MaxConsecutiveDays { get; set; } = 0;

        /// <summary>
        /// 已解锁成就 ID 列表
        /// </summary>
        [JsonPropertyName("unlockedAchievements")]
        public List<string> UnlockedAchievements { get; set; } = new();

        /// <summary>
        /// 已击败的 Boss 列表
        /// </summary>
        [JsonPropertyName("defeatedBosses")]
        public List<string> DefeatedBosses { get; set; } = new();

        /// <summary>
        /// 创建时间
        /// </summary>
        [JsonPropertyName("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        /// <summary>
        /// 最后工作时间
        /// </summary>
        [JsonPropertyName("lastWorkDate")]
        public DateTime? LastWorkDate { get; set; }

        /// <summary>
        /// 添加经验值
        /// </summary>
        public bool AddExperience(int exp)
        {
            Experience += exp;
            
            // 检查是否升级
            while (Experience >= ExperienceToNextLevel)
            {
                Experience -= ExperienceToNextLevel;
                Level++;
                return true; // 升级了
            }
            
            return false; // 没有升级
        }

        /// <summary>
        /// 添加金币
        /// </summary>
        public void AddGold(int amount)
        {
            Gold += amount;
        }

        /// <summary>
        /// 扣除金币
        /// </summary>
        public bool SpendGold(int amount)
        {
            if (Gold >= amount)
            {
                Gold -= amount;
                return true;
            }
            return false;
        }

        /// <summary>
        /// 解锁成就
        /// </summary>
        public bool UnlockAchievement(string achievementId)
        {
            if (!UnlockedAchievements.Contains(achievementId))
            {
                UnlockedAchievements.Add(achievementId);
                return true;
            }
            return false;
        }

        /// <summary>
        /// 击败 Boss
        /// </summary>
        public bool DefeatBoss(string bossId)
        {
            if (!DefeatedBosses.Contains(bossId))
            {
                DefeatedBosses.Add(bossId);
                return true;
            }
            return false;
        }

        /// <summary>
        /// 更新连续工作天数
        /// </summary>
        public void UpdateConsecutiveDays()
        {
            var today = DateTime.Today;
            
            if (LastWorkDate == null)
            {
                // 第一次工作
                ConsecutiveDays = 1;
                TotalWorkDays = 1;
            }
            else if (LastWorkDate.Value.Date == today)
            {
                // 今天已经工作过，不增加天数
                return;
            }
            else if (LastWorkDate.Value.Date == today.AddDays(-1))
            {
                // 连续工作
                ConsecutiveDays++;
                TotalWorkDays++;
            }
            else
            {
                // 中断了
                ConsecutiveDays = 1;
                TotalWorkDays++;
            }
            
            LastWorkDate = today;
            
            // 更新最长连续天数
            if (ConsecutiveDays > MaxConsecutiveDays)
            {
                MaxConsecutiveDays = ConsecutiveDays;
            }
        }
    }
}
