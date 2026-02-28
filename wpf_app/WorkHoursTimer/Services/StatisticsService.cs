using System;
using System.Collections.Generic;
using System.Linq;
using WorkHoursTimer.Models;

namespace WorkHoursTimer.Services
{
    /// <summary>
    /// 统计服务
    /// </summary>
    public class StatisticsService
    {
        private static StatisticsService? _instance;
        public static StatisticsService Instance => _instance ??= new StatisticsService();

        private StatisticsService()
        {
        }

        /// <summary>
        /// 获取今日统计
        /// </summary>
        public DailyStatistics GetTodayStatistics()
        {
            var today = DateTime.Today;
            return GetStatisticsForDate(today);
        }

        /// <summary>
        /// 获取指定日期的统计
        /// </summary>
        public DailyStatistics GetStatisticsForDate(DateTime date)
        {
            var sessions = DataService.Instance.AppData.Sessions
                .Where(s => s.StartTime.Date == date.Date)
                .ToList();

            var totalSeconds = sessions.Sum(s => s.DurationSeconds);
            var projectStats = sessions
                .GroupBy(s => s.ProjectName)
                .Select(g => new ProjectDailyStats
                {
                    ProjectName = g.Key,
                    TotalSeconds = g.Sum(s => s.DurationSeconds),
                    SessionCount = g.Count()
                })
                .OrderByDescending(p => p.TotalSeconds)
                .ToList();

            return new DailyStatistics
            {
                Date = date,
                TotalSeconds = totalSeconds,
                SessionCount = sessions.Count,
                ProjectStats = projectStats
            };
        }

        /// <summary>
        /// 获取本周统计
        /// </summary>
        public WeeklyStatistics GetWeekStatistics()
        {
            var today = DateTime.Today;
            var startOfWeek = today.AddDays(-(int)today.DayOfWeek + (int)DayOfWeek.Monday);
            if (today.DayOfWeek == DayOfWeek.Sunday)
            {
                startOfWeek = startOfWeek.AddDays(-7);
            }

            return GetWeekStatistics(startOfWeek);
        }

        /// <summary>
        /// 获取指定周的统计
        /// </summary>
        public WeeklyStatistics GetWeekStatistics(DateTime startOfWeek)
        {
            var endOfWeek = startOfWeek.AddDays(7);
            var sessions = DataService.Instance.AppData.Sessions
                .Where(s => s.StartTime.Date >= startOfWeek && s.StartTime.Date < endOfWeek)
                .ToList();

            var dailyStats = new List<DailyStatistics>();
            for (int i = 0; i < 7; i++)
            {
                var date = startOfWeek.AddDays(i);
                dailyStats.Add(GetStatisticsForDate(date));
            }

            var totalSeconds = sessions.Sum(s => s.DurationSeconds);
            var projectStats = sessions
                .GroupBy(s => s.ProjectName)
                .Select(g => new ProjectWeeklyStats
                {
                    ProjectName = g.Key,
                    TotalSeconds = g.Sum(s => s.DurationSeconds),
                    SessionCount = g.Count(),
                    DailyBreakdown = dailyStats
                        .Select(d => d.ProjectStats.FirstOrDefault(p => p.ProjectName == g.Key)?.TotalSeconds ?? 0)
                        .ToList()
                })
                .OrderByDescending(p => p.TotalSeconds)
                .ToList();

            return new WeeklyStatistics
            {
                StartDate = startOfWeek,
                EndDate = endOfWeek.AddDays(-1),
                TotalSeconds = totalSeconds,
                SessionCount = sessions.Count,
                DailyStats = dailyStats,
                ProjectStats = projectStats
            };
        }

        /// <summary>
        /// 获取本月统计
        /// </summary>
        public MonthlyStatistics GetMonthStatistics()
        {
            var today = DateTime.Today;
            return GetMonthStatistics(today.Year, today.Month);
        }

        /// <summary>
        /// 获取指定月份的统计
        /// </summary>
        public MonthlyStatistics GetMonthStatistics(int year, int month)
        {
            var startOfMonth = new DateTime(year, month, 1);
            var endOfMonth = startOfMonth.AddMonths(1);

            var sessions = DataService.Instance.AppData.Sessions
                .Where(s => s.StartTime >= startOfMonth && s.StartTime < endOfMonth)
                .ToList();

            var totalSeconds = sessions.Sum(s => s.DurationSeconds);
            var projectStats = sessions
                .GroupBy(s => s.ProjectName)
                .Select(g => new ProjectMonthlyStats
                {
                    ProjectName = g.Key,
                    TotalSeconds = g.Sum(s => s.DurationSeconds),
                    SessionCount = g.Count()
                })
                .OrderByDescending(p => p.TotalSeconds)
                .ToList();

            // 按周分组
            var weeklyBreakdown = new List<int>();
            var currentDate = startOfMonth;
            while (currentDate < endOfMonth)
            {
                var weekEnd = currentDate.AddDays(7);
                if (weekEnd > endOfMonth) weekEnd = endOfMonth;

                var weekSeconds = sessions
                    .Where(s => s.StartTime >= currentDate && s.StartTime < weekEnd)
                    .Sum(s => s.DurationSeconds);

                weeklyBreakdown.Add(weekSeconds);
                currentDate = weekEnd;
            }

            return new MonthlyStatistics
            {
                Year = year,
                Month = month,
                TotalSeconds = totalSeconds,
                SessionCount = sessions.Count,
                ProjectStats = projectStats,
                WeeklyBreakdown = weeklyBreakdown
            };
        }

        /// <summary>
        /// 获取日期范围统计
        /// </summary>
        public RangeStatistics GetRangeStatistics(DateTime startDate, DateTime endDate)
        {
            var sessions = DataService.Instance.AppData.Sessions
                .Where(s => s.StartTime.Date >= startDate.Date && s.StartTime.Date <= endDate.Date)
                .ToList();

            var totalSeconds = sessions.Sum(s => s.DurationSeconds);
            var projectStats = sessions
                .GroupBy(s => s.ProjectName)
                .Select(g => new ProjectRangeStats
                {
                    ProjectName = g.Key,
                    TotalSeconds = g.Sum(s => s.DurationSeconds),
                    SessionCount = g.Count()
                })
                .OrderByDescending(p => p.TotalSeconds)
                .ToList();

            return new RangeStatistics
            {
                StartDate = startDate,
                EndDate = endDate,
                TotalSeconds = totalSeconds,
                SessionCount = sessions.Count,
                ProjectStats = projectStats
            };
        }

        /// <summary>
        /// 获取项目对比数据
        /// </summary>
        public List<ProjectComparisonData> GetProjectComparison(DateTime startDate, DateTime endDate)
        {
            var sessions = DataService.Instance.AppData.Sessions
                .Where(s => s.StartTime.Date >= startDate.Date && s.StartTime.Date <= endDate.Date)
                .ToList();

            return sessions
                .GroupBy(s => s.ProjectName)
                .Select(g => new ProjectComparisonData
                {
                    ProjectName = g.Key,
                    TotalSeconds = g.Sum(s => s.DurationSeconds),
                    SessionCount = g.Count(),
                    AverageSessionSeconds = (int)g.Average(s => s.DurationSeconds),
                    TotalHours = g.Sum(s => s.DurationSeconds) / 3600.0
                })
                .OrderByDescending(p => p.TotalSeconds)
                .ToList();
        }
    }

    #region 统计数据模型

    /// <summary>
    /// 日统计
    /// </summary>
    public class DailyStatistics
    {
        public DateTime Date { get; set; }
        public int TotalSeconds { get; set; }
        public int SessionCount { get; set; }
        public List<ProjectDailyStats> ProjectStats { get; set; } = new();

        public double TotalHours => TotalSeconds / 3600.0;
        public string FormattedTotal => $"{TotalSeconds / 3600}h {(TotalSeconds % 3600) / 60}m {TotalSeconds % 60}s";
    }

    /// <summary>
    /// 项目日统计
    /// </summary>
    public class ProjectDailyStats
    {
        public string ProjectName { get; set; } = string.Empty;
        public int TotalSeconds { get; set; }
        public int SessionCount { get; set; }

        public double TotalHours => TotalSeconds / 3600.0;
        public string FormattedTotal => $"{TotalSeconds / 3600}h {(TotalSeconds % 3600) / 60}m {TotalSeconds % 60}s";
    }

    /// <summary>
    /// 周统计
    /// </summary>
    public class WeeklyStatistics
    {
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int TotalSeconds { get; set; }
        public int SessionCount { get; set; }
        public List<DailyStatistics> DailyStats { get; set; } = new();
        public List<ProjectWeeklyStats> ProjectStats { get; set; } = new();

        public double TotalHours => TotalSeconds / 3600.0;
        public string FormattedTotal => $"{TotalSeconds / 3600}h {(TotalSeconds % 3600) / 60}m {TotalSeconds % 60}s";
    }

    /// <summary>
    /// 项目周统计
    /// </summary>
    public class ProjectWeeklyStats
    {
        public string ProjectName { get; set; } = string.Empty;
        public int TotalSeconds { get; set; }
        public int SessionCount { get; set; }
        public List<int> DailyBreakdown { get; set; } = new(); // 7天的秒数

        public double TotalHours => TotalSeconds / 3600.0;
        public string FormattedTotal => $"{TotalSeconds / 3600}h {(TotalSeconds % 3600) / 60}m {TotalSeconds % 60}s";
    }

    /// <summary>
    /// 月统计
    /// </summary>
    public class MonthlyStatistics
    {
        public int Year { get; set; }
        public int Month { get; set; }
        public int TotalSeconds { get; set; }
        public int SessionCount { get; set; }
        public List<ProjectMonthlyStats> ProjectStats { get; set; } = new();
        public List<int> WeeklyBreakdown { get; set; } = new(); // 每周的秒数

        public double TotalHours => TotalSeconds / 3600.0;
        public string FormattedTotal => $"{TotalSeconds / 3600}h {(TotalSeconds % 3600) / 60}m {TotalSeconds % 60}s";
    }

    /// <summary>
    /// 项目月统计
    /// </summary>
    public class ProjectMonthlyStats
    {
        public string ProjectName { get; set; } = string.Empty;
        public int TotalSeconds { get; set; }
        public int SessionCount { get; set; }

        public double TotalHours => TotalSeconds / 3600.0;
    }

    /// <summary>
    /// 范围统计
    /// </summary>
    public class RangeStatistics
    {
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int TotalSeconds { get; set; }
        public int SessionCount { get; set; }
        public List<ProjectRangeStats> ProjectStats { get; set; } = new();

        public double TotalHours => TotalSeconds / 3600.0;
        public string FormattedTotal => $"{TotalSeconds / 3600}h {(TotalSeconds % 3600) / 60}m";
    }

    /// <summary>
    /// 项目范围统计
    /// </summary>
    public class ProjectRangeStats
    {
        public string ProjectName { get; set; } = string.Empty;
        public int TotalSeconds { get; set; }
        public int SessionCount { get; set; }

        public double TotalHours => TotalSeconds / 3600.0;
    }

    /// <summary>
    /// 项目对比数据
    /// </summary>
    public class ProjectComparisonData
    {
        public string ProjectName { get; set; } = string.Empty;
        public int TotalSeconds { get; set; }
        public int SessionCount { get; set; }
        public int AverageSessionSeconds { get; set; }
        public double TotalHours { get; set; }

        public string FormattedTotal => $"{TotalSeconds / 3600}h {(TotalSeconds % 3600) / 60}m";
        public string FormattedAverage => $"{AverageSessionSeconds / 3600}h {(AverageSessionSeconds % 3600) / 60}m";
    }

    #endregion
}
