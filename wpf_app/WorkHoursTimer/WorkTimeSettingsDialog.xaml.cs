using System;
using System.Windows;
using WorkHoursTimer.Services;
using Wpf.Ui.Controls;

namespace WorkHoursTimer
{
    /// <summary>
    /// 工作时间设置对话框
    /// </summary>
    public partial class WorkTimeSettingsDialog : FluentWindow
    {
        public int WorkStartHour { get; private set; }
        public int WorkEndHour { get; private set; }

        public WorkTimeSettingsDialog()
        {
            InitializeComponent();
            LoadSettings();
            UpdateWorkDuration();
        }

        /// <summary>
        /// 加载当前设置
        /// </summary>
        private void LoadSettings()
        {
            var settings = DataService.Instance.AppData.Settings;
            StartHourSlider.Value = settings.WorkStartHour;
            EndHourSlider.Value = settings.WorkEndHour;
            WorkStartHour = settings.WorkStartHour;
            WorkEndHour = settings.WorkEndHour;
        }

        /// <summary>
        /// 开始时间变化
        /// </summary>
        private void StartHourSlider_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            if (StartHourText == null) return;
            
            var hour = (int)e.NewValue;
            StartHourText.Text = $"{hour:D2}:00";
            WorkStartHour = hour;
            
            // 确保结束时间大于开始时间
            if (EndHourSlider != null && hour >= EndHourSlider.Value)
            {
                EndHourSlider.Value = Math.Min(23, hour + 1);
            }
            
            UpdateWorkDuration();
        }

        /// <summary>
        /// 结束时间变化
        /// </summary>
        private void EndHourSlider_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            if (EndHourText == null) return;
            
            var hour = (int)e.NewValue;
            EndHourText.Text = $"{hour:D2}:00";
            WorkEndHour = hour;
            
            // 确保结束时间大于开始时间
            if (StartHourSlider != null && hour <= StartHourSlider.Value)
            {
                StartHourSlider.Value = Math.Max(0, hour - 1);
            }
            
            UpdateWorkDuration();
        }

        /// <summary>
        /// 更新工作时长显示
        /// </summary>
        private void UpdateWorkDuration()
        {
            if (WorkDurationText == null) return;
            
            var duration = WorkEndHour - WorkStartHour;
            if (duration < 0) duration += 24; // 跨天情况
            
            WorkDurationText.Text = $"{duration} 小时";
        }

        /// <summary>
        /// 确定按钮
        /// </summary>
        private void OkButton_Click(object sender, RoutedEventArgs e)
        {
            // 验证时间有效性
            if (WorkEndHour <= WorkStartHour)
            {
                System.Windows.MessageBox.Show(
                    "下班时间必须晚于上班时间！",
                    "错误",
                    System.Windows.MessageBoxButton.OK,
                    System.Windows.MessageBoxImage.Warning
                );
                return;
            }

            // 保存设置
            var settings = DataService.Instance.AppData.Settings;
            settings.WorkStartHour = WorkStartHour;
            settings.WorkEndHour = WorkEndHour;
            DataService.Instance.SaveData();

            // 发送消息通知挂件更新
            WindowMessenger.Instance.SendMessage("WORK_TIME_CHANGED", new
            {
                StartHour = WorkStartHour,
                EndHour = WorkEndHour
            });

            DialogResult = true;
            Close();
        }

        /// <summary>
        /// 取消按钮
        /// </summary>
        private void CancelButton_Click(object sender, RoutedEventArgs e)
        {
            DialogResult = false;
            Close();
        }
    }
}
