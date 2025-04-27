import 'package:intl/intl.dart';
import 'tree_record.dart';

// 时间段定义
enum TimePeriod {
  day,    // 日
  week,   // 周
  month,  // 月
  year    // 年
}

// 专注类型分布项
class FocusTypeDistribution {
  final String typeName;    // 类型名称（30分钟、45分钟、60分钟、120分钟）
  final int count;          // 该类型的次数
  final int totalMinutes;   // 该类型的总分钟数
  final bool isWithered;    // 是否为枯萎的树

  FocusTypeDistribution({
    required this.typeName,
    required this.count,
    required this.totalMinutes,
    this.isWithered = false,
  });
}

// 时间序列数据点
class TimeSeriesData {
  final DateTime dateTime;
  final int value;          // 专注分钟数或次数
  final String label;       // 显示标签（日期、星期几等）

  TimeSeriesData({
    required this.dateTime,
    required this.value,
    required this.label,
  });
}

// 专注统计数据
class FocusStats {
  // 时间周期内的记录
  final List<TreeRecord> records;
  
  // 时间周期
  final TimePeriod period;
  
  // 构造函数
  FocusStats({
    required this.records,
    required this.period,
  });
  
  // 获取总专注时长（分钟）
  int get totalFocusMinutes {
    return records.fold(0, (sum, record) => sum + record.duration);
  }
  
  // 获取总专注次数
  int get totalFocusSessions {
    return records.length;
  }
  
  // 获取成功专注次数
  int get successfulSessions {
    return records.where((record) => !record.isWithered).length;
  }
  
  // 获取成功专注率
  double get successRate {
    if (totalFocusSessions == 0) return 0;
    return successfulSessions / totalFocusSessions;
  }
  
  // 获取专注类型分布（饼图数据）
  List<FocusTypeDistribution> getFocusTypeDistribution() {
    // 按时长和是否枯萎分组
    Map<String, List<TreeRecord>> groupedByType = {};
    
    for (var record in records) {
      final key = '${record.duration}${record.isWithered ? '_withered' : '_healthy'}';
      if (!groupedByType.containsKey(key)) {
        groupedByType[key] = [];
      }
      groupedByType[key]!.add(record);
    }
    
    // 转换为分布列表
    List<FocusTypeDistribution> result = [];
    
    groupedByType.forEach((key, typeRecords) {
      final isWithered = key.contains('_withered');
      final durationStr = key.split('_')[0];
      final typeName = '$durationStr分钟' + (isWithered ? '(中断)' : '');
      
      result.add(FocusTypeDistribution(
        typeName: typeName,
        count: typeRecords.length,
        totalMinutes: typeRecords.fold(0, (sum, record) => sum + record.duration),
        isWithered: isWithered,
      ));
    });
    
    // 按总时长排序
    result.sort((a, b) => b.totalMinutes.compareTo(a.totalMinutes));
    
    return result;
  }
  
  // 获取时间序列数据
  List<TimeSeriesData> getTimeSeriesData({bool countSessions = false}) {
    if (records.isEmpty) return [];
    
    // 格式化器，用于生成标签
    DateFormat formatter;
    
    // 分段单位和格式
    switch (period) {
      case TimePeriod.day:
        formatter = DateFormat('HH:00');
        return _getHourlyData(formatter, countSessions);
      case TimePeriod.week:
        formatter = DateFormat('E'); // 星期几缩写
        return _getDailyData(formatter, countSessions);
      case TimePeriod.month:
        formatter = DateFormat('MM-dd');
        return _getDailyData(formatter, countSessions);
      case TimePeriod.year:
        formatter = DateFormat('yyyy-MM');
        return _getMonthlyData(formatter, countSessions);
    }
  }
  
  // 获取按小时统计的数据
  List<TimeSeriesData> _getHourlyData(DateFormat formatter, bool countSessions) {
    Map<int, int> hourData = {};
    
    // 初始化24小时的数据
    for (int i = 0; i < 24; i++) {
      hourData[i] = 0;
    }
    
    // 汇总数据
    for (var record in records) {
      final hour = record.plantedDate.hour;
      hourData[hour] = hourData[hour]! + (countSessions ? 1 : record.duration);
    }
    
    // 转换为时间序列
    List<TimeSeriesData> result = [];
    
    final now = DateTime.now();
    for (int hour = 0; hour < 24; hour++) {
      final dateTime = DateTime(now.year, now.month, now.day, hour);
      result.add(TimeSeriesData(
        dateTime: dateTime,
        value: hourData[hour]!,
        label: formatter.format(dateTime),
      ));
    }
    
    return result;
  }
  
  // 获取按天统计的数据
  List<TimeSeriesData> _getDailyData(DateFormat formatter, bool countSessions) {
    // 日期范围
    DateTime oldestDate = records.map((r) => r.plantedDate).reduce((a, b) => a.isBefore(b) ? a : b);
    DateTime now = DateTime.now();
    
    // 确保日期范围至少包含7天（周视图）或30天（月视图）
    int minDays = period == TimePeriod.week ? 7 : 30;
    if (now.difference(oldestDate).inDays < minDays) {
      oldestDate = now.subtract(Duration(days: minDays - 1));
    }
    
    // 汇总数据
    Map<String, int> dailyData = {};
    Map<String, DateTime> dateMap = {}; // 用于保存映射关系
    
    // 初始化日期范围内的所有天
    DateTime current = DateTime(oldestDate.year, oldestDate.month, oldestDate.day);
    while (!current.isAfter(now)) {
      String key = DateFormat('yyyy-MM-dd').format(current);
      dailyData[key] = 0;
      dateMap[key] = current;
      current = current.add(const Duration(days: 1));
    }
    
    // 汇总数据
    for (var record in records) {
      final dateKey = DateFormat('yyyy-MM-dd').format(record.plantedDate);
      if (dailyData.containsKey(dateKey)) {
        dailyData[dateKey] = dailyData[dateKey]! + (countSessions ? 1 : record.duration);
      }
    }
    
    // 转换为时间序列
    List<TimeSeriesData> result = [];
    
    dailyData.forEach((key, value) {
      DateTime date = dateMap[key]!;
      result.add(TimeSeriesData(
        dateTime: date,
        value: value,
        label: formatter.format(date),
      ));
    });
    
    // 按日期排序
    result.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    // 如果是周视图，确保只返回最近7天
    if (period == TimePeriod.week && result.length > 7) {
      return result.sublist(result.length - 7);
    }
    
    // 如果是月视图，确保只返回最近30天
    if (period == TimePeriod.month && result.length > 30) {
      return result.sublist(result.length - 30);
    }
    
    return result;
  }
  
  // 获取按月统计的数据
  List<TimeSeriesData> _getMonthlyData(DateFormat formatter, bool countSessions) {
    // 日期范围
    DateTime oldestDate = records.map((r) => r.plantedDate).reduce((a, b) => a.isBefore(b) ? a : b);
    DateTime now = DateTime.now();
    
    // 确保日期范围至少包含12个月
    if (now.year * 12 + now.month - (oldestDate.year * 12 + oldestDate.month) < 12) {
      oldestDate = DateTime(now.year - 1, now.month + 1, 1);
    }
    
    // 汇总数据
    Map<String, int> monthlyData = {};
    Map<String, DateTime> dateMap = {}; // 用于保存映射关系
    
    // 初始化日期范围内的所有月
    DateTime current = DateTime(oldestDate.year, oldestDate.month, 1);
    while (!current.isAfter(now)) {
      String key = DateFormat('yyyy-MM').format(current);
      monthlyData[key] = 0;
      dateMap[key] = current;
      
      // 增加一个月
      if (current.month == 12) {
        current = DateTime(current.year + 1, 1, 1);
      } else {
        current = DateTime(current.year, current.month + 1, 1);
      }
    }
    
    // 汇总数据
    for (var record in records) {
      final monthKey = DateFormat('yyyy-MM').format(record.plantedDate);
      if (monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = monthlyData[monthKey]! + (countSessions ? 1 : record.duration);
      }
    }
    
    // 转换为时间序列
    List<TimeSeriesData> result = [];
    
    monthlyData.forEach((key, value) {
      DateTime date = dateMap[key]!;
      result.add(TimeSeriesData(
        dateTime: date,
        value: value,
        label: formatter.format(date),
      ));
    });
    
    // 按日期排序
    result.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    // 确保只返回最近12个月
    if (result.length > 12) {
      return result.sublist(result.length - 12);
    }
    
    return result;
  }
} 