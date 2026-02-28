using System;
using System.Text.Json.Serialization;

namespace WorkHoursTimer.Models
{
    /// <summary>
    /// 项目模型
    /// </summary>
    public class Project
    {
        /// <summary>
        /// 项目 ID
        /// </summary>
        [JsonPropertyName("id")]
        public string Id { get; set; } = Guid.NewGuid().ToString();

        /// <summary>
        /// 项目名称
        /// </summary>
        [JsonPropertyName("name")]
        public string Name { get; set; } = string.Empty;

        /// <summary>
        /// 项目颜色（十六进制）
        /// </summary>
        [JsonPropertyName("color")]
        public string Color { get; set; } = "#FFD700";

        /// <summary>
        /// 项目描述
        /// </summary>
        [JsonPropertyName("description")]
        public string Description { get; set; } = string.Empty;

        /// <summary>
        /// 创建时间
        /// </summary>
        [JsonPropertyName("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        /// <summary>
        /// 是否激活
        /// </summary>
        [JsonPropertyName("isActive")]
        public bool IsActive { get; set; } = true;

        /// <summary>
        /// 总工时（秒）
        /// </summary>
        [JsonPropertyName("totalSeconds")]
        public int TotalSeconds { get; set; } = 0;

        /// <summary>
        /// 会话数量
        /// </summary>
        [JsonPropertyName("sessionCount")]
        public int SessionCount { get; set; } = 0;

        /// <summary>
        /// 格式化的总工时
        /// </summary>
        [JsonIgnore]
        public string FormattedTotalTime
        {
            get
            {
                var hours = TotalSeconds / 3600;
                var minutes = (TotalSeconds % 3600) / 60;
                return $"{hours}h {minutes}m";
            }
        }

        /// <summary>
        /// 总工时（小时）
        /// </summary>
        [JsonIgnore]
        public double TotalHours => TotalSeconds / 3600.0;
    }
}
