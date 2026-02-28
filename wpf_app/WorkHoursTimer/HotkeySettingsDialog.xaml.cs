using System.Windows;

namespace WorkHoursTimer
{
    /// <summary>
    /// 快捷键设置对话框
    /// </summary>
    public partial class HotkeySettingsDialog : Window
    {
        public HotkeySettingsDialog()
        {
            InitializeComponent();
        }

        private void Close_Click(object sender, RoutedEventArgs e)
        {
            Close();
        }
    }
}
