using System;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Media.Animation;
using System.Windows.Threading;

namespace WorkHoursTimer.Services
{
    /// <summary>
    /// 自动隐藏服务 - 实现侧边栏滑出效果
    /// </summary>
    public class AutoHideService
    {
        private static AutoHideService? _instance;
        public static AutoHideService Instance => _instance ??= new AutoHideService();

        private Window? _window;
        private DispatcherTimer? _hideTimer;
        private DispatcherTimer? _mouseCheckTimer;
        private bool _isHidden = false;
        private bool _isAnimating = false;
        private double _hiddenLeft;
        private double _visibleLeft;
        private const int PEEK_WIDTH = 5; // 边缘可见宽度
        private const int ANIMATION_DURATION = 200; // 动画时长（毫秒）
        private const int EDGE_TRIGGER_WIDTH = 10; // 边缘触发宽度

        /// <summary>
        /// 是否启用自动隐藏
        /// </summary>
        public bool IsAutoHideEnabled { get; set; } = true;

        // Win32 API - 获取鼠标位置
        [DllImport("user32.dll")]
        private static extern bool GetCursorPos(out POINT lpPoint);

        [StructLayout(LayoutKind.Sequential)]
        private struct POINT
        {
            public int X;
            public int Y;
        }

        private AutoHideService()
        {
        }

        /// <summary>
        /// 初始化自动隐藏服务
        /// </summary>
        public void Initialize(Window window)
        {
            _window = window;
            
            // 计算隐藏和显示位置
            var workArea = SystemParameters.WorkArea;
            _visibleLeft = workArea.Right - window.Width;
            _hiddenLeft = workArea.Right - PEEK_WIDTH;

            // 初始状态：显示（改为显示，方便用户看到）
            _window.Left = _visibleLeft;
            _isHidden = false;

            // 监听鼠标进入/离开事件
            _window.MouseEnter += Window_MouseEnter;
            _window.MouseLeave += Window_MouseLeave;

            // 创建自动隐藏计时器
            _hideTimer = new DispatcherTimer
            {
                Interval = TimeSpan.FromSeconds(3) // 3秒后自动隐藏（给用户更多时间）
            };
            _hideTimer.Tick += HideTimer_Tick;
            
            // 创建鼠标位置检测计时器（每100ms检测一次）
            _mouseCheckTimer = new DispatcherTimer
            {
                Interval = TimeSpan.FromMilliseconds(100)
            };
            _mouseCheckTimer.Tick += MouseCheckTimer_Tick;
            _mouseCheckTimer.Start();
            
            // 启动后 5 秒自动隐藏（给用户时间看到窗口）
            var startupTimer = new DispatcherTimer
            {
                Interval = TimeSpan.FromSeconds(5)
            };
            startupTimer.Tick += (s, e) =>
            {
                startupTimer.Stop();
                if (IsAutoHideEnabled && !_isHidden)
                {
                    HideWindow();
                }
            };
            startupTimer.Start();
        }

        /// <summary>
        /// 鼠标位置检测计时器 - 检测鼠标是否靠近屏幕右侧边缘
        /// </summary>
        private void MouseCheckTimer_Tick(object? sender, EventArgs e)
        {
            if (!IsAutoHideEnabled || _window == null) return;

            // 获取鼠标位置
            if (GetCursorPos(out POINT point))
            {
                var workArea = SystemParameters.WorkArea;
                var screenRight = workArea.Right;

                // 检查鼠标是否在屏幕右侧边缘附近
                bool isNearRightEdge = point.X >= screenRight - EDGE_TRIGGER_WIDTH;

                if (isNearRightEdge && _isHidden && !_isAnimating)
                {
                    // 鼠标靠近右侧边缘，显示窗口
                    ShowWindow();
                }
            }
        }

        /// <summary>
        /// 鼠标进入窗口
        /// </summary>
        private void Window_MouseEnter(object? sender, System.Windows.Input.MouseEventArgs e)
        {
            if (!IsAutoHideEnabled) return;

            // 停止自动隐藏计时器
            _hideTimer?.Stop();

            // 显示窗口
            if (_isHidden && !_isAnimating)
            {
                ShowWindow();
            }
        }

        /// <summary>
        /// 鼠标离开窗口
        /// </summary>
        private void Window_MouseLeave(object? sender, System.Windows.Input.MouseEventArgs e)
        {
            if (!IsAutoHideEnabled) return;

            // 启动自动隐藏计时器
            _hideTimer?.Start();
        }

        /// <summary>
        /// 自动隐藏计时器触发
        /// </summary>
        private void HideTimer_Tick(object? sender, EventArgs e)
        {
            _hideTimer?.Stop();

            // 隐藏窗口
            if (!_isHidden && !_isAnimating)
            {
                HideWindow();
            }
        }

        /// <summary>
        /// 显示窗口（滑入动画）
        /// </summary>
        public void ShowWindow()
        {
            if (_window == null || !_isHidden || _isAnimating) return;

            _isAnimating = true;

            var animation = new DoubleAnimation
            {
                From = _hiddenLeft,
                To = _visibleLeft,
                Duration = TimeSpan.FromMilliseconds(ANIMATION_DURATION),
                EasingFunction = new QuadraticEase { EasingMode = EasingMode.EaseOut }
            };

            animation.Completed += (s, e) =>
            {
                _isHidden = false;
                _isAnimating = false;
            };

            _window.BeginAnimation(Window.LeftProperty, animation);
        }

        /// <summary>
        /// 隐藏窗口（滑出动画）
        /// </summary>
        public void HideWindow()
        {
            if (_window == null || _isHidden || _isAnimating) return;

            _isAnimating = true;

            var animation = new DoubleAnimation
            {
                From = _visibleLeft,
                To = _hiddenLeft,
                Duration = TimeSpan.FromMilliseconds(ANIMATION_DURATION),
                EasingFunction = new QuadraticEase { EasingMode = EasingMode.EaseIn }
            };

            animation.Completed += (s, e) =>
            {
                _isHidden = true;
                _isAnimating = false;
            };

            _window.BeginAnimation(Window.LeftProperty, animation);
        }

        /// <summary>
        /// 切换显示/隐藏
        /// </summary>
        public void Toggle()
        {
            if (_isHidden)
            {
                ShowWindow();
            }
            else
            {
                HideWindow();
            }
        }

        /// <summary>
        /// 强制显示窗口（不自动隐藏）
        /// </summary>
        public void ForceShow()
        {
            _hideTimer?.Stop();
            ShowWindow();
        }

        /// <summary>
        /// 启用/禁用自动隐藏
        /// </summary>
        public void SetAutoHide(bool enabled)
        {
            IsAutoHideEnabled = enabled;
            
            if (!enabled && _isHidden)
            {
                // 如果禁用自动隐藏，显示窗口
                ShowWindow();
            }
        }
    }
}
