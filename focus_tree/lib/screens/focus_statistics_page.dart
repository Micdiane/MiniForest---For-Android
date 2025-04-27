import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/focus_provider.dart';
import '../models/focus_stats.dart';
import '../models/daily_focus_summary.dart';
import '../widgets/simple_focus_chart.dart';

class FocusStatisticsPage extends StatefulWidget {
  const FocusStatisticsPage({Key? key}) : super(key: key);

  @override
  State<FocusStatisticsPage> createState() => _FocusStatisticsPageState();
}

class _FocusStatisticsPageState extends State<FocusStatisticsPage> {
  TimePeriod _selectedPeriod = TimePeriod.week;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('专注统计'),
      ),
      body: Consumer<FocusProvider>(
        builder: (context, provider, child) {
          // 获取所选时间段的统计数据
          final stats = provider.getStats(_selectedPeriod);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 时间段选择器
                _buildPeriodSelector(),
                
                const SizedBox(height: 24),
                
                // 总体统计数据
                _buildSummaryStats(stats),
                
                const SizedBox(height: 24),
                
                // 专注类型分布图表
                _buildDistributionChart(stats),
                
                const SizedBox(height: 24),
                
                // 时间序列图表
                _buildTimeSeriesChart(stats),
              ],
            ),
          );
        },
      ),
    );
  }
  
  // 时间段选择器
  Widget _buildPeriodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPeriodButton(TimePeriod.day, '今日'),
        _buildPeriodButton(TimePeriod.week, '本周'),
        _buildPeriodButton(TimePeriod.month, '本月'),
        _buildPeriodButton(TimePeriod.year, '本年'),
      ],
    );
  }
  
  Widget _buildPeriodButton(TimePeriod period, String label) {
    final isSelected = period == _selectedPeriod;
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedPeriod = period;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.green : Colors.grey.shade200,
            foregroundColor: isSelected ? Colors.white : Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0),
          ),
          child: Text(label),
        ),
      ),
    );
  }
  
  // 总体统计数据
  Widget _buildSummaryStats(FocusStats stats) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Text(
            _getPeriodTitle(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('专注次数', '${stats.totalFocusSessions}次'),
              _buildStatItem('专注时长', '${stats.totalFocusMinutes}分钟'),
              _buildStatItem('成功率', '${(stats.successRate * 100).toStringAsFixed(1)}%'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
  
  // 专注类型分布图表
  Widget _buildDistributionChart(FocusStats stats) {
    final distribution = stats.getFocusTypeDistribution();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '专注类型分布',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SimpleFocusPieChart(
          data: distribution,
          height: 200,
        ),
      ],
    );
  }
  
  // 时间序列图表
  Widget _buildTimeSeriesChart(FocusStats stats) {
    // 创建时间序列数据
    final seriesData = stats.getTimeSeriesData();
    final dailyData = DailyFocusSummary.fromTimeSeriesData(seriesData);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '专注时长趋势',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SimpleFocusChart(
          data: dailyData,
          height: 200,
          daysToShow: _getDaysToShow(),
        ),
      ],
    );
  }
  
  // 根据选择的时间段获取要显示的天数
  int _getDaysToShow() {
    switch (_selectedPeriod) {
      case TimePeriod.day:
        return 1;
      case TimePeriod.week:
        return 7;
      case TimePeriod.month:
        return 30;
      case TimePeriod.year:
        return 365;
    }
  }
  
  // 获取对应时间段的标题
  String _getPeriodTitle() {
    switch (_selectedPeriod) {
      case TimePeriod.day:
        return '今日专注概览';
      case TimePeriod.week:
        return '本周专注概览';
      case TimePeriod.month:
        return '本月专注概览';
      case TimePeriod.year:
        return '本年专注概览';
    }
  }
} 