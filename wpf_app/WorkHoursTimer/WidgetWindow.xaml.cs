using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using WorkHoursTimer.Helpers;
using WorkHoursTimer.ViewModels;

namespace WorkHoursTimer
{
    /// <summary>
    /// Interaction logic for WidgetWindow.xaml
    /// </summary>
    public partial class WidgetWindow : Window
    {
        private bool _isClickThroughEnabled = false;
        private readonly WidgetViewModel _viewModel;

        public WidgetWindow()
        {
            InitializeComponent();
            
            // 初始化 ViewModel
            _viewModel = new WidgetViewModel();
            this.DataContext = _viewModel;
            
            PositionToBottomRight();
            
            // 窗口加载完成后启用穿透
            this.Loaded += (s, e) => EnableClickThrough();
            
            // 鼠标进入时禁用穿透（允许拖拽）
            this.MouseEnter += (s, e) => DisableClickThrough();
            
            // 鼠标离开时启用穿透
            this.MouseLeave += (s, e) => EnableClickThrough();
        }

        /// <summary>
        /// 将窗口定位到右下角
        /// </summary>
        private void PositionToBottomRight()
        {
            var workArea = SystemParameters.WorkArea;
            this.Left = workArea.Right - this.Width - 20;
            this.Top = workArea.Bottom - this.Height - 20;
        }

        /// <summary>
        /// 启用鼠标穿透
        /// </summary>
        private void EnableClickThrough()
        {
            if (!_isClickThroughEnabled)
            {
                Win32Helper.SetClickThrough(this, true);
                _isClickThroughEnabled = true;
                
                // 更新 ViewModel 状态
                _viewModel.UpdateStatus("🔒 穿透模式");
            }
        }

        /// <summary>
        /// 禁用鼠标穿透（允许交互）
        /// </summary>
        private void DisableClickThrough()
        {
            if (_isClickThroughEnabled)
            {
                Win32Helper.SetClickThrough(this, false);
                _isClickThroughEnabled = false;
                
                // 更新 ViewModel 状态
                _viewModel.UpdateStatus("🔓 可拖拽");
            }
        }

        /// <summary>
        /// 允许拖拽窗口
        /// </summary>
        private void Window_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            if (e.ButtonState == MouseButtonState.Pressed)
            {
                this.DragMove();
            }
        }

        /// <summary>
        /// 右键点击事件 - 显示上下文菜单
        /// </summary>
        private void Window_MouseRightButtonUp(object sender, MouseButtonEventArgs e)
        {
            // 右键点击时，确保窗口不穿透，以便显示菜单
            DisableClickThrough();
        }

        /// <summary>
        /// 切换到勇者伐魔模式
        /// </summary>
        private void SwitchToBossBattle_Click(object sender, RoutedEventArgs e)
        {
            _viewModel.CurrentSkin = "boss_battle";
        }

        /// <summary>
        /// 切换到跑酷猫咪模式
        /// </summary>
        private void SwitchToRunnerCat_Click(object sender, RoutedEventArgs e)
        {
            _viewModel.CurrentSkin = "runner_cat";
        }

        /// <summary>
        /// 关闭菜单项点击事件
        /// </summary>
        private void CloseMenuItem_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        /// <summary>
        /// 置顶菜单项点击事件
        /// </summary>
        private void TopMostMenuItem_Click(object sender, RoutedEventArgs e)
        {
            var menuItem = sender as MenuItem;
            if (menuItem != null)
            {
                this.Topmost = menuItem.IsChecked;
            }
        }
    }
}
