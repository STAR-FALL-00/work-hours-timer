using System;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Threading;
using WpfImage = System.Windows.Controls.Image;

namespace WorkHoursTimer.Controls
{
    /// <summary>
    /// 精灵动画控件 - 用于播放 PNG 序列帧动画
    /// </summary>
    public class SpriteAnimationControl : WpfImage
    {
        private DispatcherTimer? _animationTimer;
        private List<BitmapImage> _frames = new List<BitmapImage>();
        private int _currentFrameIndex = 0;

        #region Dependency Properties

        /// <summary>
        /// 帧路径列表
        /// </summary>
        public static readonly DependencyProperty FramePathsProperty =
            DependencyProperty.Register(
                nameof(FramePaths),
                typeof(string[]),
                typeof(SpriteAnimationControl),
                new PropertyMetadata(null, OnFramePathsChanged));

        public string[]? FramePaths
        {
            get => (string[]?)GetValue(FramePathsProperty);
            set => SetValue(FramePathsProperty, value);
        }

        /// <summary>
        /// 帧间隔（毫秒）
        /// </summary>
        public static readonly DependencyProperty FrameIntervalProperty =
            DependencyProperty.Register(
                nameof(FrameInterval),
                typeof(int),
                typeof(SpriteAnimationControl),
                new PropertyMetadata(100));

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
                typeof(SpriteAnimationControl),
                new PropertyMetadata(true, OnAutoPlayChanged));

        public bool AutoPlay
        {
            get => (bool)GetValue(AutoPlayProperty);
            set => SetValue(AutoPlayProperty, value);
        }

        #endregion

        public SpriteAnimationControl()
        {
            // 设置像素缩放模式
            RenderOptions.SetBitmapScalingMode(this, BitmapScalingMode.NearestNeighbor);
            
            // 窗口加载时开始播放
            this.Loaded += (s, e) =>
            {
                if (AutoPlay)
                {
                    Play();
                }
            };

            // 窗口卸载时停止播放
            this.Unloaded += (s, e) => Stop();
        }

        private static void OnFramePathsChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            if (d is SpriteAnimationControl control)
            {
                control.LoadFrames();
            }
        }

        private static void OnAutoPlayChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            if (d is SpriteAnimationControl control && (bool)e.NewValue)
            {
                control.Play();
            }
        }

        /// <summary>
        /// 加载帧图片
        /// </summary>
        private void LoadFrames()
        {
            _frames.Clear();

            if (FramePaths == null || FramePaths.Length == 0)
                return;

            foreach (var path in FramePaths)
            {
                try
                {
                    var bitmap = new BitmapImage();
                    bitmap.BeginInit();
                    bitmap.UriSource = new Uri(path, UriKind.RelativeOrAbsolute);
                    bitmap.CacheOption = BitmapCacheOption.OnLoad;
                    bitmap.EndInit();
                    bitmap.Freeze(); // 冻结以提高性能
                    _frames.Add(bitmap);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"加载帧失败: {path}, 错误: {ex.Message}");
                }
            }

            // 显示第一帧
            if (_frames.Count > 0)
            {
                this.Source = _frames[0];
            }
        }

        /// <summary>
        /// 开始播放动画
        /// </summary>
        public void Play()
        {
            if (_frames.Count == 0)
            {
                LoadFrames();
            }

            if (_frames.Count <= 1)
                return;

            if (_animationTimer == null)
            {
                _animationTimer = new DispatcherTimer
                {
                    Interval = TimeSpan.FromMilliseconds(FrameInterval)
                };
                _animationTimer.Tick += AnimationTimer_Tick;
            }

            _animationTimer.Start();
        }

        /// <summary>
        /// 停止播放动画
        /// </summary>
        public void Stop()
        {
            _animationTimer?.Stop();
            _currentFrameIndex = 0;
            if (_frames.Count > 0)
            {
                this.Source = _frames[0];
            }
        }

        /// <summary>
        /// 暂停播放动画
        /// </summary>
        public void Pause()
        {
            _animationTimer?.Stop();
        }

        /// <summary>
        /// 恢复播放动画
        /// </summary>
        public void Resume()
        {
            _animationTimer?.Start();
        }

        private void AnimationTimer_Tick(object? sender, EventArgs e)
        {
            if (_frames.Count == 0)
                return;

            _currentFrameIndex = (_currentFrameIndex + 1) % _frames.Count;
            this.Source = _frames[_currentFrameIndex];
        }
    }
}
