using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Windows.Interop;

namespace WorkHoursTimer.Services
{
    /// <summary>
    /// 全局快捷键服务
    /// </summary>
    public class HotkeyService : IDisposable
    {
        private static HotkeyService? _instance;
        public static HotkeyService Instance => _instance ??= new HotkeyService();

        // Win32 API
        [DllImport("user32.dll")]
        private static extern bool RegisterHotKey(IntPtr hWnd, int id, uint fsModifiers, uint vk);

        [DllImport("user32.dll")]
        private static extern bool UnregisterHotKey(IntPtr hWnd, int id);

        // 修饰键常量
        private const uint MOD_ALT = 0x0001;
        private const uint MOD_CONTROL = 0x0002;
        private const uint MOD_SHIFT = 0x0004;
        private const uint MOD_WIN = 0x0008;
        private const uint MOD_NOREPEAT = 0x4000;

        // 虚拟键码
        private const uint VK_S = 0x53;
        private const uint VK_E = 0x45;
        private const uint VK_H = 0x48;
        private const uint VK_W = 0x57;

        // 快捷键 ID
        private const int HOTKEY_START_PAUSE = 1;
        private const int HOTKEY_STOP = 2;
        private const int HOTKEY_TOGGLE_MAIN = 3;
        private const int HOTKEY_TOGGLE_WIDGET = 4;

        private IntPtr _windowHandle;
        private HwndSource? _source;
        private readonly Dictionary<int, Action> _hotkeyActions = new();

        /// <summary>
        /// 快捷键触发事件
        /// </summary>
        public event EventHandler<HotkeyEventArgs>? HotkeyPressed;

        private HotkeyService()
        {
        }

        /// <summary>
        /// 初始化快捷键服务
        /// </summary>
        public void Initialize(System.Windows.Window window)
        {
            _windowHandle = new WindowInteropHelper(window).Handle;
            _source = HwndSource.FromHwnd(_windowHandle);
            _source?.AddHook(WndProc);

            // 注册默认快捷键
            RegisterDefaultHotkeys();
        }

        /// <summary>
        /// 注册默认快捷键
        /// </summary>
        private void RegisterDefaultHotkeys()
        {
            try
            {
                // Ctrl+Alt+S: 开始/暂停工作
                RegisterHotKey(_windowHandle, HOTKEY_START_PAUSE, 
                    MOD_CONTROL | MOD_ALT | MOD_NOREPEAT, VK_S);
                _hotkeyActions[HOTKEY_START_PAUSE] = OnStartPauseHotkey;

                // Ctrl+Alt+E: 停止工作
                RegisterHotKey(_windowHandle, HOTKEY_STOP, 
                    MOD_CONTROL | MOD_ALT | MOD_NOREPEAT, VK_E);
                _hotkeyActions[HOTKEY_STOP] = OnStopHotkey;

                // Ctrl+Alt+H: 显示/隐藏主窗口
                RegisterHotKey(_windowHandle, HOTKEY_TOGGLE_MAIN, 
                    MOD_CONTROL | MOD_ALT | MOD_NOREPEAT, VK_H);
                _hotkeyActions[HOTKEY_TOGGLE_MAIN] = OnToggleMainWindowHotkey;

                // Ctrl+Alt+W: 显示/隐藏挂件窗口
                RegisterHotKey(_windowHandle, HOTKEY_TOGGLE_WIDGET, 
                    MOD_CONTROL | MOD_ALT | MOD_NOREPEAT, VK_W);
                _hotkeyActions[HOTKEY_TOGGLE_WIDGET] = OnToggleWidgetHotkey;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"注册快捷键失败: {ex.Message}");
            }
        }

        /// <summary>
        /// 窗口消息处理
        /// </summary>
        private IntPtr WndProc(IntPtr hwnd, int msg, IntPtr wParam, IntPtr lParam, ref bool handled)
        {
            const int WM_HOTKEY = 0x0312;

            if (msg == WM_HOTKEY)
            {
                int hotkeyId = wParam.ToInt32();
                
                if (_hotkeyActions.TryGetValue(hotkeyId, out var action))
                {
                    action?.Invoke();
                    
                    // 触发事件
                    HotkeyPressed?.Invoke(this, new HotkeyEventArgs
                    {
                        HotkeyId = hotkeyId,
                        HotkeyName = GetHotkeyName(hotkeyId)
                    });
                }

                handled = true;
            }

            return IntPtr.Zero;
        }

        /// <summary>
        /// 获取快捷键名称
        /// </summary>
        private string GetHotkeyName(int hotkeyId)
        {
            return hotkeyId switch
            {
                HOTKEY_START_PAUSE => "开始/暂停工作",
                HOTKEY_STOP => "停止工作",
                HOTKEY_TOGGLE_MAIN => "显示/隐藏主窗口",
                HOTKEY_TOGGLE_WIDGET => "显示/隐藏挂件",
                _ => "未知快捷键"
            };
        }

        /// <summary>
        /// 开始/暂停工作快捷键
        /// </summary>
        private void OnStartPauseHotkey()
        {
            var timerService = TimerService.Instance;
            
            if (timerService.CurrentSession == null)
            {
                // 没有会话，开始工作
                timerService.Start();
                TrayIconService.Instance.ShowNotification(
                    "快捷键", 
                    "工作已开始 (Ctrl+Alt+S)", 
                    System.Windows.Forms.ToolTipIcon.Info
                );
            }
            else if (timerService.IsRunning)
            {
                // 正在运行，暂停
                timerService.Pause();
                TrayIconService.Instance.ShowNotification(
                    "快捷键", 
                    "工作已暂停 (Ctrl+Alt+S)", 
                    System.Windows.Forms.ToolTipIcon.Warning
                );
            }
            else
            {
                // 已暂停，恢复
                timerService.Resume();
                TrayIconService.Instance.ShowNotification(
                    "快捷键", 
                    "工作已恢复 (Ctrl+Alt+S)", 
                    System.Windows.Forms.ToolTipIcon.Info
                );
            }
        }

        /// <summary>
        /// 停止工作快捷键
        /// </summary>
        private void OnStopHotkey()
        {
            var timerService = TimerService.Instance;
            
            if (timerService.CurrentSession != null)
            {
                var session = timerService.Stop();
                if (session != null)
                {
                    DataService.Instance.AddSession(session);
                    
                    // 更新项目统计
                    var project = ProjectService.Instance.CurrentProject;
                    if (project != null)
                    {
                        ProjectService.Instance.UpdateProjectStats(project.Id, session.DurationSeconds);
                    }
                    
                    TrayIconService.Instance.ShowNotification(
                        "快捷键", 
                        $"工作完成！时长: {session.FormattedDuration} (Ctrl+Alt+E)", 
                        System.Windows.Forms.ToolTipIcon.Info
                    );
                }
            }
        }

        /// <summary>
        /// 显示/隐藏主窗口快捷键
        /// </summary>
        private void OnToggleMainWindowHotkey()
        {
            var mainWindow = System.Windows.Application.Current.MainWindow;
            
            if (mainWindow != null)
            {
                if (mainWindow.IsVisible)
                {
                    TrayIconService.Instance.HideMainWindow();
                    TrayIconService.Instance.ShowNotification(
                        "快捷键", 
                        "主窗口已隐藏 (Ctrl+Alt+H)", 
                        System.Windows.Forms.ToolTipIcon.Info
                    );
                }
                else
                {
                    TrayIconService.Instance.ShowMainWindow();
                    TrayIconService.Instance.ShowNotification(
                        "快捷键", 
                        "主窗口已显示 (Ctrl+Alt+H)", 
                        System.Windows.Forms.ToolTipIcon.Info
                    );
                }
            }
        }

        /// <summary>
        /// 显示/隐藏挂件快捷键
        /// </summary>
        private void OnToggleWidgetHotkey()
        {
            // 通过消息系统通知主窗口切换挂件显示
            WindowMessenger.Instance.SendMessage("TOGGLE_WIDGET", new
            {
                Source = "Hotkey",
                Key = "Ctrl+Alt+W"
            });
            
            TrayIconService.Instance.ShowNotification(
                "快捷键", 
                "切换挂件显示 (Ctrl+Alt+W)", 
                System.Windows.Forms.ToolTipIcon.Info
            );
        }

        /// <summary>
        /// 注销所有快捷键
        /// </summary>
        public void UnregisterAll()
        {
            try
            {
                UnregisterHotKey(_windowHandle, HOTKEY_START_PAUSE);
                UnregisterHotKey(_windowHandle, HOTKEY_STOP);
                UnregisterHotKey(_windowHandle, HOTKEY_TOGGLE_MAIN);
                UnregisterHotKey(_windowHandle, HOTKEY_TOGGLE_WIDGET);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"注销快捷键失败: {ex.Message}");
            }
        }

        public void Dispose()
        {
            UnregisterAll();
            
            if (_source != null)
            {
                _source.RemoveHook(WndProc);
                _source = null;
            }
        }
    }

    /// <summary>
    /// 快捷键事件参数
    /// </summary>
    public class HotkeyEventArgs : EventArgs
    {
        public int HotkeyId { get; set; }
        public string HotkeyName { get; set; } = string.Empty;
    }
}
