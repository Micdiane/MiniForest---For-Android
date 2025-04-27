import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tree_record.dart';
import '../models/focus_stats.dart';

class FocusProvider extends ChangeNotifier {
  bool _isFocusing = false;
  bool _isWithered = false;
  int _selectedDuration = 0; // in minutes
  int _remainingSeconds = 0;
  DateTime? _focusStartTime;
  String _currentTreeImagePath = '';
  List<TreeRecord> _treeRecords = [];
  
  // Getters
  bool get isFocusing => _isFocusing;
  bool get isWithered => _isWithered;
  int get selectedDuration => _selectedDuration;
  int get remainingSeconds => _remainingSeconds;
  DateTime? get focusStartTime => _focusStartTime;
  String get currentTreeImagePath => _currentTreeImagePath;
  List<TreeRecord> get treeRecords => _treeRecords;
  
  // 显示在草地上的最大树木数量
  static const int maxDisplayTrees = 25;
  
  // 获取最近的树木（最多25棵）
  List<TreeRecord> get recentTrees {
    if (_treeRecords.length <= maxDisplayTrees) {
      return List.from(_treeRecords);
    }
    return _treeRecords.sublist(_treeRecords.length - maxDisplayTrees);
  }

  // 统计数据
  int get totalTrees => _treeRecords.length;
  int get healthyTrees => _treeRecords.where((tree) => !tree.isWithered).length;
  int get witheredTrees => _treeRecords.where((tree) => tree.isWithered).length;
  
  // 构造函数 - 加载保存的树木记录
  FocusProvider() {
    _loadTreeRecords();
  }
  
  // 加载保存的树木记录
  Future<void> _loadTreeRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? recordsJson = prefs.getString('tree_records');
      
      if (recordsJson != null) {
        final List<dynamic> decoded = jsonDecode(recordsJson);
        _treeRecords = decoded.map((item) => TreeRecord.fromJson(item)).toList();
        
        // 按日期排序
        _treeRecords.sort((a, b) => a.plantedDate.compareTo(b.plantedDate));
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading tree records: $e');
    }
  }
  
  // 保存树木记录
  Future<void> _saveTreeRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_treeRecords.map((e) => e.toJson()).toList());
      await prefs.setString('tree_records', encoded);
    } catch (e) {
      debugPrint('Error saving tree records: $e');
    }
  }
  
  // 获取指定时间段内的专注统计数据
  FocusStats getStats(TimePeriod period) {
    List<TreeRecord> filteredRecords = [];
    
    // 获取当前日期
    final now = DateTime.now();
    
    // 根据时间段筛选记录
    switch (period) {
      case TimePeriod.day:
        // 今日数据：当天0点到现在
        final startOfDay = DateTime(now.year, now.month, now.day);
        filteredRecords = _treeRecords
            .where((record) => record.plantedDate.isAfter(startOfDay) || 
                              record.plantedDate.isAtSameMomentAs(startOfDay))
            .toList();
        break;
      
      case TimePeriod.week:
        // 本周数据：当周一0点到现在（周一作为一周的开始）
        int weekday = now.weekday;
        final startOfWeek = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: weekday - 1));
        filteredRecords = _treeRecords
            .where((record) => record.plantedDate.isAfter(startOfWeek) || 
                              record.plantedDate.isAtSameMomentAs(startOfWeek))
            .toList();
        break;
      
      case TimePeriod.month:
        // 本月数据：当月1日0点到现在
        final startOfMonth = DateTime(now.year, now.month, 1);
        filteredRecords = _treeRecords
            .where((record) => record.plantedDate.isAfter(startOfMonth) || 
                              record.plantedDate.isAtSameMomentAs(startOfMonth))
            .toList();
        break;
      
      case TimePeriod.year:
        // 本年数据：当年1月1日0点到现在
        final startOfYear = DateTime(now.year, 1, 1);
        filteredRecords = _treeRecords
            .where((record) => record.plantedDate.isAfter(startOfYear) || 
                              record.plantedDate.isAtSameMomentAs(startOfYear))
            .toList();
        break;
    }
    
    return FocusStats(records: filteredRecords, period: period);
  }
  
  // Formatted time
  String get formattedRemainingTime {
    final minutes = (_remainingSeconds / 60).floor();
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  // Progress value from 0.0 to 1.0
  double get progress {
    if (_selectedDuration == 0) return 0.0;
    final totalSeconds = _selectedDuration * 60;
    return (totalSeconds - _remainingSeconds) / totalSeconds;
  }
  
  // 解析图片路径获取树类型名称
  String _getTreeTypeFromPath(String path) {
    // 从路径中提取文件名部分，例如 "tree_30min.png"
    final filename = path.split('/').last;
    // 移除扩展名
    return filename.split('.').first;
  }
  
  // Start a new focus session
  void startFocus(int durationMinutes, String treeImagePath) {
    _selectedDuration = durationMinutes;
    _remainingSeconds = durationMinutes * 60;
    _isFocusing = true;
    _isWithered = false;
    _focusStartTime = DateTime.now();
    _currentTreeImagePath = treeImagePath;
    notifyListeners();
  }
  
  // Update remaining time
  void updateRemainingTime(int seconds) {
    _remainingSeconds = seconds;
    notifyListeners();
  }
  
  // Complete focus session successfully
  void completeFocusSuccess() {
    _isFocusing = false;
    
    // 创建并保存成功的树记录
    final treeType = _getTreeTypeFromPath(_currentTreeImagePath);
    final newTree = TreeRecord.createSuccess(_selectedDuration, treeType);
    _treeRecords.add(newTree);
    _saveTreeRecords();
    
    notifyListeners();
  }
  
  // Complete focus session with failure (withered tree)
  void completeFocusWithered() {
    _isFocusing = false;
    _isWithered = true;
    _currentTreeImagePath = 'assets/images/withered_tree.png';
    
    // 创建并保存枯萎的树记录
    final treeType = _getTreeTypeFromPath(_currentTreeImagePath);
    final newTree = TreeRecord.createWithered(_selectedDuration, treeType);
    _treeRecords.add(newTree);
    _saveTreeRecords();
    
    notifyListeners();
  }
  
  // Reset focus session
  void resetFocus() {
    _isFocusing = false;
    _isWithered = false;
    _selectedDuration = 0;
    _remainingSeconds = 0;
    _focusStartTime = null;
    _currentTreeImagePath = '';
    notifyListeners();
  }
  
  // 清除所有树记录（仅用于测试）
  Future<void> clearAllTrees() async {
    _treeRecords.clear();
    await _saveTreeRecords();
    notifyListeners();
  }
  
  // 添加虚拟数据（仅用于测试统计功能）
  Future<void> addDummyData() async {
    // 为过去30天随机添加专注记录
    final now = DateTime.now();
    final random = ValueNotifier<int>(DateTime.now().microsecond).value; // 使用时间作为随机种子
    
    final durations = [30, 45, 60, 120];
    final treeTypes = ['tree_30min', 'tree_45min', 'tree_60min', 'tree_120min'];
    
    for (int i = 0; i < 50; i++) {
      // 随机日期（过去30天内）
      final daysAgo = random % 30;
      final hoursAgo = random % 24;
      final date = now.subtract(Duration(days: daysAgo, hours: hoursAgo));
      
      // 随机时长和树类型
      final durationIndex = random % 4;
      final duration = durations[durationIndex];
      final treeType = treeTypes[durationIndex];
      
      // 随机成功或失败（70%成功率）
      final isSuccess = random % 10 < 7;
      
      TreeRecord newRecord;
      if (isSuccess) {
        newRecord = TreeRecord(
          id: date.millisecondsSinceEpoch.toString(),
          plantedDate: date,
          duration: duration,
          isWithered: false,
          treeType: treeType,
        );
      } else {
        newRecord = TreeRecord(
          id: date.millisecondsSinceEpoch.toString(),
          plantedDate: date,
          duration: duration,
          isWithered: true,
          treeType: treeType,
        );
      }
      
      _treeRecords.add(newRecord);
    }
    
    // 按日期排序
    _treeRecords.sort((a, b) => a.plantedDate.compareTo(b.plantedDate));
    
    await _saveTreeRecords();
    notifyListeners();
  }
} 