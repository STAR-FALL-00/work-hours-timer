using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Threading;

namespace WorkHoursTimer.Services
{
    /// <summary>
    /// 战斗状态枚举
    /// </summary>
    public enum BattleState
    {
        Idle,           // 待机
        Approaching,    // 接近
        Fighting,       // 战斗
        Retreating,     // 撤退
        Cooldown        // 冷却
    }

    /// <summary>
    /// 战斗系统服务 - 管理角色移动和战斗逻辑
    /// </summary>
    public class BattleSystemService
    {
        #region 常量定义

        private const double HERO_START_X = 0;
        private const double BOSS_START_X = 184;
        private const double BATTLE_DISTANCE = 50;  // 缩短战斗距离，从100改为50
        private const double HERO_RUN_SPEED = 2.0;  // 降低速度，从3.0改为2.0
        private const double BOSS_MOVE_SPEED = 1.5; // 降低速度，从2.0改为1.5
        private const int MAX_BATTLE_ROUNDS = 5;
        private const int MOVEMENT_FPS = 60;

        #endregion

        #region 事件定义

        public event EventHandler<PositionChangedEventArgs>? HeroPositionChanged;
        public event EventHandler<Position2DChangedEventArgs>? BossPositionChanged;
        public event EventHandler<AnimationChangedEventArgs>? HeroAnimationChanged;
        public event EventHandler<AnimationChangedEventArgs>? BossAnimationChanged;
        public event EventHandler<FlipChangedEventArgs>? HeroFlipChanged;
        public event EventHandler<FlipChangedEventArgs>? BossFlipChanged;
        public event EventHandler<BattleStateChangedEventArgs>? StateChanged;

        #endregion

        #region 私有字段

        private readonly DispatcherTimer _movementTimer;
        private readonly DispatcherTimer _battleTimer;
        private readonly Random _random = new Random();

        private double _heroX = HERO_START_X;
        private double _bossX = BOSS_START_X;
        private double _bossY = 0;
        private double _heroVelocityX = 0;
        private double _bossTargetX = BOSS_START_X;
        private bool _bossIsJumping = false;
        private double _bossJumpStartX = 0;
        private double _bossJumpTargetX = 0;
        private double _bossJumpProgress = 0;
        private const double JUMP_HEIGHT = 40.0;
        private const double JUMP_DURATION = 30; // 帧数
        private int _battleRound = 0;
        private BattleState _currentState = BattleState.Idle;
        private bool _isRunning = false;
        
        // 动画状态缓存，避免重复触发
        private string _currentHeroAnimation = "Idle";
        private string _currentBossAnimation = "Idle";

        #endregion

        #region 公共属性

        public double HeroX => _heroX;
        public double BossX => _bossX;
        public double BossY => _bossY;
        public BattleState CurrentState => _currentState;
        public bool IsRunning => _isRunning;

        #endregion

        public BattleSystemService()
        {
            // 移动定时器 (60 FPS)
            _movementTimer = new DispatcherTimer
            {
                Interval = TimeSpan.FromMilliseconds(1000.0 / MOVEMENT_FPS)
            };
            _movementTimer.Tick += OnMovementTick;

            // 战斗定时器 (每秒一回合)
            _battleTimer = new DispatcherTimer
            {
                Interval = TimeSpan.FromSeconds(1)
            };
            _battleTimer.Tick += OnBattleTick;
        }

        #region 公共方法

        /// <summary>
        /// 启动战斗系统
        /// </summary>
        public void Start()
        {
            if (_isRunning) return;

            _isRunning = true;
            _currentState = BattleState.Idle;
            _heroX = HERO_START_X;
            _bossX = BOSS_START_X;
            _heroVelocityX = 0;

            _movementTimer.Start();
            
            // 延迟开始第一次战斗循环（缩短到 3-5 秒用于测试）
            var delay = GetRandomDelay(3000, 5000);
            Log($"🎮 战斗系统启动 - {delay / 1000} 秒后开始第一次战斗");
            
            DelayedAction(delay, () =>
            {
                if (_isRunning && _currentState == BattleState.Idle)
                {
                    Log("⏰ 延迟结束，开始接近阶段");
                    StartApproachingPhase();
                }
            });
        }

        /// <summary>
        /// 停止战斗系统
        /// </summary>
        public void Stop()
        {
            if (!_isRunning) return;

            _isRunning = false;
            _movementTimer.Stop();
            _battleTimer.Stop();
            _currentState = BattleState.Idle;
            _heroVelocityX = 0;

            Log("⏹️ 战斗系统停止");
        }

        /// <summary>
        /// 重置到初始状态
        /// </summary>
        public void Reset()
        {
            _heroX = HERO_START_X;
            _bossX = BOSS_START_X;
            _bossY = 0;
            _heroVelocityX = 0;
            _bossIsJumping = false;
            _currentState = BattleState.Idle;

            RaiseHeroPositionChanged(_heroX);
            RaiseBossPositionChanged(_bossX, _bossY);
            RaiseHeroAnimationChanged("Idle");
            RaiseBossAnimationChanged("Idle");
            RaiseHeroFlipChanged(false);
            RaiseBossFlipChanged(true);
        }

        #endregion

        #region 移动系统

        /// <summary>
        /// 移动定时器 Tick
        /// </summary>
        private void OnMovementTick(object? sender, EventArgs e)
        {
            if (!_isRunning) return;

            // 更新勇者位置
            _heroX += _heroVelocityX;
            _heroX = Math.Max(0, Math.Min(BOSS_START_X, _heroX));
            if (_heroVelocityX != 0)
                RaiseHeroPositionChanged(_heroX);

            // 更新 Boss 跳跃
            if (_bossIsJumping)
            {
                UpdateBossJump();
            }

            // 根据状态更新
            switch (_currentState)
            {
                case BattleState.Approaching:
                    UpdateApproachingPhase();
                    break;

                case BattleState.Retreating:
                    UpdateRetreatingPhase();
                    break;
            }
        }

        /// <summary>
        /// 更新 Boss 跳跃（抛物线）
        /// </summary>
        private void UpdateBossJump()
        {
            _bossJumpProgress++;

            // 计算进度 (0 到 1)
            var progress = _bossJumpProgress / JUMP_DURATION;

            if (progress >= 1.0)
            {
                // 跳跃结束 - 确保落地
                _bossIsJumping = false;
                _bossX = _bossJumpTargetX;
                _bossY = 0;  // 重要：确保Y坐标归零
                _bossJumpProgress = 0;
                RaiseBossPositionChanged(_bossX, _bossY);
                RaiseBossAnimationChanged("Idle");  // 落地后切换到待机动画
                Log($"  跳跃完成 - 位置: {_bossX:F0}, 已落地");
                return;
            }

            // 水平位置：线性插值
            _bossX = _bossJumpStartX + (_bossJumpTargetX - _bossJumpStartX) * progress;

            // 垂直位置：抛物线 (y = -4h * (x - 0.5)^2 + h)
            var normalizedX = progress;
            _bossY = -4 * JUMP_HEIGHT * Math.Pow(normalizedX - 0.5, 2) + JUMP_HEIGHT;

            RaiseBossPositionChanged(_bossX, _bossY);
        }

        /// <summary>
        /// 开始 Boss 跳跃
        /// </summary>
        private void StartBossJump(double targetX)
        {
            _bossIsJumping = true;
            _bossJumpStartX = _bossX;
            _bossJumpTargetX = Math.Max(0, Math.Min(BOSS_START_X, targetX));
            _bossJumpProgress = 0;
            RaiseBossFlipChanged(_bossJumpTargetX < _bossX);
            RaiseBossAnimationChanged("JumpStart");
            Log($"  Boss 开始跳跃: {_bossJumpStartX:F0} → {_bossJumpTargetX:F0}");
        }

        /// <summary>
        /// 开始接近阶段
        /// </summary>
        private void StartApproachingPhase()
        {
            ChangeState(BattleState.Approaching);

            // Boss 选择随机目标位置并跳跃过去
            _bossTargetX = _random.Next(50, 180);
            StartBossJump(_bossTargetX);

            Log($"🎯 接近阶段 - Boss跳跃到: {_bossTargetX:F0}");
        }

        /// <summary>
        /// 更新接近阶段
        /// </summary>
        private void UpdateApproachingPhase()
        {
            // Boss 跳跃逻辑
            if (!_bossIsJumping)
            {
                // 跳跃完成后，短暂待机
                // 20% 概率继续跳跃（降低频率，从30%改为20%）
                if (_random.NextDouble() < 0.2)
                {
                    _bossTargetX = _random.Next(50, 180);
                    StartBossJump(_bossTargetX);
                }
            }

            // 勇者追击逻辑
            var distance = Math.Abs(_bossX - _heroX);

            if (distance > BATTLE_DISTANCE)
            {
                // 距离远，跑步追击
                var newVelocity = _bossX > _heroX ? HERO_RUN_SPEED : -HERO_RUN_SPEED;
                if (Math.Abs(_heroVelocityX - newVelocity) > 0.01)  // 只在速度变化时更新
                {
                    _heroVelocityX = newVelocity;
                    RaiseHeroAnimationChanged("Run");
                    RaiseHeroFlipChanged(_heroVelocityX < 0);
                }
                else
                {
                    _heroVelocityX = newVelocity;
                }
            }
            else
            {
                // 距离近，进入战斗
                _heroVelocityX = 0;
                StartFightingPhase();
            }
        }

        #endregion

        #region 战斗系统

        /// <summary>
        /// 开始战斗阶段
        /// </summary>
        private void StartFightingPhase()
        {
            ChangeState(BattleState.Fighting);
            _battleRound = 0;

            // 停止移动和跳跃
            _heroVelocityX = 0;
            _bossIsJumping = false;
            _bossY = 0;

            // 面对面
            RaiseHeroFlipChanged(_bossX < _heroX);
            RaiseBossFlipChanged(_heroX > _bossX);

            // 开始战斗定时器
            _battleTimer.Start();

            Log($"⚔️ 战斗开始！");
        }

        /// <summary>
        /// 战斗定时器 Tick
        /// </summary>
        private void OnBattleTick(object? sender, EventArgs e)
        {
            if (_currentState != BattleState.Fighting)
            {
                _battleTimer.Stop();
                return;
            }

            _battleRound++;

            if (_battleRound > MAX_BATTLE_ROUNDS)
            {
                // 战斗结束
                _battleTimer.Stop();
                StartRetreatingPhase();
                return;
            }

            // 执行战斗回合
            ExecuteBattleRound();
        }

        /// <summary>
        /// 执行战斗回合
        /// </summary>
        private void ExecuteBattleRound()
        {
            var action = _random.NextDouble();

            if (action < 0.7) // 70% 勇者攻击
            {
                // 勇者攻击
                if (_random.NextDouble() < 0.6)
                {
                    RaiseHeroAnimationChanged("Attack1");
                    Log($"  回合{_battleRound}: 勇者普通攻击");
                }
                else
                {
                    RaiseHeroAnimationChanged("Attack2");
                    Log($"  回合{_battleRound}: 勇者重击");
                }

                // Boss 受击
                RaiseBossAnimationChanged("Hurt");
            }
            else // 30% Boss 反击
            {
                // Boss 冲撞
                RaiseBossAnimationChanged("JumpStart");
                Log($"  回合{_battleRound}: Boss 冲撞");

                // 勇者反应
                if (_random.NextDouble() < 0.5)
                {
                    // 格挡
                    RaiseHeroAnimationChanged("Block");
                    Log($"    勇者格挡");

                    // 延迟执行击退
                    DelayedAction(300, () =>
                    {
                        if (_currentState == BattleState.Fighting)
                        {
                            PerformKnockback(30);
                        }
                    });
                }
                else
                {
                    // 翻滚
                    RaiseHeroAnimationChanged("Roll");
                    Log($"    勇者翻滚");

                    // 延迟执行翻滚
                    DelayedAction(300, () =>
                    {
                        if (_currentState == BattleState.Fighting)
                        {
                            PerformRoll(50);
                        }
                    });
                }
            }
        }

        /// <summary>
        /// 执行击退效果
        /// </summary>
        private void PerformKnockback(double distance)
        {
            var originalX = _heroX;
            var targetX = Math.Max(0, _heroX - distance);

            // 后退
            AnimatePosition(
                () => _heroX,
                x =>
                {
                    _heroX = x;
                    RaiseHeroPositionChanged(x);
                },
                targetX,
                20,
                () =>
                {
                    // 跑回来
                    RaiseHeroAnimationChanged("Run");
                    AnimatePosition(
                        () => _heroX,
                        x =>
                        {
                            _heroX = x;
                            RaiseHeroPositionChanged(x);
                        },
                        originalX,
                        20,
                        () => RaiseHeroAnimationChanged("Idle")
                    );
                }
            );
        }

        /// <summary>
        /// 执行翻滚效果
        /// </summary>
        private void PerformRoll(double distance)
        {
            var originalX = _heroX;
            var targetX = Math.Max(0, _heroX - distance);

            // 翻滚
            AnimatePosition(
                () => _heroX,
                x =>
                {
                    _heroX = x;
                    RaiseHeroPositionChanged(x);
                },
                targetX,
                15,
                () =>
                {
                    // 跑回来
                    RaiseHeroAnimationChanged("Run");
                    AnimatePosition(
                        () => _heroX,
                        x =>
                        {
                            _heroX = x;
                            RaiseHeroPositionChanged(x);
                        },
                        originalX,
                        20,
                        () => RaiseHeroAnimationChanged("Idle")
                    );
                }
            );
        }

        #endregion

        #region 撤退和冷却

        /// <summary>
        /// 开始撤退阶段
        /// </summary>
        private void StartRetreatingPhase()
        {
            ChangeState(BattleState.Retreating);

            // Boss 跳跃逃跑
            StartBossJump(BOSS_START_X);

            // 勇者待机
            RaiseHeroAnimationChanged("Idle");
            _heroVelocityX = 0;

            Log($"🏃 Boss 撤退！");
        }

        /// <summary>
        /// 更新撤退阶段
        /// </summary>
        private void UpdateRetreatingPhase()
        {
            if (!_bossIsJumping)
            {
                RaiseBossAnimationChanged("Idle");
                RaiseBossFlipChanged(true);
                StartCooldownPhase();
            }
        }

        /// <summary>
        /// 开始冷却阶段
        /// </summary>
        private void StartCooldownPhase()
        {
            ChangeState(BattleState.Cooldown);

            // 勇者回到起点
            RaiseHeroAnimationChanged("Run");
            AnimatePosition(
                () => _heroX,
                x =>
                {
                    _heroX = x;
                    RaiseHeroPositionChanged(x);
                },
                HERO_START_X,
                30,
                () =>
                {
                    RaiseHeroAnimationChanged("Idle");
                    RaiseHeroFlipChanged(false);
                    StartIdlePhase();
                }
            );

            Log($"💤 冷却阶段");
        }

        /// <summary>
        /// 开始待机阶段
        /// </summary>
        private void StartIdlePhase()
        {
            ChangeState(BattleState.Idle);

            // 延迟开始下一次战斗（缩短到 5-10 秒用于测试）
            var delay = GetRandomDelay(5000, 10000);
            Log($"⏰ 待机 {delay / 1000} 秒后开始下一轮");

            DelayedAction(delay, () =>
            {
                if (_isRunning && _currentState == BattleState.Idle)
                {
                    Log("⏰ 待机结束，开始下一轮战斗");
                    StartApproachingPhase();
                }
            });
        }

        #endregion

        #region 辅助方法

        /// <summary>
        /// 位置动画
        /// </summary>
        private void AnimatePosition(Func<double> getter, Action<double> setter, double target, int steps, Action? onComplete = null)
        {
            var start = getter();
            var distance = target - start;
            var step = 0;

            var timer = new DispatcherTimer { Interval = TimeSpan.FromMilliseconds(16) };
            timer.Tick += (s, e) =>
            {
                step++;
                var progress = (double)step / steps;
                setter(start + distance * progress);

                if (step >= steps)
                {
                    timer.Stop();
                    setter(target);
                    onComplete?.Invoke();
                }
            };
            timer.Start();
        }

        /// <summary>
        /// 延迟执行
        /// </summary>
        private void DelayedAction(int milliseconds, Action action)
        {
            Log($"⏱️ 设置延迟执行: {milliseconds}ms");
            System.Threading.Tasks.Task.Delay(milliseconds).ContinueWith(_ =>
            {
                Log($"⏱️ 延迟 {milliseconds}ms 结束，准备执行回调");
                try
                {
                    System.Windows.Application.Current?.Dispatcher.Invoke(() =>
                    {
                        Log($"⏱️ 在 UI 线程执行回调");
                        action();
                        Log($"⏱️ 回调执行完成");
                    });
                }
                catch (Exception ex)
                {
                    Log($"❌ 延迟执行出错: {ex.Message}");
                }
            });
        }

        /// <summary>
        /// 获取随机延迟
        /// </summary>
        private int GetRandomDelay(int min, int max)
        {
            return _random.Next(min, max);
        }

        /// <summary>
        /// 改变状态
        /// </summary>
        private void ChangeState(BattleState newState)
        {
            if (_currentState != newState)
            {
                _currentState = newState;
                StateChanged?.Invoke(this, new BattleStateChangedEventArgs(newState));
            }
        }

        /// <summary>
        /// 日志输出
        /// </summary>
        private void Log(string message)
        {
            System.Diagnostics.Debug.WriteLine($"[BattleSystem] {message}");
        }

        #endregion

        #region 事件触发方法

        private void RaiseHeroPositionChanged(double x)
        {
            HeroPositionChanged?.Invoke(this, new PositionChangedEventArgs(x));
        }

        private void RaiseBossPositionChanged(double x, double y)
        {
            BossPositionChanged?.Invoke(this, new Position2DChangedEventArgs(x, y));
        }

        private void RaiseHeroAnimationChanged(string animation)
        {
            if (_currentHeroAnimation != animation)
            {
                _currentHeroAnimation = animation;
                HeroAnimationChanged?.Invoke(this, new AnimationChangedEventArgs(animation));
            }
        }

        private void RaiseBossAnimationChanged(string animation)
        {
            if (_currentBossAnimation != animation)
            {
                _currentBossAnimation = animation;
                BossAnimationChanged?.Invoke(this, new AnimationChangedEventArgs(animation));
            }
        }

        private void RaiseHeroFlipChanged(bool flipped)
        {
            HeroFlipChanged?.Invoke(this, new FlipChangedEventArgs(flipped));
        }

        private void RaiseBossFlipChanged(bool flipped)
        {
            BossFlipChanged?.Invoke(this, new FlipChangedEventArgs(flipped));
        }

        #endregion
    }

    #region 事件参数类

    public class PositionChangedEventArgs : EventArgs
    {
        public double X { get; }
        public PositionChangedEventArgs(double x) => X = x;
    }

    public class Position2DChangedEventArgs : EventArgs
    {
        public double X { get; }
        public double Y { get; }
        public Position2DChangedEventArgs(double x, double y)
        {
            X = x;
            Y = y;
        }
    }

    public class AnimationChangedEventArgs : EventArgs
    {
        public string Animation { get; }
        public AnimationChangedEventArgs(string animation) => Animation = animation;
    }

    public class FlipChangedEventArgs : EventArgs
    {
        public bool Flipped { get; }
        public FlipChangedEventArgs(bool flipped) => Flipped = flipped;
    }

    public class BattleStateChangedEventArgs : EventArgs
    {
        public BattleState State { get; }
        public BattleStateChangedEventArgs(BattleState state) => State = state;
    }

    #endregion
}
