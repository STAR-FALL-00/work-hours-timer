using System.Collections.Generic;

namespace WorkHoursTimer.Models
{
    /// <summary>
    /// 应用数据模型（用于 JSON 序列化）
    /// </summary>
    public class AppData
    {
        /// <summary>
        /// 所有工作会话
        /// </summary>
        public List<WorkSession> Sessions { get; set; } = new();

        /// <summary>
        /// 项目列表
        /// </summary>
        public List<Project> Projects { get; set; } = new();

        /// <summary>
        /// 当前活动会话 ID
        /// </summary>
        public string? ActiveSessionId { get; set; }

        /// <summary>
        /// 当前选中的项目 ID
        /// </summary>
        public string? CurrentProjectId { get; set; }

        /// <summary>
        /// 总工作时长（秒）
        /// </summary>
        public int TotalWorkSeconds { get; set; }

        /// <summary>
        /// 应用设置
        /// </summary>
        public Settings Settings { get; set; } = new();

        /// <summary>
        /// 冒险者档案（游戏化数据）
        /// </summary>
        public AdventurerProfile? AdventurerProfile { get; set; }
    }
}
