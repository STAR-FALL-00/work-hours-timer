using System.Windows;
using System.Windows.Controls;
using WorkHoursTimer.Models;

namespace WorkHoursTimer
{
    /// <summary>
    /// 项目对话框
    /// </summary>
    public partial class ProjectDialog : Window
    {
        public string ProjectName => NameTextBox.Text.Trim();
        public string ProjectColor => (ColorComboBox.SelectedItem as ComboBoxItem)?.Tag?.ToString() ?? "#FFD700";
        public string ProjectDescription => DescriptionTextBox.Text.Trim();

        private readonly Project? _editingProject;

        /// <summary>
        /// 新建项目
        /// </summary>
        public ProjectDialog()
        {
            InitializeComponent();
            Title = "新建项目";
        }

        /// <summary>
        /// 编辑项目
        /// </summary>
        public ProjectDialog(Project project) : this()
        {
            _editingProject = project;
            Title = "编辑项目";
            
            // 填充现有数据
            NameTextBox.Text = project.Name;
            DescriptionTextBox.Text = project.Description;
            
            // 选择颜色
            foreach (ComboBoxItem item in ColorComboBox.Items)
            {
                if (item.Tag?.ToString() == project.Color)
                {
                    ColorComboBox.SelectedItem = item;
                    break;
                }
            }
        }

        private void OK_Click(object sender, RoutedEventArgs e)
        {
            // 验证项目名称
            if (string.IsNullOrWhiteSpace(ProjectName))
            {
                System.Windows.MessageBox.Show("请输入项目名称", "提示", MessageBoxButton.OK, MessageBoxImage.Warning);
                NameTextBox.Focus();
                return;
            }

            DialogResult = true;
            Close();
        }

        private void Cancel_Click(object sender, RoutedEventArgs e)
        {
            DialogResult = false;
            Close();
        }
    }
}
