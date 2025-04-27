import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/focus_provider.dart';
import 'stats_page.dart';
import 'focus_page.dart';
import 'focus_statistics_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 种树选项
  final Map<int, String> durationOptions = {
    30: 'assets/images/tree_30min.png',
    45: 'assets/images/tree_45min.png',
    60: 'assets/images/tree_60min.png',
    120: 'assets/images/tree_120min.png',
  };

  // 控制底部树种选择面板的可见性
  bool _showTreeOptions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 主体是森林统计页面
      body: Stack(
        children: [
          // 基础页面内容
          const StatsPage(),
          
          // 半透明遮罩（仅当树种选择面板显示时）
          if (_showTreeOptions)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          
          // 底部树种选择面板
          if (_showTreeOptions)
            _buildTreeSelectionPanel(),
        ],
      ),
      
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
                image: DecorationImage(
                  image: AssetImage('assets/images/tree_120min.png'),
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  opacity: 0.7,
                ),
              ),
              child: const Text(
                '专注树',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.forest),
              title: const Text('我的森林'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.insights),
              title: const Text('专注统计'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FocusStatisticsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('设置'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonDialog();
              },
            ),
            
            // 测试按钮 - 仅在调试模式下显示
            if (true) // TODO: 改为 if (kDebugMode)
              ListTile(
                leading: const Icon(Icons.data_array, color: Colors.blue),
                title: const Text('添加示例数据', style: TextStyle(color: Colors.blue)),
                onTap: () {
                  Navigator.pop(context);
                  Provider.of<FocusProvider>(context, listen: false).addDummyData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已添加示例数据')),
                  );
                },
              ),
            if (true) // TODO: 改为 if (kDebugMode)
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('清除所有树记录', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showClearConfirmDialog();
                },
              ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('我的森林'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 切换树种选择面板的可见性
          setState(() {
            _showTreeOptions = !_showTreeOptions;
          });
        },
        child: Icon(_showTreeOptions ? Icons.close : Icons.add),
        tooltip: '种植新树',
      ),
    );
  }

  // 树种选择面板
  Widget _buildTreeSelectionPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Material(
        elevation: 16,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      '选择专注时长',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _showTreeOptions = false;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: durationOptions.length,
                itemBuilder: (context, index) {
                  final duration = durationOptions.keys.elementAt(index);
                  final imagePath = durationOptions.values.elementAt(index);
                  return _buildDurationOption(context, duration, imagePath);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 单个时长选项卡片
  Widget _buildDurationOption(BuildContext context, int minutes, String imagePath) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _showTreeOptions = false;
          });
          // 开始专注并导航到专注页面
          Provider.of<FocusProvider>(context, listen: false)
              .startFocus(minutes, imagePath);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FocusPage(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported,
                      size: 30,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$minutes分钟',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('敬请期待'),
          content: const Text('此功能正在开发中，敬请期待！'),
          actions: [
            TextButton(
              child: const Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showClearConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认清除'),
          content: const Text('此操作将清除所有树记录数据，且无法恢复。确定继续吗？'),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () {
                Provider.of<FocusProvider>(context, listen: false).clearAllTrees();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('所有树记录已清除')),
                );
              },
            ),
          ],
        );
      },
    );
  }
} 