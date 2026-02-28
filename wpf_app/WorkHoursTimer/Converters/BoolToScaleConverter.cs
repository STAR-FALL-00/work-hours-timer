using System;
using System.Globalization;
using System.Windows.Data;

namespace WorkHoursTimer.Converters
{
    /// <summary>
    /// 将布尔值转换为缩放值，用于翻转图像
    /// true = -1 (翻转), false = 1 (正常)
    /// </summary>
    public class BoolToScaleConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value is bool flipped)
            {
                return flipped ? -1.0 : 1.0;
            }
            return 1.0;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}
