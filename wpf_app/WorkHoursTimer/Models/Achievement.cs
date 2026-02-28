using System;
using System.Text.Json.Serialization;

namespace WorkHoursTimer.Models
{
    /// <summary>
    /// 成就类型
    /// </summary>
    public enum AchievementType
    {
        /// <summary>
        /// 工作时长相关
        /// </summary>
        WorkHours,
        
        /// <summary>
        /// 连续工作天数
        /// </summary>
        Consecutive,
        
        /// <summary>
        /// 项目相关
        /// </summary>
        Project,
        
        /// <summary>
        /// 收益相关
        /// </summary>
        Earnings,
        
        /// <summary>
        /// 特殊成就
        /// </summary>
        Special
    }

    /// <summary>
    /// 成就
    /// </summary>
    public class Achievement
    {
        /// <summary>
        /// 成就 ID
        /// </summary>
        [JsonPropertyName("id")]
        public string Id { get; set; } = string.Empty;

        /// <summary>
        /// 成就名称
        /// </summary>
        [JsonPropertyName("name")]
        public string Name { get; set; } = string.Empty;

        /// <summary>
        /// 成就描述
        /// </summary>
        [JsonPropertyName("description")]
        public string Description { get; set; } = string.Empty;

        /// <summary>
        /// 成就图标（Emoji）
        /// </summary>
        [JsonPropertyName("icon")]
        public string Icon { get; set; } = "🏆";

        /// <summary>
        /// 成就类型
        /// </summary>
        [JsonPropertyName("type")]
        public AchievementType Type { get; set; }

        /// <summary>
        /// 奖励金币
        /// </summary>
        [JsonPropertyName("rewardGold")]
        public int RewardGold { get; set; } = 0;

        /// <summary>
        /// 奖励经验
        /// </summary>
        [JsonPropertyName("rewardExp")]
        public int RewardExp { get; set; } = 0;

        /// <summary>
        /// 目标值（用于进度计算）
        /// </summary>
        [JsonPropertyName("targetValue")]
        public int TargetValue { get; set; } = 0;

        /// <summary>
        /// 是否已解锁
        /// </summary>
        [JsonPropertyName("isUnlocked")]
        public bool IsUnlocked { get; set; } = false;

        /// <summary>
        /// 解锁时间
        /// </summary>
        [JsonPropertyName("unlockedAt")]
        public DateTime? UnlockedAt { get; set; }

        /// <summary>
        /// 当前进度
        /// </summary>
        [JsonPropertyName("currentProgress")]
        public int CurrentProgress { get; set; } = 0;

        /// <summary>
        /// 进度百分比
        /// </summary>
        [JsonIgnore]
        public double ProgressPercentage => TargetValue > 0 ? (double)CurrentProgress / TargetValue * 100 : 0;

        /// <summary>
        /// 进度文本
        /// </summary>
        [JsonIgnore]
        public string ProgressText => $"{CurrentProgress}/{TargetValue}";
    }
}
