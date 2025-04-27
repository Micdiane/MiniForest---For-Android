import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/focus_stats.dart';
import '../models/daily_focus_summary.dart';

class FocusLineChart extends StatelessWidget {
  final List<DailyFocusSummary> data;
  final double height;
  final int daysToShow;

  const FocusLineChart({
    Key? key,
    required this.data,
    this.height = 200,
    this.daysToShow = 7,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 如果没有数据，显示空状态
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('暂无专注数据'),
        ),
      );
    }

    // 筛选最近X天的数据
    final recentData = data.length > daysToShow 
        ? data.sublist(data.length - daysToShow) 
        : data;
    
    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 30, // 30分钟一条横线
            verticalInterval: 1,    // 每天一条竖线
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  // 确保索引在数据范围内
                  if (value.toInt() < 0 || value.toInt() >= recentData.length) {
                    return const Text('');
                  }
                  
                  // 格式化日期为MM-dd格式
                  final date = recentData[value.toInt()].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MM-dd').format(date),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff72719b),
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 30, // 每30分钟一个刻度
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '${value.toInt()}分钟',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xff72719b),
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1),
          ),
          minX: 0,
          maxX: recentData.length - 1.0,
          minY: 0,
          maxY: _getMaxY(recentData) + 30, // 添加一些空间在顶部
          lineBarsData: [
            // 健康专注时间曲线
            LineChartBarData(
              spots: _createSpots(recentData, false),
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.2),
              ),
            ),
            // 枯萎专注时间曲线
            LineChartBarData(
              spots: _createSpots(recentData, true),
              isCurved: true,
              color: Colors.redAccent,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.redAccent.withOpacity(0.2),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  final data = recentData[spot.x.toInt()];
                  final isWithered = spot.barIndex == 1;
                  
                  return LineTooltipItem(
                    '${isWithered ? "枯萎" : "健康"}: ${spot.y.toInt()}分钟',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  // 为健康或枯萎数据创建点
  List<FlSpot> _createSpots(List<DailyFocusSummary> data, bool isWithered) {
    final spots = <FlSpot>[];
    
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final minutes = isWithered 
          ? item.witheredFocusMinutes 
          : item.healthyFocusMinutes;
      
      spots.add(FlSpot(i.toDouble(), minutes.toDouble()));
    }
    
    return spots;
  }

  // 获取Y轴的最大值
  double _getMaxY(List<DailyFocusSummary> data) {
    double maxY = 0;
    
    for (final item in data) {
      final total = item.healthyFocusMinutes + item.witheredFocusMinutes;
      if (total > maxY) {
        maxY = total.toDouble();
      }
    }
    
    // 如果最大值太小，至少显示60分钟的范围
    return maxY < 60 ? 60 : maxY;
  }
} 