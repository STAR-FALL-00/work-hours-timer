using System;

namespace WorkHoursTimer.Models
{
    /// <summary>
    /// 工作会话模型
    /// </summary>
    public class WorkSession
    {
        /// <summary>
        /// 会话 ID
        /// </summary>
        public string Id { get; set; } = Guid.NewGuid().ToString();

        /// <summary>
        /// 项目名称
        /// </summary>
        public string ProjectName { get; set; } = string.Empty;

        /// <summary>
        /// 开始时间
        /// </summary>
        public DateTime StartTime { get; set; }

        /// <summary>
        /// 结束时间
        /// </summary>
        public DateTime? EndTime { get; set; }

        /// <summary>
        /// 工作时长（秒）
        /// </summary>
        public int DurationSeconds { get; set; }

        /// <summary>
        /// 是否正在进行
        /// </summary>
        public bool IsActive { get; set; }

        /// <summary>
        /// 备注
        /// </summary>
        public string Notes { get; set; } = string.Empty;

        /// <summary>
        /// 获取格式化的时长
        /// </summary>
        public string FormattedDuration
        {
            get
            {
                var hours = DurationSeconds / 3600;
                var minutes = (DurationSeconds % 3600) / 60;
                var seconds = DurationSeconds % 60;
                return $"{hours:D2}:{minutes:D2}:{seconds:D2}";
            }
        }
    }
}
