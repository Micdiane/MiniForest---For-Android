import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/focus_stats.dart';

class FocusPieChart extends StatelessWidget {
  final List<FocusTypeDistribution> data;
  final double height;
  final Function(int, PieTouchResponse)? onTouch;

  const FocusPieChart({
    Key? key,
    required this.data,
    this.height = 200,
    this.onTouch,
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

    return SizedBox(
      height: height,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: _createSections(),
          pieTouchData: PieTouchData(
            touchCallback: onTouch != null 
                ? (FlTouchEvent event, PieTouchResponse? response) {
                    if (response == null || response.touchedSection == null) {
                      return;
                    }
                    if (event is FlTapUpEvent) {
                      onTouch!(response.touchedSection!.touchedSectionIndex, response);
                    }
                  }
                : null,
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _createSections() {
    final List<PieChartSectionData> sections = [];
    
    // 计算总分钟数，用于百分比
    final totalMinutes = data.fold<int>(0, (sum, item) => sum + item.totalMinutes);
    
    // 配色方案
    const List<Color> healthyColors = [
      Color(0xFF4CAF50), // 绿色
      Color(0xFF8BC34A), // 浅绿色
      Color(0xFF009688), // 青绿色
      Color(0xFF00BCD4), // 青色
    ];
    
    const List<Color> witheredColors = [
      Color(0xFFFF5722), // 深橙色
      Color(0xFFF44336), // 红色
      Color(0xFFE91E63), // 粉红色
      Color(0xFFD32F2F), // 深红色
    ];

    // 创建饼图部分
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final double percentage = totalMinutes > 0 
          ? item.totalMinutes / totalMinutes 
          : 0;
      
      // 选择颜色
      final Color color = item.isWithered
          ? witheredColors[i % witheredColors.length]
          : healthyColors[i % healthyColors.length];
      
      sections.add(
        PieChartSectionData(
          color: color,
          value: item.totalMinutes.toDouble(),
          title: '${(percentage * 100).toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          badgeWidget: _Badge(
            item.typeName,
            color: color,
            size: 30,
          ),
          badgePositionPercentageOffset: 0.98,
        ),
      );
    }

    return sections;
  }
}

// 自定义标签组件
class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final double size;

  const _Badge(
    this.text, {
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      width: size,
      height: size,
      alignment: Alignment.center,
      child: Text(
        text.split('分钟')[0], // 只显示时长数字
        style: TextStyle(
          fontSize: size / 3,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} 