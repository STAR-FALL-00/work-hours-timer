using System;
using System.Windows.Threading;
using WorkHoursTimer.Models;

namespace WorkHoursTimer.Services
{
    /// <summary>
    /// 计时器服务
    /// </summary>
    public class TimerService
    {
        private static TimerService? _instance;
        public static TimerService Instance => _instance ??= new TimerService();

        private DispatcherTimer? _timer;
        private WorkSession? _currentSession;

        /// <summary>
        /// 计时器更新事件（每秒触发）
        /// </summary>
        public event EventHandler<TimerTickEventArgs>? TimerTick;

        /// <summary>
        /// 是否正在运行
        /// </summary>
        public bool IsRunning => _timer?.IsEnabled ?? false;

        /// <summary>
        /// 当前会话
        /// </summary>
        public WorkSession? CurrentSession => _currentSession;

        private TimerService()
        {
        }

        /// <summary>
        /// 开始计时
        /// </summary>
        public void Start(string? projectName = null)
        {
            if (IsRunning)
            {
                Stop();
            }

            // 如果没有指定项目名，使用当前项目
            if (string.IsNullOrEmpty(projectName))
            {
                projectName = ProjectService.Instance.CurrentProject?.Name ?? "默认项目";
            }

            _currentSession = new WorkSession
            {
                ProjectName = projectName,
                StartTime = DateTime.Now,
                IsActive = true,
                DurationSeconds = 0
            };

            _timer = new DispatcherTimer
            {
                Interval = TimeSpan.FromSeconds(1)
            };
            _timer.Tick += Timer_Tick;
            _timer.Start();

            // 发送开始消息
            WindowMessenger.Instance.SendMessage("TIMER_STARTED", new
            {
                ProjectName = projectName,
                StartTime = _currentSession.StartTime
            });
        }

        /// <summary>
        /// 停止计时
        /// </summary>
        public WorkSession? Stop()
        {
            if (_timer != null)
            {
                _timer.Stop();
                _timer.Tick -= Timer_Tick;
                _timer = null;
            }

            if (_currentSession != null)
            {
                _currentSession.EndTime = DateTime.Now;
                _currentSession.IsActive = false;

                // 发送停止消息
                WindowMessenger.Instance.SendMessage("TIMER_STOPPED", new
                {
                    Duration = _currentSession.DurationSeconds,
                    FormattedDuration = _currentSession.FormattedDuration
                });

                var session = _currentSession;
                _currentSession = null;
                return session;
            }

            return null;
        }

        /// <summary>
        /// 暂停计时
        /// </summary>
        public void Pause()
        {
            if (_timer != null && _timer.IsEnabled)
            {
                _timer.Stop();
                WindowMessenger.Instance.SendMessage("TIMER_PAUSED", null);
            }
        }

        /// <summary>
        /// 恢复计时
        /// </summary>
        public void Resume()
        {
            if (_timer != null && !_timer.IsEnabled && _currentSession != null)
            {
                _timer.Start();
                WindowMessenger.Instance.SendMessage("TIMER_RESUMED", null);
            }
        }

        private void Timer_Tick(object? sender, EventArgs e)
        {
            if (_currentSession != null)
            {
                _currentSession.DurationSeconds++;

                // 触发更新事件
                TimerTick?.Invoke(this, new TimerTickEventArgs
                {
                    DurationSeconds = _currentSession.DurationSeconds,
                    FormattedDuration = _currentSession.FormattedDuration
                });

                // 发送更新消息
                WindowMessenger.Instance.SendMessage("TIMER_TICK", new
                {
                    Duration = _currentSession.DurationSeconds,
                    FormattedDuration = _currentSession.FormattedDuration
                });
            }
        }
    }

    /// <summary>
    /// 计时器更新事件参数
    /// </summary>
    public class TimerTickEventArgs : EventArgs
    {
        public int DurationSeconds { get; set; }
        public string FormattedDuration { get; set; } = string.Empty;
    }
}
