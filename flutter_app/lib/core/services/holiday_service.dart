/// 节假日服务
/// 用于判断某一天是否为工作日
class HolidayService {
  // 2026年中国法定节假日（根据国务院办公厅通知）
  static final Map<int, List<DateTime>> _holidays = {
    2026: [
      // 元旦：1月1日-3日
      DateTime(2026, 1, 1),
      DateTime(2026, 1, 2),
      DateTime(2026, 1, 3),
      
      // 春节：1月29日-2月4日（农历正月初一至初七）
      DateTime(2026, 1, 29),
      DateTime(2026, 1, 30),
      DateTime(2026, 1, 31),
      DateTime(2026, 2, 1),
      DateTime(2026, 2, 2),
      DateTime(2026, 2, 3),
      DateTime(2026, 2, 4),
      
      // 清明节：4月4日-6日
      DateTime(2026, 4, 4),
      DateTime(2026, 4, 5),
      DateTime(2026, 4, 6),
      
      // 劳动节：5月1日-5日
      DateTime(2026, 5, 1),
      DateTime(2026, 5, 2),
      DateTime(2026, 5, 3),
      DateTime(2026, 5, 4),
      DateTime(2026, 5, 5),
      
      // 端午节：6月25日-27日
      DateTime(2026, 6, 25),
      DateTime(2026, 6, 26),
      DateTime(2026, 6, 27),
      
      // 中秋节：9月26日-28日
      DateTime(2026, 9, 26),
      DateTime(2026, 9, 27),
      DateTime(2026, 9, 28),
      
      // 国庆节：10月1日-7日
      DateTime(2026, 10, 1),
      DateTime(2026, 10, 2),
      DateTime(2026, 10, 3),
      DateTime(2026, 10, 4),
      DateTime(2026, 10, 5),
      DateTime(2026, 10, 6),
      DateTime(2026, 10, 7),
    ],
    
    // 可以继续添加其他年份的节假日
    2027: [
      // 元旦：1月1日-3日
      DateTime(2027, 1, 1),
      DateTime(2027, 1, 2),
      DateTime(2027, 1, 3),
      // ... 其他节假日待更新
    ],
  };

  // 调休补班日期（这些周末需要上班）
  static final Map<int, List<DateTime>> _workdays = {
    2026: [
      // 春节调休：1月24日（周六）、2月1日（周日）上班
      DateTime(2026, 1, 24),
      DateTime(2026, 2, 1),
      
      // 国庆节调休：9月27日（周日）、10月10日（周六）上班
      DateTime(2026, 9, 27),
      DateTime(2026, 10, 10),
    ],
  };

  /// 判断某一天是否为工作日
  /// 
  /// 工作日定义：
  /// 1. 不是周末（周六、周日）
  /// 2. 不是法定节假日
  /// 3. 或者是调休补班日
  static bool isWorkday(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final year = date.year;
    
    // 检查是否为调休补班日
    if (_workdays[year]?.any((d) => _isSameDay(d, normalizedDate)) ?? false) {
      return true;
    }
    
    // 检查是否为法定节假日
    if (_holidays[year]?.any((d) => _isSameDay(d, normalizedDate)) ?? false) {
      return false;
    }
    
    // 检查是否为周末
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return false;
    }
    
    return true;
  }

  /// 计算某个月的工作日天数
  static int getWorkdaysInMonth(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    
    int workdays = 0;
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(year, month, day);
      if (isWorkday(date)) {
        workdays++;
      }
    }
    
    return workdays;
  }

  /// 计算某个日期范围内的工作日天数
  static int getWorkdaysInRange(DateTime start, DateTime end) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    
    int workdays = 0;
    DateTime current = normalizedStart;
    
    while (current.isBefore(normalizedEnd) || current.isAtSameMomentAs(normalizedEnd)) {
      if (isWorkday(current)) {
        workdays++;
      }
      current = current.add(const Duration(days: 1));
    }
    
    return workdays;
  }

  /// 获取当月剩余工作日天数
  static int getRemainingWorkdaysInMonth(DateTime date) {
    final today = DateTime(date.year, date.month, date.day);
    final lastDay = DateTime(date.year, date.month + 1, 0);
    
    return getWorkdaysInRange(today, lastDay);
  }

  /// 判断两个日期是否为同一天
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 获取某个月的所有节假日
  static List<DateTime> getHolidaysInMonth(int year, int month) {
    return _holidays[year]
            ?.where((date) => date.month == month)
            .toList() ??
        [];
  }

  /// 获取某个月的所有调休补班日
  static List<DateTime> getMakeupWorkdaysInMonth(int year, int month) {
    return _workdays[year]
            ?.where((date) => date.month == month)
            .toList() ??
        [];
  }
}
