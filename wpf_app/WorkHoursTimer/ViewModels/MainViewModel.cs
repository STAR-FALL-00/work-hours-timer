using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using System;
using System.Collections.ObjectModel;
using WorkHoursTimer.Models;
using WorkHoursTimer.Services;

namespace WorkHoursTimer.ViewModels
{
    /// <summary>
    /// 主窗口视图模型
    /// </summary>
    public partial class MainViewModel : ObservableObject
    {
        [ObservableProperty]
        private string _currentTime = "00:00:00";

        [ObservableProperty]
        private string _currentProject = "未开始";

        [ObservableProperty]
        private bool _isTimerRunning = false;

        [ObservableProperty]
        private bool _isTimerPaused = false;

        [ObservableProperty]
        private ObservableCollection<Project> _projects = new();

        [ObservableProperty]
        private Project? _selectedProject;

        [ObservableProperty]
        private double _todayHours = 0.0;

        [ObservableProperty]
        private int _todaySessions = 0;

        [ObservableProperty]
        private double _todayEarnings = 0.0;

        public MainViewModel()
        {
            // 订阅计时器事件
            TimerService.Instance.TimerTick += OnTimerTick;
            
            // 订阅项目变更事件
            ProjectService.Instance.ProjectChanged += OnProjectChanged;
            
            // 加载项目列表
            LoadProjects();
            
            // 加载今日统计
            LoadTodayStats();
        }

        /// <summary>
        /// 加载项目列表
        /// </summary>
        private void LoadProjects()
        {
            Projects.Clear();
            var projects = ProjectService.Instance.GetActiveProjects();
            foreach (var project in projects)
            {
                Projects.Add(project);
            }
            
            SelectedProject = ProjectService.Instance.CurrentProject;
        }

        /// <summary>
        /// 加载今日统计
        /// </summary>
        private void LoadTodayStats()
        {
            var stats = StatisticsService.Instance.GetTodayStatistics();
            TodayHours = stats.TotalHours;
            TodaySessions = stats.SessionCount;
            TodayEarnings = stats.TotalHours * 100; // 假设时薪100
        }

        /// <summary>
        /// 计时器更新事件
        /// </summary>
        private void OnTimerTick(object? sender, TimerTickEventArgs e)
        {
            CurrentTime = e.FormattedDuration;
        }

        /// <summary>
        /// 项目变更事件
        /// </summary>
        private void OnProjectChanged(object? sender, ProjectChangedEventArgs e)
        {
            LoadProjects();
        }

        /// <summary>
        /// 开始工作命令
        /// </summary>
        [RelayCommand]
        private void StartWork()
        {
            TimerService.Instance.Start();
            IsTimerRunning = true;
            IsTimerPaused = false;
            CurrentProject = ProjectService.Instance.CurrentProject?.Name ?? "默认项目";
        }

        /// <summary>
        /// 暂停/恢复命令
        /// </summary>
        [RelayCommand]
        private void PauseResume()
        {
            if (TimerService.Instance.IsRunning)
            {
                TimerService.Instance.Pause();
                IsTimerPaused = true;
            }
            else
            {
                TimerService.Instance.Resume();
                IsTimerPaused = false;
            }
        }

        /// <summary>
        /// 停止工作命令
        /// </summary>
        [RelayCommand]
        private void StopWork()
        {
            var session = TimerService.Instance.Stop();
            if (session != null)
            {
                DataService.Instance.AddSession(session);
                
                var project = ProjectService.Instance.CurrentProject;
                if (project != null)
                {
                    ProjectService.Instance.UpdateProjectStats(project.Id, session.DurationSeconds);
                }
            }
            
            IsTimerRunning = false;
            IsTimerPaused = false;
            CurrentTime = "00:00:00";
            CurrentProject = "未开始";
            
            LoadTodayStats();
        }

        /// <summary>
        /// 切换项目命令
        /// </summary>
        [RelayCommand]
        private void SwitchProject(string projectId)
        {
            ProjectService.Instance.SwitchProject(projectId);
        }
    }
}
