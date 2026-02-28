using System;
using System.Globalization;
using System.Windows.Data;

namespace WorkHoursTimer.Converters
{
    /// <summary>
    /// 将百分比值转换为宽度
    /// </summary>
    public class PercentToWidthConverter : IValueConverter
    {
        public double MaxWidth { get; set; } = 280;

        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value is double percent)
            {
                // 如果提供了参数，使用参数作为最大宽度
                double maxWidth = MaxWidth;
                if (parameter != null && double.TryParse(parameter.ToString(), out double paramWidth))
                {
                    maxWidth = paramWidth;
                }
                
                return (percent / 100.0) * maxWidth;
            }
            return 0.0;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}
