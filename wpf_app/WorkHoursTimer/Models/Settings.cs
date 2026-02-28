using System;
using System.Text.Json.Serialization;

namespace WorkHoursTimer.Models
{
    /// <summary>
    /// 应用设置
    /// </summary>
    public class Settings
    {
        /// <summary>
        /// 时薪（元/小时）
        /// </summary>
        [JsonPropertyName("hourlyRate")]
        public double HourlyRate { get; set; } = 100.0;

        /// <summary>
        /// 主题（dark/light）
        /// </summary>
        [JsonPropertyName("theme")]
        public string Theme { get; set; } = "dark";

        /// <summary>
        /// 挂件皮肤（boss_battle/runner_cat）
        /// </summary>
        [JsonPropertyName("widgetSkin")]
        public string WidgetSkin { get; set; } = "boss_battle";

        /// <summary>
        /// 开机自启
        /// </summary>
        [JsonPropertyName("autoStart")]
        public bool AutoStart { get; set; } = false;

        /// <summary>
        /// 启用音效
        /// </summary>
        [JsonPropertyName("soundEnabled")]
        public bool SoundEnabled { get; set; } = true;

        /// <summary>
        /// 音量（0-100）
        /// </summary>
        [JsonPropertyName("volume")]
        public int Volume { get; set; } = 50;

        /// <summary>
        /// 挂件窗口位置 X
        /// </summary>
        [JsonPropertyName("widgetX")]
        public double WidgetX { get; set; } = -1;

        /// <summary>
        /// 挂件窗口位置 Y
        /// </summary>
        [JsonPropertyName("widgetY")]
        public double WidgetY { get; set; } = -1;

        /// <summary>
        /// 挂件窗口置顶
        /// </summary>
        [JsonPropertyName("widgetTopmost")]
        public bool WidgetTopmost { get; set; } = true;

        /// <summary>
        /// 启用自动隐藏
        /// </summary>
        [JsonPropertyName("autoHideEnabled")]
        public bool AutoHideEnabled { get; set; } = true;

        /// <summary>
        /// 自动隐藏延迟（秒）
        /// </summary>
        [JsonPropertyName("autoHideDelay")]
        public int AutoHideDelay { get; set; } = 3;

        /// <summary>
        /// 每日工作目标（小时）
        /// </summary>
        [JsonPropertyName("dailyGoal")]
        public double DailyGoal { get; set; } = 8.0;

        /// <summary>
        /// 工作开始时间（小时，0-23）
        /// </summary>
        [JsonPropertyName("workStartHour")]
        public int WorkStartHour { get; set; } = 9;

        /// <summary>
        /// 工作结束时间（小时，0-23）
        /// </summary>
        [JsonPropertyName("workEndHour")]
        public int WorkEndHour { get; set; } = 18;

        /// <summary>
        /// 启用午休提醒
        /// </summary>
        [JsonPropertyName("lunchBreakEnabled")]
        public bool LunchBreakEnabled { get; set; } = true;

        /// <summary>
        /// 午休开始时间
        /// </summary>
        [JsonPropertyName("lunchBreakStart")]
        public TimeSpan LunchBreakStart { get; set; } = new TimeSpan(12, 0, 0);

        /// <summary>
        /// 午休时长（分钟）
        /// </summary>
        [JsonPropertyName("lunchBreakDuration")]
        public int LunchBreakDuration { get; set; } = 60;

        /// <summary>
        /// 启用游戏化功能
        /// </summary>
        [JsonPropertyName("gamificationEnabled")]
        public bool GamificationEnabled { get; set; } = true;

        /// <summary>
        /// 当前等级
        /// </summary>
        [JsonPropertyName("level")]
        public int Level { get; set; } = 1;

        /// <summary>
        /// 当前经验值
        /// </summary>
        [JsonPropertyName("experience")]
        public int Experience { get; set; } = 0;

        /// <summary>
        /// 总金币
        /// </summary>
        [JsonPropertyName("totalGold")]
        public int TotalGold { get; set; } = 0;

        /// <summary>
        /// 上次更新时间
        /// </summary>
        [JsonPropertyName("lastUpdated")]
        public DateTime LastUpdated { get; set; } = DateTime.Now;
    }
}
