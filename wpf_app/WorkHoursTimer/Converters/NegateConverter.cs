using System;
using System.Globalization;
using System.Windows.Data;

namespace WorkHoursTimer.Converters
{
    /// <summary>
    /// 将数值取反，用于 Y 轴坐标转换
    /// </summary>
    public class NegateConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value is double d)
            {
                return -d;
            }
            return 0.0;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}
