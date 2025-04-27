import 'package:flutter/material.dart';
import 'focus_stats.dart';

class DailyFocusSummary {
  final DateTime date;
  final int healthyFocusMinutes;
  final int witheredFocusMinutes;
  
  DailyFocusSummary({
    required this.date,
    required this.healthyFocusMinutes,
    required this.witheredFocusMinutes,
  });
  
  // 获取总专注分钟数
  int get totalFocusMinutes => healthyFocusMinutes + witheredFocusMinutes;
  
  // 从TimeSeriesData列表转换
  static List<DailyFocusSummary> fromTimeSeriesData(List<TimeSeriesData> seriesData) {
    if (seriesData.isEmpty) return [];
    
    // 按日期分组
    Map<String, TimeSeriesData> dataByDate = {};
    for (var data in seriesData) {
      final key = '${data.dateTime.year}-${data.dateTime.month}-${data.dateTime.day}';
      dataByDate[key] = data;
    }
    
    // 转换为DailyFocusSummary
    List<DailyFocusSummary> result = [];
    dataByDate.forEach((key, data) {
      result.add(DailyFocusSummary(
        date: data.dateTime,
        healthyFocusMinutes: data.value,
        witheredFocusMinutes: 0, // 由于TimeSeriesData中没有区分，这里只能设为0
      ));
    });
    
    // 按日期排序
    result.sort((a, b) => a.date.compareTo(b.date));
    
    return result;
  }
} 