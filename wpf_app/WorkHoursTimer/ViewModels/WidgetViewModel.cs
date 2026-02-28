using CommunityToolkit.Mvvm.ComponentModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Threading;
using WorkHoursTimer.Services;

namespace WorkHoursTimer.ViewModels
{
    /// <summary>
    /// 挂件窗口视图模型 - 带完整战斗系统
    /// </summary>
    public partial class WidgetViewModel : ObservableObject
    {
        #region 基础属性

        [ObservableProperty]
        private string _timerText = "00:00:00";

        [ObservableProperty]
        private string _statusText = "🔓 可拖拽";

        [ObservableProperty]
        private string _currentSkin = "boss_battle";

        [ObservableProperty]
        private double _bossHealth = 100.0;

        [ObservableProperty]
        private double _heroProgress = 0.0;

        [ObservableProperty]
        private int _goldEarned = 0;

        [ObservableProperty]
        private int _expGained = 0;

        [ObservableProperty]
        private bool _isWorking = false;

        #endregion

        #region 位置和翻转属性

        [ObservableProperty]
        private double _heroX = 0;

        [ObservableProperty]
        private double _bossX = 184;

        [ObservableProperty]
        private double _bossY = 0;

        [ObservableProperty]
        private bool _heroFlipped = false;

        [ObservableProperty]
        private bool _bossFlipped = true;

        #endregion

        #region 动画帧属性

        [ObservableProperty]
        private IEnumerable<string> _heroFrames;

        [ObservableProperty]
        private IEnumerable<string> _bossFrames;

        [ObservableProperty]
        private IEnumerable<string> _coinFrames;

        [ObservableProperty]
        private IEnumerable<string> _catFrames;

        #endregion

        #region 动画帧定义

        private readonly Dictionary<string, IEnumerable<string>> _heroAnimations;
        private readonly Dictionary<string, IEnumerable<string>> _bossAnimations;
        private readonly IEnumerable<string> _coinIdleFrames;
        private readonly IEnumerable<string> _catRunFrames;

        #endregion

        #region 战斗系统

        private readonly BattleSystemService _battleSystem;
        private readonly DispatcherTimer _healthUpdateTimer;

        #endregion

        public WidgetViewModel()
        {
            // 初始化勇者动画
            _heroAnimations = new Dictionary<string, IEnumerable<string>>
            {
                ["Idle"] = Enumerable.Range(0, 8)
                    .Select(i => $"pack://application:,,,/Assets/Images/Hero/Hero Knight/Sprites/HeroKnight/Idle/HeroKnight_Idle_{i}.png")
                    .ToArray(),
                ["Attack1"] = Enumerable.Range(0, 6)
                    .Select(i => $"pack://application:,,,/Assets/Images/Hero/Hero Knight/Sprites/HeroKnight/Attack1/HeroKnight_Attack1_{i}.png")
                    .ToArray(),
                ["Attack2"] = Enumerable.Range(0, 6)
                    .Select(i => $"pack://application:,,,/Assets/Images/Hero/Hero Knight/Sprites/HeroKnight/Attack2/HeroKnight_Attack2_{i}.png")
                    .ToArray(),
                ["Run"] = Enumerable.Range(0, 10)
                    .Select(i => $"pack://application:,,,/Assets/Images/Hero/Hero Knight/Sprites/HeroKnight/Run/HeroKnight_Run_{i}.png")
                    .ToArray(),
                ["Roll"] = Enumerable.Range(0, 9)
                    .Select(i => $"pack://application:,,,/Assets/Images/Hero/Hero Knight/Sprites/HeroKnight/Roll/HeroKnight_Roll_{i}.png")
                    .ToArray(),
                ["Block"] = Enumerable.Range(0, 5)
                    .Select(i => $"pack://application:,,,/Assets/Images/Hero/Hero Knight/Sprites/HeroKnight/Block/HeroKnight_Block_{i}.png")
                    .ToArray()
            };

            // 初始化 Boss 动画
            _bossAnimations = new Dictionary<string, IEnumerable<string>>
            {
                ["Idle"] = Enumerable.Range(0, 7)
                    .Select(i => $"pack://application:,,,/Assets/Images/Boss/Slime Enemy/Idle/Frames/frame_{i}.png")
                    .ToArray(),
                ["Hurt"] = Enumerable.Range(0, 11)
                    .Select(i => $"pack://application:,,,/Assets/Images/Boss/Slime Enemy/Hurt/Frames/frame_{i}.png")
                    .ToArray(),
                ["JumpStart"] = Enumerable.Range(0, 9)
                    .Select(i => $"pack://application:,,,/Assets/Images/Boss/Slime Enemy/Jump/Frames/Start/frame_{i}.png")
                    .ToArray()
            };

            _coinIdleFrames = new[] { "pack://application:,,,/Assets/Images/Effects/SpinningCoin/Spinning Coin.png" };
            _catRunFrames = new[] { "pack://application:,,,/Assets/Images/Cat/Tile32x32_2/Tile.png" };

            // 设置初始动画
            _heroFrames = _heroAnimations["Idle"];
            _bossFrames = _bossAnimations["Idle"];
            _coinFrames = _coinIdleFrames;
            _catFrames = _catRunFrames;

            // 初始化战斗系统
            System.Diagnostics.Debug.WriteLine("[WidgetViewModel] 初始化战斗系统");
            _battleSystem = new BattleSystemService();
            _battleSystem.HeroPositionChanged += OnHeroPositionChanged;
            _battleSystem.BossPositionChanged += OnBossPositionChanged;
            _battleSystem.HeroAnimationChanged += OnHeroAnimationChanged;
            _battleSystem.BossAnimationChanged += OnBossAnimationChanged;
            _battleSystem.HeroFlipChanged += OnHeroFlipChanged;
            _battleSystem.BossFlipChanged += OnBossFlipChanged;
            System.Diagnostics.Debug.WriteLine("[WidgetViewModel] 战斗系统初始化完成");

            // 订阅窗口消息
            System.Diagnostics.Debug.WriteLine("[WidgetViewModel] 订阅窗口消息");
            WindowMessenger.Instance.MessageReceived += OnMessageReceived;
            System.Diagnostics.Debug.WriteLine("[WidgetViewModel] WidgetViewModel 构造完成");

            // 初始化血条更新定时器（每秒更新一次）
            _healthUpdateTimer = new DispatcherTimer
            {
                Interval = TimeSpan.FromSeconds(1)
            };
            _healthUpdateTimer.Tick += (s, e) => UpdateBossHealthByTime();
            _healthUpdateTimer.Start();
            
            // 立即更新一次血条
            UpdateBossHealthByTime();
        }

        #region 战斗系统事件处理

        private void OnHeroPositionChanged(object? sender, PositionChangedEventArgs e)
        {
            HeroX = e.X;
        }

        private void OnBossPositionChanged(object? sender, Position2DChangedEventArgs e)
        {
            BossX = e.X;
            BossY = e.Y;
        }

        private void OnHeroAnimationChanged(object? sender, AnimationChangedEventArgs e)
        {
            if (_heroAnimations.TryGetValue(e.Animation, out var frames))
            {
                HeroFrames = frames;
            }
        }

        private void OnBossAnimationChanged(object? sender, AnimationChangedEventArgs e)
        {
            if (_bossAnimations.TryGetValue(e.Animation, out var frames))
            {
                BossFrames = frames;
            }
        }

        private void OnHeroFlipChanged(object? sender, FlipChangedEventArgs e)
        {
            HeroFlipped = e.Flipped;
        }

        private void OnBossFlipChanged(object? sender, FlipChangedEventArgs e)
        {
            BossFlipped = e.Flipped;
        }

        #endregion

        #region 窗口消息处理

        private void OnMessageReceived(object? sender, MessageEventArgs e)
        {
            System.Diagnostics.Debug.WriteLine($"[WidgetViewModel] 收到消息: {e.Type}");
            
            switch (e.Type)
            {
                case "TIMER_STARTED":
                    System.Diagnostics.Debug.WriteLine("[WidgetViewModel] 处理 TIMER_STARTED");
                    IsWorking = true;
                    StatusText = "▶️ 开始工作";
                    System.Diagnostics.Debug.WriteLine("[WidgetViewModel] 调用 _battleSystem.Start()");
                    _battleSystem.Start();
                    System.Diagnostics.Debug.WriteLine("[WidgetViewModel] _battleSystem.Start() 完成");
                    break;

                case "TIMER_TICK":
                    if (e.Data != null)
                    {
                        var data = System.Text.Json.JsonSerializer.Deserialize<System.Text.Json.JsonElement>(
                            System.Text.Json.JsonSerializer.Serialize(e.Data));

                        if (data.TryGetProperty("FormattedDuration", out var duration))
                        {
                            TimerText = duration.GetString() ?? "00:00:00";
                        }

                        if (data.TryGetProperty("TotalSeconds", out var seconds))
                        {
                            UpdateProgress(seconds.GetInt32());
                        }
                    }
                    break;

                case "TIMER_STOPPED":
                    IsWorking = false;
                    TimerText = "00:00:00";
                    StatusText = "⏹️ 已停止";
                    _battleSystem.Stop();
                    ResetProgress();
                    break;

                case "TIMER_PAUSED":
                    IsWorking = false;
                    StatusText = "⏸️ 已暂停";
                    _battleSystem.Stop();
                    break;

                case "TIMER_RESUMED":
                    IsWorking = true;
                    StatusText = "▶️ 继续工作";
                    _battleSystem.Start();
                    break;

                case "SWITCH_SKIN":
                    if (e.Data != null)
                    {
                        var data = System.Text.Json.JsonSerializer.Deserialize<System.Text.Json.JsonElement>(
                            System.Text.Json.JsonSerializer.Serialize(e.Data));

                        if (data.TryGetProperty("skin_id", out var skinId))
                        {
                            CurrentSkin = skinId.GetString() ?? "boss_battle";
                        }
                    }
                    break;

                case "UPDATE_RESOURCES":
                    if (e.Data != null)
                    {
                        var data = System.Text.Json.JsonSerializer.Deserialize<System.Text.Json.JsonElement>(
                            System.Text.Json.JsonSerializer.Serialize(e.Data));

                        if (data.TryGetProperty("gold", out var gold))
                        {
                            GoldEarned = gold.GetInt32();
                        }

                        if (data.TryGetProperty("exp", out var exp))
                        {
                            ExpGained = exp.GetInt32();
                        }
                    }
                    break;

                case "WORK_TIME_CHANGED":
                    System.Diagnostics.Debug.WriteLine("[WidgetViewModel] 工作时间已更新，立即刷新血条");
                    UpdateBossHealthByTime();
                    break;
            }
        }

        #endregion

        #region 进度更新

        /// <summary>
        /// 根据当前时间更新 Boss 血量（使用设置中的工作时间）
        /// </summary>
        private void UpdateBossHealthByTime()
        {
            var settings = DataService.Instance.AppData.Settings;
            var now = DateTime.Now;
            var workStartTime = new DateTime(now.Year, now.Month, now.Day, settings.WorkStartHour, 0, 0);
            var workEndTime = new DateTime(now.Year, now.Month, now.Day, settings.WorkEndHour, 0, 0);
            var totalWorkSeconds = (workEndTime - workStartTime).TotalSeconds;

            if (now >= workStartTime && now <= workEndTime)
            {
                // 工作时间内，血量随时间减少
                var elapsedSeconds = (now - workStartTime).TotalSeconds;
                var progress = elapsedSeconds / totalWorkSeconds;
                BossHealth = Math.Max(0, 100 - (progress * 100));
            }
            else if (now > workEndTime)
            {
                // 下班后，血量为 0
                BossHealth = 0;
            }
            else
            {
                // 上班前，血量满
                BossHealth = 100;
            }
        }

        private void UpdateProgress(int totalSeconds)
        {
            // Boss 血量由定时器独立更新，这里不再处理
            
            // Hero 进度
            var targetHours = 9.0;
            var currentHours = totalSeconds / 3600.0;
            HeroProgress = Math.Min(100, (currentHours / targetHours * 100));

            // 计算收益
            GoldEarned = (int)(currentHours * 100);
            ExpGained = (int)(currentHours * 50);
        }

        private void ResetProgress()
        {
            // Boss 血量由定时器独立更新，不重置
            HeroProgress = 0.0;
            _battleSystem.Reset();
        }

        #endregion

        #region 公共方法

        public void UpdateStatus(string status)
        {
            StatusText = status;
        }

        #endregion
    }
}
