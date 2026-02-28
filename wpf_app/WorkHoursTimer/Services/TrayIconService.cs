using System;
using System.Drawing;
using System.Windows;
using System.Windows.Forms;
using WpfApplication = System.Windows.Application;

namespace WorkHoursTimer.Services
{
    /// <summary>
    /// 系统托盘图标服务
    /// </summary>
    public class TrayIconService : IDisposable
    {
        private static TrayIconService? _instance;
        public static TrayIconService Instance => _instance ??= new TrayIconService();

        private NotifyIcon? _notifyIcon;
        private MainWindow? _mainWindow;

        private TrayIconService()
        {
        }

        /// <summary>
        /// 初始化托盘图标
        /// </summary>
        public void Initialize(MainWindow mainWindow)
        {
            _mainWindow = mainWindow;

            _notifyIcon = new NotifyIcon
            {
                Icon = SystemIcons.Application, // 临时使用系统图标
                Visible = true,
                Text = "Work Hours Timer"
            };

            // 双击托盘图标 - 显示/隐藏主窗口
            _notifyIcon.DoubleClick += (s, e) => ToggleMainWindow();

            // 创建右键菜单
            var contextMenu = new ContextMenuStrip();
            
            contextMenu.Items.Add("显示主窗口", null, (s, e) => ShowMainWindow());
            contextMenu.Items.Add("-"); // 分隔线
            
            var timerMenu = new ToolStripMenuItem("计时器");
            timerMenu.DropDownItems.Add("开始工作", null, (s, e) => StartTimer());
            timerMenu.DropDownItems.Add("暂停", null, (s, e) => PauseTimer());
            timerMenu.DropDownItems.Add("停止", null, (s, e) => StopTimer());
            contextMenu.Items.Add(timerMenu);
            
            contextMenu.Items.Add("-");
            contextMenu.Items.Add("退出", null, (s, e) => ExitApplication());

            _notifyIcon.ContextMenuStrip = contextMenu;
        }

        /// <summary>
        /// 显示主窗口
        /// </summary>
        public void ShowMainWindow()
        {
            if (_mainWindow != null)
            {
                _mainWindow.Show();
                _mainWindow.WindowState = WindowState.Normal;
                _mainWindow.Activate();
                
                // 强制显示窗口（不自动隐藏）
                AutoHideService.Instance.ForceShow();
            }
        }

        /// <summary>
        /// 隐藏主窗口到托盘
        /// </summary>
        public void HideMainWindow()
        {
            if (_mainWindow != null)
            {
                _mainWindow.Hide();
            }
        }

        /// <summary>
        /// 切换主窗口显示/隐藏
        /// </summary>
        private void ToggleMainWindow()
        {
            if (_mainWindow != null)
            {
                if (_mainWindow.IsVisible)
                {
                    HideMainWindow();
                }
                else
                {
                    ShowMainWindow();
                }
            }
        }

        /// <summary>
        /// 显示托盘通知
        /// </summary>
        public void ShowNotification(string title, string message, ToolTipIcon icon = ToolTipIcon.Info)
        {
            _notifyIcon?.ShowBalloonTip(3000, title, message, icon);
        }

        /// <summary>
        /// 开始计时器
        /// </summary>
        private void StartTimer()
        {
            if (!TimerService.Instance.IsRunning)
            {
                TimerService.Instance.Start("默认项目");
                ShowNotification("计时器", "工作已开始", ToolTipIcon.Info);
            }
        }

        /// <summary>
        /// 暂停计时器
        /// </summary>
        private void PauseTimer()
        {
            if (TimerService.Instance.IsRunning)
            {
                TimerService.Instance.Pause();
                ShowNotification("计时器", "工作已暂停", ToolTipIcon.Warning);
            }
            else if (TimerService.Instance.CurrentSession != null)
            {
                TimerService.Instance.Resume();
                ShowNotification("计时器", "工作已恢复", ToolTipIcon.Info);
            }
        }

        /// <summary>
        /// 停止计时器
        /// </summary>
        private void StopTimer()
        {
            var session = TimerService.Instance.Stop();
            if (session != null)
            {
                DataService.Instance.AddSession(session);
                ShowNotification("计时器", $"工作完成！时长: {session.FormattedDuration}", ToolTipIcon.Info);
            }
        }

        /// <summary>
        /// 退出应用
        /// </summary>
        private void ExitApplication()
        {
            // 停止计时器
            if (TimerService.Instance.IsRunning)
            {
                var session = TimerService.Instance.Stop();
                if (session != null)
                {
                    DataService.Instance.AddSession(session);
                }
            }

            // 清理资源
            Dispose();

            // 退出应用
            WpfApplication.Current.Shutdown();
        }

        public void Dispose()
        {
            if (_notifyIcon != null)
            {
                _notifyIcon.Visible = false;
                _notifyIcon.Dispose();
                _notifyIcon = null;
            }
        }
    }
}
