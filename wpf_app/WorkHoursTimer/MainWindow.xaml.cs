using System;
using System.Linq;
using System.Windows;
using WorkHoursTimer.Services;
using Wpf.Ui.Controls;

namespace WorkHoursTimer
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : FluentWindow
    {
        private WidgetWindow? _widgetWindow;

        public MainWindow()
        {
            InitializeComponent();
            PositionWindowToRight();
            
            // 订阅计时器事件
            TimerService.Instance.TimerTick += OnTimerTick;
            
            // 初始化托盘图标
            TrayIconService.Instance.Initialize(this);
            
            // 窗口关闭时最小化到托盘而不是退出
            this.Closing += MainWindow_Closing;
            
            // 加载项目列表
            LoadProjects();
            
            // 订阅项目变更事件
            ProjectService.Instance.ProjectChanged += OnProjectChanged;
            
            // 初始化快捷键服务
            this.Loaded += (s, e) =>
            {
                HotkeyService.Instance.Initialize(this);
                // 初始化自动隐藏服务
                AutoHideService.Instance.Initialize(this);
            };
            
            // 订阅窗口消息（用于快捷键切换挂件）
            WindowMessenger.Instance.MessageReceived += OnWindowMessage;
            
            // 禁用窗口拖动
            this.MouseLeftButtonDown += MainWindow_MouseLeftButtonDown;
            
            // 加载统计数据
            LoadStatistics();
            
            // 订阅 Expander 展开事件
            StatisticsExpander.Expanded += (s, e) => LoadStatistics();
        }

        /// <summary>
        /// 禁用窗口拖动
        /// </summary>
        private void MainWindow_MouseLeftButtonDown(object sender, System.Windows.Input.MouseButtonEventArgs e)
        {
            // 不执行 DragMove，窗口固定在右侧
            // 注释掉默认的拖动行为
            // this.DragMove();
        }

        /// <summary>
        /// 加载项目列表
        /// </summary>
        private void LoadProjects()
        {
            var projects = ProjectService.Instance.GetActiveProjects();
            ProjectComboBox.ItemsSource = projects;
            
            // 选中当前项目
            if (ProjectService.Instance.CurrentProject != null)
            {
                ProjectComboBox.SelectedValue = ProjectService.Instance.CurrentProject.Id;
            }
        }

        /// <summary>
        /// 项目变更事件
        /// </summary>
        private void OnProjectChanged(object? sender, ProjectChangedEventArgs e)
        {
            // 重新加载项目列表
            LoadProjects();
        }

        /// <summary>
        /// 窗口消息处理
        /// </summary>
        private void OnWindowMessage(object? sender, MessageEventArgs e)
        {
            if (e.Type == "TOGGLE_WIDGET")
            {
                // 切换挂件显示
                if (_widgetWindow != null && _widgetWindow.IsLoaded)
                {
                    if (_widgetWindow.IsVisible)
                    {
                        _widgetWindow.Hide();
                    }
                    else
                    {
                        _widgetWindow.Show();
                    }
                }
                else
                {
                    // 如果挂件不存在，创建它
                    CreateWidgetWindow_Click(this, new RoutedEventArgs());
                }
            }
        }

        /// <summary>
        /// 窗口关闭事件 - 最小化到托盘
        /// </summary>
        private void MainWindow_Closing(object? sender, System.ComponentModel.CancelEventArgs e)
        {
            // 取消关闭，改为隐藏到托盘
            e.Cancel = true;
            TrayIconService.Instance.HideMainWindow();
            TrayIconService.Instance.ShowNotification("Work Hours Timer", "应用已最小化到托盘", System.Windows.Forms.ToolTipIcon.Info);
        }

        /// <summary>
        /// 将窗口定位到屏幕右侧
        /// </summary>
        private void PositionWindowToRight()
        {
            var workArea = SystemParameters.WorkArea;
            this.Height = workArea.Height * 0.9;
            this.Top = workArea.Top + (workArea.Height - this.Height) / 2;
            this.Left = workArea.Right - this.Width;
        }

        /// <summary>
        /// 工作时间设置
        /// </summary>
        private void WorkTimeSettings_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var dialog = new WorkTimeSettingsDialog
                {
                    Owner = this
                };
                
                if (dialog.ShowDialog() == true)
                {
                    var settings = DataService.Instance.AppData.Settings;
                    System.Windows.MessageBox.Show(
                        $"工作时间已更新！\n\n" +
                        $"上班时间: {settings.WorkStartHour:D2}:00\n" +
                        $"下班时间: {settings.WorkEndHour:D2}:00\n" +
                        $"工作时长: {settings.WorkEndHour - settings.WorkStartHour} 小时",
                        "设置成功",
                        System.Windows.MessageBoxButton.OK,
                        System.Windows.MessageBoxImage.Information
                    );
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ 打开工作时间设置失败: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"   堆栈: {ex.StackTrace}");
                System.Windows.MessageBox.Show(
                    $"打开设置窗口失败:\n{ex.Message}\n\n详细信息:\n{ex.StackTrace}",
                    "错误",
                    System.Windows.MessageBoxButton.OK,
                    System.Windows.MessageBoxImage.Error
                );
            }
        }

        /// <summary>
        /// 创建挂件窗口
        /// </summary>
        private void CreateWidgetWindow_Click(object sender, RoutedEventArgs e)
        {
            if (_widgetWindow == null || !_widgetWindow.IsLoaded)
            {
                _widgetWindow = new WidgetWindow();
                _widgetWindow.Closed += (s, args) =>
                {
                    _widgetWindow = null;
                    CloseWidgetButton.IsEnabled = false;
                };
                _widgetWindow.Show();
                CloseWidgetButton.IsEnabled = true;
                
                // 发送测试消息
                WindowMessenger.Instance.SendMessage("WIDGET_CREATED", new
                {
                    Message = "挂件窗口已创建",
                    Time = DateTime.Now.ToString("HH:mm:ss")
                });
            }
        }

        /// <summary>
        /// 关闭挂件窗口
        /// </summary>
        private void CloseWidgetWindow_Click(object sender, RoutedEventArgs e)
        {
            if (_widgetWindow != null && _widgetWindow.IsLoaded)
            {
                // 发送关闭消息
                WindowMessenger.Instance.SendMessage("WIDGET_CLOSING", new
                {
                    Message = "主窗口请求关闭挂件",
                    Time = DateTime.Now.ToString("HH:mm:ss")
                });
                
                _widgetWindow.Close();
                _widgetWindow = null;
                CloseWidgetButton.IsEnabled = false;
            }
        }

        /// <summary>
        /// 开始工作按钮
        /// </summary>
        private void StartButton_Click(object sender, RoutedEventArgs e)
        {
            // 使用当前选中的项目
            TimerService.Instance.Start();
            StartButton.IsEnabled = false;
            PauseButton.IsEnabled = true;
            StopButton.IsEnabled = true;
            ProjectDisplay.Text = ProjectService.Instance.CurrentProject?.Name ?? "默认项目";
            ProjectComboBox.IsEnabled = false; // 计时时不能切换项目
        }

        /// <summary>
        /// 暂停/恢复按钮
        /// </summary>
        private void PauseButton_Click(object sender, RoutedEventArgs e)
        {
            if (TimerService.Instance.IsRunning)
            {
                TimerService.Instance.Pause();
                PauseButton.Content = "恢复";
            }
            else
            {
                TimerService.Instance.Resume();
                PauseButton.Content = "暂停";
            }
        }

        /// <summary>
        /// 停止工作按钮
        /// </summary>
        private void StopButton_Click(object sender, RoutedEventArgs e)
        {
            var session = TimerService.Instance.Stop();
            if (session != null)
            {
                // 保存会话
                DataService.Instance.AddSession(session);
                
                // 更新项目统计
                var project = ProjectService.Instance.CurrentProject;
                if (project != null)
                {
                    ProjectService.Instance.UpdateProjectStats(project.Id, session.DurationSeconds);
                }
                
                // 添加工作收益（金币和经验）
                EconomyService.Instance.AddWorkRewards(session.DurationSeconds);
                
                // 检查成就
                AchievementService.Instance.CheckAchievements();
                
                // 获取收益信息
                var (gold, exp) = EconomyService.Instance.CalculateRewards(session.DurationSeconds);
                var (level, currentExp, expToNext, progress) = EconomyService.Instance.GetLevelInfo();
                
                // 显示完成消息
                var data = DataService.Instance.AppData;
                var totalHours = data.TotalWorkSeconds / 3600.0;
                
                System.Windows.MessageBox.Show(
                    $"工作完成！\n\n" +
                    $"项目: {session.ProjectName}\n" +
                    $"本次时长: {session.FormattedDuration}\n" +
                    $"总工时: {totalHours:F2} 小时\n" +
                    $"会话数: {data.Sessions.Count}\n\n" +
                    $"💰 获得金币: +{gold}\n" +
                    $"⭐ 获得经验: +{exp}\n" +
                    $"📊 当前等级: Lv.{level} ({currentExp}/{expToNext})",
                    "完成",
                    System.Windows.MessageBoxButton.OK,
                    System.Windows.MessageBoxImage.Information
                );
            }
            
            StartButton.IsEnabled = true;
            PauseButton.IsEnabled = false;
            PauseButton.Content = "暂停";
            StopButton.IsEnabled = false;
            TimerDisplay.Text = "00:00:00";
            ProjectDisplay.Text = "未开始";
            ProjectComboBox.IsEnabled = true; // 停止后可以切换项目
            
            // 刷新统计数据
            LoadStatistics();
        }

        /// <summary>
        /// 计时器更新事件
        /// </summary>
        private void OnTimerTick(object? sender, TimerTickEventArgs e)
        {
            TimerDisplay.Text = e.FormattedDuration;
        }

        /// <summary>
        /// 最小化到托盘
        /// </summary>
        private void MinimizeToTray_Click(object sender, RoutedEventArgs e)
        {
            TrayIconService.Instance.HideMainWindow();
            TrayIconService.Instance.ShowNotification("Work Hours Timer", "应用已最小化到托盘", System.Windows.Forms.ToolTipIcon.Info);
        }

        /// <summary>
        /// 项目选择变更
        /// </summary>
        private void ProjectComboBox_SelectionChanged(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
        {
            if (ProjectComboBox.SelectedValue is string projectId)
            {
                ProjectService.Instance.SwitchProject(projectId);
            }
        }

        /// <summary>
        /// 添加项目
        /// </summary>
        private void AddProject_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new ProjectDialog();
            if (dialog.ShowDialog() == true)
            {
                ProjectService.Instance.CreateProject(
                    dialog.ProjectName,
                    dialog.ProjectColor,
                    dialog.ProjectDescription
                );
            }
        }

        /// <summary>
        /// 编辑项目
        /// </summary>
        private void EditProject_Click(object sender, RoutedEventArgs e)
        {
            var currentProject = ProjectService.Instance.CurrentProject;
            if (currentProject == null)
            {
                System.Windows.MessageBox.Show("请先选择一个项目", "提示", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Information);
                return;
            }

            var dialog = new ProjectDialog(currentProject);
            if (dialog.ShowDialog() == true)
            {
                ProjectService.Instance.UpdateProject(
                    currentProject.Id,
                    dialog.ProjectName,
                    dialog.ProjectColor,
                    dialog.ProjectDescription
                );
            }
        }

        /// <summary>
        /// 删除项目
        /// </summary>
        private void DeleteProject_Click(object sender, RoutedEventArgs e)
        {
            var currentProject = ProjectService.Instance.CurrentProject;
            if (currentProject == null)
            {
                System.Windows.MessageBox.Show("请先选择一个项目", "提示", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Information);
                return;
            }

            var result = System.Windows.MessageBox.Show(
                $"确定要删除项目 \"{currentProject.Name}\" 吗？\n\n注意：项目的工时记录将保留。",
                "确认删除",
                System.Windows.MessageBoxButton.YesNo,
                System.Windows.MessageBoxImage.Warning
            );

            if (result == System.Windows.MessageBoxResult.Yes)
            {
                if (!ProjectService.Instance.DeleteProject(currentProject.Id))
                {
                    System.Windows.MessageBox.Show("无法删除最后一个项目", "错误", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Error);
                }
            }
        }

        /// <summary>
        /// 显示快捷键设置
        /// </summary>
        private void ShowHotkeySettings_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new HotkeySettingsDialog
            {
                Owner = this
            };
            dialog.ShowDialog();
        }

        /// <summary>
        /// 显示统计窗口
        /// </summary>
        private void ShowStatistics_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var statsWindow = new StatisticsWindow
                {
                    Owner = this
                };
                statsWindow.ShowDialog();
            }
            catch (Exception ex)
            {
                System.Windows.MessageBox.Show(
                    $"打开统计窗口失败:\n{ex.Message}\n\n详细信息:\n{ex.StackTrace}",
                    "错误",
                    System.Windows.MessageBoxButton.OK,
                    System.Windows.MessageBoxImage.Error
                );
            }
        }

        /// <summary>
        /// 加载统计数据
        /// </summary>
        private void LoadStatistics()
        {
            try
            {
                var stats = StatisticsService.Instance.GetTodayStatistics();
                
                // 更新统计卡片
                StatsTotalHours.Text = $"{stats.TotalHours:F1}h";
                StatsSessionCount.Text = stats.SessionCount.ToString();
                
                if (stats.SessionCount > 0)
                {
                    var avgSeconds = stats.TotalSeconds / stats.SessionCount;
                    StatsAvgTime.Text = $"{avgSeconds / 3600.0:F1}h";
                }
                else
                {
                    StatsAvgTime.Text = "0.0h";
                }
                
                // 更新项目列表
                if (stats.ProjectStats != null && stats.ProjectStats.Any())
                {
                    // 计算最大值用于条形图宽度
                    var maxSeconds = stats.ProjectStats.Max(p => p.TotalSeconds);
                    var maxWidth = 200.0; // 最大宽度
                    
                    // 为每个项目添加条形图宽度属性
                    var projectsWithWidth = stats.ProjectStats.Select(p => new
                    {
                        p.ProjectName,
                        p.TotalSeconds,
                        p.SessionCount,
                        p.FormattedTotal,
                        BarWidth = maxSeconds > 0 ? (p.TotalSeconds / (double)maxSeconds) * maxWidth : 0
                    }).ToList();
                    
                    StatsProjectList.ItemsSource = projectsWithWidth;
                    StatsProjectList.Visibility = Visibility.Visible;
                    StatsNoData.Visibility = Visibility.Collapsed;
                }
                else
                {
                    StatsProjectList.ItemsSource = null;
                    StatsProjectList.Visibility = Visibility.Collapsed;
                    StatsNoData.Visibility = Visibility.Visible;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"加载统计数据失败: {ex.Message}");
            }
        }

        /// <summary>
        /// 导出统计数据
        /// </summary>
        private void ExportStatistics_Click(object sender, RoutedEventArgs e)
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
                    var stats = StatisticsService.Instance.GetTodayStatistics();
                    var sb = new System.Text.StringBuilder();
                    
                    // 添加 BOM 以支持中文
                    sb.Append('\ufeff');
                    
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
                    
                    System.IO.File.WriteAllText(dialog.FileName, sb.ToString(), System.Text.Encoding.UTF8);
                    
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
    }
}
