import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/focus_provider.dart';
import '../models/tree_record.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FocusProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildStatsSummary(provider),
            Expanded(
              child: _buildGrassland(context, provider),
            ),
          ],
        );
      },
    );
  }

  // 统计摘要
  Widget _buildStatsSummary(FocusProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.green.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('总计树木', provider.totalTrees.toString(), Icons.nature),
          _buildStatItem('健康树木', provider.healthyTrees.toString(), Icons.eco, color: Colors.green),
          _buildStatItem('枯萎树木', provider.witheredTrees.toString(), Icons.eco, color: Colors.brown),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color color = Colors.black54}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }

  // 草地视图
  Widget _buildGrassland(BuildContext context, FocusProvider provider) {
    final trees = provider.recentTrees;
    
    if (trees.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.nature, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '您的森林还是空的',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '开始您的第一次专注，种下第一棵树吧！',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        // 草地背景
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green.shade100,
            Colors.green.shade300,
          ],
        ),
      ),
      child: Stack(
        children: [
          // 点缀的小花和草
          ...List.generate(20, (index) {
            return Positioned(
              left: 10 + (index * 19) % (MediaQuery.of(context).size.width - 20),
              top: 20 + (index * 23) % (MediaQuery.of(context).size.height / 2),
              child: Icon(
                index % 3 == 0 ? Icons.grass : Icons.local_florist,
                size: 16,
                color: index % 3 == 0 ? Colors.green.shade800 : Colors.yellow.shade600,
              ),
            );
          }),
          
          // 树木布局
          GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 0.8,
              crossAxisSpacing: 0,
              mainAxisSpacing: 8,
            ),
            itemCount: trees.length,
            itemBuilder: (context, index) {
              final tree = trees[index];
              return _buildTreeItem(context, tree);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTreeItem(BuildContext context, TreeRecord tree) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Image.asset(
            tree.imagePath,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.nature,
                size: 40,
                color: tree.isWithered ? Colors.brown : Colors.green,
              );
            },
          ),
        ),
        Text(
          '${tree.duration}分钟',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: tree.isWithered ? Colors.brown : Colors.green.shade800,
          ),
        ),
        Text(
          '${tree.plantedDate.month}/${tree.plantedDate.day}',
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
} 