import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_focus_summary.dart';

class SimpleFocusChart extends StatelessWidget {
  final List<DailyFocusSummary> data;
  final double height;
  final int daysToShow;

  const SimpleFocusChart({
    Key? key,
    required this.data,
    this.height = 200,
    this.daysToShow = 7,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('暂无专注数据'),
        ),
      );
    }

    // 筛选最近的数据
    final recentData = data.length > daysToShow 
        ? data.sublist(data.length - daysToShow) 
        : data;

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: _buildChartBars(recentData),
          ),
          const SizedBox(height: 8),
          _buildDateLabels(recentData),
        ],
      ),
    );
  }

  Widget _buildChartBars(List<DailyFocusSummary> recentData) {
    // 计算最大值用于确定比例
    double maxValue = 0;
    for (var item in recentData) {
      double total = item.totalFocusMinutes.toDouble();
      if (total > maxValue) {
        maxValue = total;
      }
    }
    
    // 设置最小最大值
    maxValue = maxValue < 60 ? 60 : maxValue;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(recentData.length, (index) {
        final item = recentData[index];
        final healthy = item.healthyFocusMinutes.toDouble();
        final withered = item.witheredFocusMinutes.toDouble();
        
        // 计算高度比例
        final healthyHeight = healthy / maxValue;
        final witheredHeight = withered / maxValue;
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 健康专注部分
                if (healthy > 0)
                  Flexible(
                    flex: (healthyHeight * 100).round(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                
                // 枯萎专注部分
                if (withered > 0)
                  Flexible(
                    flex: (witheredHeight * 100).round(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.only(
                          topLeft: healthy > 0 ? Radius.zero : const Radius.circular(4),
                          topRight: healthy > 0 ? Radius.zero : const Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                
                // 填充空间部分
                if (healthyHeight + witheredHeight < 1)
                  Flexible(
                    flex: ((1 - healthyHeight - witheredHeight) * 100).round(),
                    child: Container(color: Colors.transparent),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDateLabels(List<DailyFocusSummary> recentData) {
    return Row(
      children: List.generate(recentData.length, (index) {
        final date = recentData[index].date;
        return Expanded(
          child: Text(
            DateFormat('MM-dd').format(date),
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }),
    );
  }
}

class SimpleFocusPieChart extends StatelessWidget {
  final List<dynamic> data;
  final double height;

  const SimpleFocusPieChart({
    Key? key,
    required this.data,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('暂无专注数据'),
        ),
      );
    }

    // 计算总分钟数
    int totalMinutes = 0;
    for (var item in data) {
      totalMinutes += item.totalMinutes as int;
    }

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: _buildPieChartVisualization(totalMinutes),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildPieChartVisualization(int totalMinutes) {
    return Row(
      children: [
        // 简单的饼图可视化
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      '$totalMinutes\n分钟',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  CustomPaint(
                    size: Size.infinite,
                    painter: SimplePieChartPainter(data),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // 图表数据详情
        Expanded(
          flex: 4,
          child: _buildDataDetails(totalMinutes),
        ),
      ],
    );
  }

  Widget _buildDataDetails(int totalMinutes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(data.length, (index) {
        final item = data[index];
        final minutes = item.totalMinutes as int;
        final percentage = totalMinutes > 0 ? minutes / totalMinutes * 100 : 0;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getItemColor(item, index),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.typeName as String,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(data.length, (index) {
        final item = data[index];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getItemColor(item, index),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              item.typeName as String,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }),
    );
  }

  Color _getItemColor(dynamic item, int index) {
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

    final isWithered = item.isWithered as bool? ?? false;
    
    return isWithered
        ? witheredColors[index % witheredColors.length]
        : healthyColors[index % healthyColors.length];
  }
}

class SimplePieChartPainter extends CustomPainter {
  final List<dynamic> data;
  
  SimplePieChartPainter(this.data);
  
  @override
  void paint(Canvas canvas, Size size) {
    // 计算总分钟数
    int totalMinutes = 0;
    for (var item in data) {
      totalMinutes += item.totalMinutes as int;
    }
    
    if (totalMinutes <= 0) return;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width < size.height ? size.width / 2 : size.height / 2;
    
    double startAngle = -90 * (3.1415927 / 180); // 从顶部开始，转换为弧度
    
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final minutes = item.totalMinutes as int;
      
      if (minutes <= 0) continue;
      
      final sweepAngle = (minutes / totalMinutes) * 2 * 3.1415927;
      
      final paint = Paint()
        ..color = _getItemColor(item, i)
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 8), // 小一点，留出边缘
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
  
  Color _getItemColor(dynamic item, int index) {
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

    final isWithered = item.isWithered as bool? ?? false;
    
    return isWithered
        ? witheredColors[index % witheredColors.length]
        : healthyColors[index % healthyColors.length];
  }
} 