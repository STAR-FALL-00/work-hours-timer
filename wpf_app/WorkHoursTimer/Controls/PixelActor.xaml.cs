using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Media.Imaging;
using System.Windows.Threading;
using WpfUserControl = System.Windows.Controls.UserControl;

namespace WorkHoursTimer.Controls
{
    /// <summary>
    /// 像素角色控件 - 用于播放序列帧动画
    /// 完美解决 DataTemplate 绑定问题
    /// </summary>
    public partial class PixelActor : WpfUserControl
    {
        private DispatcherTimer? _timer;
        private int _currentFrameIndex = 0;
        private List<BitmapImage> _cachedBitmaps = new List<BitmapImage>();

        #region Dependency Properties

        /// <summary>
        /// 帧路径列表 - 支持 IEnumerable 绑定
        /// </summary>
        public static readonly DependencyProperty FramePathsProperty =
            DependencyProperty.Register(
                nameof(FramePaths),
                typeof(IEnumerable<string>),
                typeof(PixelActor),
                new PropertyMetadata(null, OnFramePathsChanged));

        public IEnumerable<string>? FramePaths
        {
            get => (IEnumerable<string>?)GetValue(FramePathsProperty);
            set => SetValue(FramePathsProperty, value);
        }

        /// <summary>
        /// 帧间隔（毫秒）
        /// </summary>
        public static readonly DependencyProperty FrameIntervalProperty =
            DependencyProperty.Register(
                nameof(FrameInterval),
                typeof(int),
                typeof(PixelActor),
                new PropertyMetadata(150, OnFrameIntervalChanged));

        public int FrameInterval
        {
            get => (int)GetValue(FrameIntervalProperty);
            set => SetValue(FrameIntervalProperty, value);
        }

        /// <summary>
        /// 是否自动播放
        /// </summary>
        public static readonly DependencyProperty AutoPlayProperty =
            DependencyProperty.Register(
                nameof(AutoPlay),
                typeof(bool),
                typeof(PixelActor),
                new PropertyMetadata(true));

        public bool AutoPlay
        {
            get => (bool)GetValue(AutoPlayProperty);
            set => SetValue(AutoPlayProperty, value);
        }

        #endregion

        public PixelActor()
        {
            InitializeComponent();

            // 初始化定时器
            _timer = new DispatcherTimer
            {
                Interval = TimeSpan.FromMilliseconds(FrameInterval)
            };
            _timer.Tick += (s, e) => UpdateFrame();

            // 窗口卸载时停止
            this.Unloaded += (s, e) => _timer?.Stop();
        }

        /// <summary>
        /// 当帧路径改变时触发
        /// </summary>
        private static void OnFramePathsChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            if (d is PixelActor control)
            {
                control.LoadAndPlay();
            }
        }

        /// <summary>
        /// 当帧间隔改变时触发
        /// </summary>
        private static void OnFrameIntervalChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            if (d is PixelActor control && control._timer != null)
            {
                control._timer.Interval = TimeSpan.FromMilliseconds((int)e.NewValue);
            }
        }

        /// <summary>
        /// 加载图片并开始播放
        /// </summary>
        private void LoadAndPlay()
        {
            _timer?.Stop();
            _cachedBitmaps.Clear();
            _currentFrameIndex = 0;

            if (FramePaths == null || !FramePaths.Any())
            {
                System.Diagnostics.Debug.WriteLine("⚠️ FramePaths 为空或没有元素");
                return;
            }

            System.Diagnostics.Debug.WriteLine($"🎬 开始加载 {FramePaths.Count()} 帧动画");

            // 预加载所有图片到内存，防止闪烁
            foreach (var path in FramePaths)
            {
                try
                {
                    System.Diagnostics.Debug.WriteLine($"📷 尝试加载: {path}");
                    var uri = new Uri(path, UriKind.RelativeOrAbsolute);
                    var bmp = new BitmapImage();
                    bmp.BeginInit();
                    bmp.UriSource = uri;
                    bmp.CacheOption = BitmapCacheOption.OnLoad; // 关键：加载到内存
                    bmp.EndInit();
                    bmp.Freeze(); // 关键：性能优化，设为只读
                    _cachedBitmaps.Add(bmp);
                    System.Diagnostics.Debug.WriteLine($"✅ 加载成功: {path}");
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"❌ 加载帧失败: {path}");
                    System.Diagnostics.Debug.WriteLine($"   错误: {ex.Message}");
                    System.Diagnostics.Debug.WriteLine($"   堆栈: {ex.StackTrace}");
                }
            }

            // 显示第一帧
            if (_cachedBitmaps.Count > 0)
            {
                DisplayImage.Source = _cachedBitmaps[0];
                System.Diagnostics.Debug.WriteLine($"🎮 显示第一帧，共 {_cachedBitmaps.Count} 帧");

                // 只有多帧且自动播放时才启动动画
                if (_cachedBitmaps.Count > 1 && AutoPlay)
                {
                    _timer?.Start();
                    System.Diagnostics.Debug.WriteLine($"▶️ 动画已启动，帧间隔: {FrameInterval}ms");
                }
            }
            else
            {
                System.Diagnostics.Debug.WriteLine("❌ 没有成功加载任何帧");
            }
        }

        /// <summary>
        /// 更新当前帧
        /// </summary>
        private void UpdateFrame()
        {
            if (_cachedBitmaps.Count == 0)
                return;

            _currentFrameIndex = (_currentFrameIndex + 1) % _cachedBitmaps.Count;
            DisplayImage.Source = _cachedBitmaps[_currentFrameIndex];
        }

        /// <summary>
        /// 手动播放
        /// </summary>
        public void Play()
        {
            if (_cachedBitmaps.Count > 1)
            {
                _timer?.Start();
            }
        }

        /// <summary>
        /// 手动停止
        /// </summary>
        public void Stop()
        {
            _timer?.Stop();
            _currentFrameIndex = 0;
            if (_cachedBitmaps.Count > 0)
            {
                DisplayImage.Source = _cachedBitmaps[0];
            }
        }

        /// <summary>
        /// 暂停
        /// </summary>
        public void Pause()
        {
            _timer?.Stop();
        }
    }
}
