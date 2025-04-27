import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'dart:io';
import '../providers/focus_provider.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({Key? key}) : super(key: key);

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> with WidgetsBindingObserver {
  Timer? _timer;
  final GlobalKey _screenshotKey = GlobalKey();
  bool _canShare = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    final provider = Provider.of<FocusProvider>(context, listen: false);
    
    if (provider.isFocusing && _timer != null && _timer!.isActive) {
      if (state == AppLifecycleState.paused || 
          state == AppLifecycleState.inactive) {
        // User left the app or locked the screen
        _timer?.cancel();
        provider.completeFocusWithered();
        setState(() {
          _canShare = true;
        });
      }
    }
  }

  void _startTimer() {
    final provider = Provider.of<FocusProvider>(context, listen: false);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (provider.remainingSeconds > 0) {
        provider.updateRemainingTime(provider.remainingSeconds - 1);
      } else {
        // Focus completed successfully
        timer.cancel();
        provider.completeFocusSuccess();
        setState(() {
          _canShare = true;
        });
      }
    });
  }

  Future<void> _captureAndShare() async {
    try {
      // 获取RepaintBoundary对象的RenderObject
      RenderRepaintBoundary boundary = _screenshotKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      
      // 将RenderObject转换为图像
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        
        // 获取临时目录用于保存截图
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/focus_tree_screenshot.png');
        await file.writeAsBytes(pngBytes);
        
        // 判断专注结果
        final provider = Provider.of<FocusProvider>(context, listen: false);
        final message = provider.isWithered 
            ? '我的专注树因为分心而枯萎了...'
            : '我成功专注了${provider.selectedDuration}分钟，看看我的专注树！';
        
        // 分享截图
        await Share.shareXFiles(
          [XFile(file.path)],
          text: message,
          subject: '我的专注树',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('分享失败: $e')),
      );
    }
  }

  void _navigateBackToForest() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FocusProvider>(
      builder: (context, provider, child) {
        return WillPopScope(
          onWillPop: () async {
            if (provider.isFocusing) {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('确定要退出专注吗？'),
                  content: const Text('如果现在退出，你的专注树将会枯萎。'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        provider.completeFocusWithered();
                        Navigator.pop(context, true);
                      },
                      child: const Text('退出'),
                    ),
                  ],
                ),
              );
              return result ?? false;
            }
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('专注模式'),
              automaticallyImplyLeading: !provider.isFocusing,
              actions: [
                if (!provider.isFocusing)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
              ],
            ),
            body: RepaintBoundary(
              key: _screenshotKey,
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Expanded(
                        flex: 5,
                        child: Image.asset(
                          provider.currentTreeImagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.nature,
                              size: 150,
                              color: Colors.green,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        provider.isFocusing ? '正在专注...' : 
                          (provider.isWithered ? '专注中断' : '专注完成！'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        provider.formattedRemainingTime,
                        style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 20),
                      LinearProgressIndicator(
                        value: provider.progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          provider.isWithered ? Colors.red : Colors.green,
                        ),
                      ),
                      const Spacer(),
                      if (!provider.isFocusing)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _navigateBackToForest, 
                              icon: const Icon(Icons.forest),
                              label: const Text('查看我的森林'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _canShare ? _captureAndShare : null,
                              icon: const Icon(Icons.share),
                              label: const Text('分享成果'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        const SizedBox(height: 60),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 