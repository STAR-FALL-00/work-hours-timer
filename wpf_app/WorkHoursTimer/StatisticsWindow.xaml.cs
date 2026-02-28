using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows;
using WorkHoursTimer.Services;
using Wpf.Ui.Controls;

namespace WorkHoursTimer
{
    /// <summary>
    /// 统计窗口
    /// </summary>
    public partial class StatisticsWindow : FluentWindow
    {
        private enum StatisticsMode
        {
            Today,
            Week,
            Month
        }

        private StatisticsMode _currentMode = StatisticsMode.Today;

        public StatisticsWindow()
        {
            try
            {
                InitializeComponent();
                ShowTodayStatistics();
            }
            catch (Exception ex)
            {
                System.Windows.MessageBox.Show(
                    $"统计窗口初始化失败:\n{ex.Message}\n\n{ex.StackTrace}",
                    "错误",
                    System.Windows.MessageBoxButton.OK,
                    System.Windows.MessageBoxImage.Error
                );
                Close();
            }
        }

        /// <summary>
        /// 显示今日统计
        /// </summary>
        private void ShowToday_Click(object sender, RoutedEventArgs e)
        {
            ShowTodayStatistics();
        }

        /// <summary>
        /// 显示本周统计
        /// </summary>
        private void ShowWeek_Click(object sender, RoutedEventArgs e)
        {
            ShowWeekStatistics();
        }

        /// <summary>
        /// 显示本月统计
        /// </summary>
        private void ShowMonth_Click(object sender, RoutedEventArgs e)
        {
            ShowMonthStatistics();
        }

        /// <summary>
        /// 显示今日统计
        /// </summary>
        private void ShowTodayStatistics()
        {
            try
            {
                _currentMode = StatisticsMode.Today;
                var stats = StatisticsService.Instance.GetTodayStatistics();
                
                // 调试信息
                System.Diagnostics.Debug.WriteLine($"今日统计 - 日期: {stats.Date:yyyy-MM-dd}");
                System.Diagnostics.Debug.WriteLine($"总秒数: {stats.TotalSeconds}");
                System.Diagnostics.Debug.WriteLine($"会话数: {stats.SessionCount}");
                System.Diagnostics.Debug.WriteLine($"项目统计数: {stats.ProjectStats?.Count ?? 0}");
                
                SubtitleText.Text = $"今日统计 - {stats.Date:yyyy年MM月dd日}";
                TotalHoursText.Text = $"{stats.TotalHours:F1} 小时";
                SessionCountText.Text = stats.SessionCount.ToString();
                
                if (stats.SessionCount > 0)
                {
                    var avgSeconds = stats.TotalSeconds / stats.SessionCount;
                    AverageTimeText.Text = $"{avgSeconds / 3600.0:F1} 小时";
                }
                else
                {
                    AverageTimeText.Text = "0.0 小时";
                }

                if (stats.ProjectStats != null && stats.ProjectStats.Any())
                {
                    ProjectStatsListBox.ItemsSource = stats.ProjectStats;
                    ProjectStatsListBox.Visibility = Visibility.Visible;
                    NoDataText.Visibility = Visibility.Collapsed;
                }
                else
                {
                    ProjectStatsListBox.ItemsSource = null;
                    ProjectStatsListBox.Visibility = Visibility.Collapsed;
                    NoDataText.Visibility = Visibility.Visible;
                }
            }
            catch (Exception ex)
            {
                System.Windows.MessageBox.Show(
                    $"显示今日统计失败:\n{ex.Message}\n\n{ex.StackTrace}",
                    "错误",
                    System.Windows.MessageBoxButton.OK,
                    System.Windows.MessageBoxImage.Error
                );
            }
        }

        /// <summary>
        /// 显示本周统计
        /// </summary>
        private void ShowWeekStatistics()
        {
            _currentMode = StatisticsMode.Week;
            var stats = StatisticsService.Instance.GetWeekStatistics();
            
            SubtitleText.Text = $"本周统计 - {stats.StartDate:MM月dd日} 至 {stats.EndDate:MM月dd日}";
            TotalHoursText.Text = $"{stats.TotalHours:F1} 小时";
            SessionCountText.Text = stats.SessionCount.ToString();
            
            if (stats.SessionCount > 0)
            {
                var avgSeconds = stats.TotalSeconds / stats.SessionCount;
                AverageTimeText.Text = $"{avgSeconds / 3600.0:F1} 小时";
            }
            else
            {
                AverageTimeText.Text = "0.0 小时";
            }

            if (stats.ProjectStats.Any())
            {
                ProjectStatsListBox.ItemsSource = stats.ProjectStats;
                ProjectStatsListBox.Visibility = Visibility.Visible;
                NoDataText.Visibility = Visibility.Collapsed;
            }
            else
            {
                ProjectStatsListBox.Visibility = Visibility.Collapsed;
                NoDataText.Visibility = Visibility.Visible;
            }
        }

        /// <summary>
        /// 显示本月统计
        /// </summary>
        private void ShowMonthStatistics()
        {
            _currentMode = StatisticsMode.Month;
            var stats = StatisticsService.Instance.GetMonthStatistics();
            
            SubtitleText.Text = $"本月统计 - {stats.Year}年{stats.Month}月";
            TotalHoursText.Text = $"{stats.TotalHours:F1} 小时";
            SessionCountText.Text = stats.SessionCount.ToString();
            
            if (stats.SessionCount > 0)
            {
                var avgSeconds = stats.TotalSeconds / stats.SessionCount;
                AverageTimeText.Text = $"{avgSeconds / 3600.0:F1} 小时";
            }
            else
            {
                AverageTimeText.Text = "0.0 小时";
            }

            if (stats.ProjectStats.Any())
            {
                ProjectStatsListBox.ItemsSource = stats.ProjectStats;
                ProjectStatsListBox.Visibility = Visibility.Visible;
                NoDataText.Visibility = Visibility.Collapsed;
            }
            else
            {
                ProjectStatsListBox.Visibility = Visibility.Collapsed;
                NoDataText.Visibility = Visibility.Visible;
            }
        }

        /// <summary>
        /// 导出数据
        /// </summary>
        private void Export_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var dialog = new Microsoft.Win32.SaveFileDialog
                {
                    Filter = "CSV 文件 (*.csv)|*.csv|所有文件 (*.*)|*.*",
                    DefaultExt = ".csv",
                    FileName = $"工时统计_{DateTime.Now:yyyyMMdd}.csv"
                };

                if (dialog.ShowDialog() == true)
                {
                    ExportToCSV(dialog.FileName);
                    System.Windows.MessageBox.Show(
                        $"数据已导出到:\n{dialog.FileName}",
                        "导出成功",
                        System.Windows.MessageBoxButton.OK,
                        System.Windows.MessageBoxImage.Information
                    );
                }
            }
            catch (Exception ex)
            {
                System.Windows.MessageBox.Show(
                    $"导出失败: {ex.Message}",
                    "错误",
                    System.Windows.MessageBoxButton.OK,
                    System.Windows.MessageBoxImage.Error
                );
            }
        }

        /// <summary>
        /// 导出为 CSV
        /// </summary>
        private void ExportToCSV(string filePath)
        {
            var sb = new StringBuilder();
            
            // 添加 BOM 以支持中文
            sb.Append('\ufeff');
            
            // 根据当前模式导出不同的数据
            switch (_currentMode)
            {
                case StatisticsMode.Today:
                    ExportTodayToCSV(sb);
                    break;
                case StatisticsMode.Week:
                    ExportWeekToCSV(sb);
                    break;
                case StatisticsMode.Month:
                    ExportMonthToCSV(sb);
                    break;
            }

            File.WriteAllText(filePath, sb.ToString(), Encoding.UTF8);
        }

        /// <summary>
        /// 导出今日数据
        /// </summary>
        private void ExportTodayToCSV(StringBuilder sb)
        {
            var stats = StatisticsService.Instance.GetTodayStatistics();
            
            sb.AppendLine("今日工时统计");
            sb.AppendLine($"日期,{stats.Date:yyyy-MM-dd}");
            sb.AppendLine($"总工时,{stats.TotalHours:F2} 小时");
            sb.AppendLine($"会话数,{stats.SessionCount}");
            sb.AppendLine();
            
            sb.AppendLine("项目名称,工时(小时),会话数");
            foreach (var project in stats.ProjectStats)
            {
                sb.AppendLine($"{project.ProjectName},{project.TotalHours:F2},{project.SessionCount}");
            }
        }

        /// <summary>
        /// 导出本周数据
        /// </summary>
        private void ExportWeekToCSV(StringBuilder sb)
        {
            var stats = StatisticsService.Instance.GetWeekStatistics();
            
            sb.AppendLine("本周工时统计");
            sb.AppendLine($"周期,{stats.StartDate:yyyy-MM-dd} 至 {stats.EndDate:yyyy-MM-dd}");
            sb.AppendLine($"总工时,{stats.TotalHours:F2} 小时");
            sb.AppendLine($"会话数,{stats.SessionCount}");
            sb.AppendLine();
            
            sb.AppendLine("项目名称,工时(小时),会话数");
            foreach (var project in stats.ProjectStats)
            {
                sb.AppendLine($"{project.ProjectName},{project.TotalHours:F2},{project.SessionCount}");
            }
        }

        /// <summary>
        /// 导出本月数据
        /// </summary>
        private void ExportMonthToCSV(StringBuilder sb)
        {
            var stats = StatisticsService.Instance.GetMonthStatistics();
            
            sb.AppendLine("本月工时统计");
            sb.AppendLine($"月份,{stats.Year}年{stats.Month}月");
            sb.AppendLine($"总工时,{stats.TotalHours:F2} 小时");
            sb.AppendLine($"会话数,{stats.SessionCount}");
            sb.AppendLine();
            
            sb.AppendLine("项目名称,工时(小时),会话数");
            foreach (var project in stats.ProjectStats)
            {
                sb.AppendLine($"{project.ProjectName},{project.TotalHours:F2},{project.SessionCount}");
            }
        }
    }
}
