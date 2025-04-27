import 'package:flutter/material.dart';

class FocusProvider extends ChangeNotifier {
  bool _isFocusing = false;
  bool _isWithered = false;
  int _selectedDuration = 0; // in minutes
  int _remainingSeconds = 0;
  DateTime? _focusStartTime;
  String _currentTreeImagePath = '';
  
  // Getters
  bool get isFocusing => _isFocusing;
  bool get isWithered => _isWithered;
  int get selectedDuration => _selectedDuration;
  int get remainingSeconds => _remainingSeconds;
  DateTime? get focusStartTime => _focusStartTime;
  String get currentTreeImagePath => _currentTreeImagePath;
  
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
    notifyListeners();
  }
  
  // Complete focus session with failure (withered tree)
  void completeFocusWithered() {
    _isFocusing = false;
    _isWithered = true;
    _currentTreeImagePath = 'assets/images/withered_tree.png';
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
} 