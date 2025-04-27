import 'package:flutter/material.dart';

class TreeRecord {
  final String id;
  final DateTime plantedDate;
  final int duration; // 专注时长（分钟）
  final bool isWithered; // 是否枯萎
  final String treeType; // 树的类型，对应图片路径的最后部分

  TreeRecord({
    required this.id,
    required this.plantedDate,
    required this.duration,
    required this.isWithered,
    required this.treeType,
  });

  // 获取树木图片路径
  String get imagePath {
    if (isWithered) {
      return 'assets/images/withered_tree.png';
    }
    return 'assets/images/$treeType.png';
  }

  // 从JSON创建TreeRecord
  factory TreeRecord.fromJson(Map<String, dynamic> json) {
    return TreeRecord(
      id: json['id'] as String,
      plantedDate: DateTime.parse(json['plantedDate'] as String),
      duration: json['duration'] as int,
      isWithered: json['isWithered'] as bool,
      treeType: json['treeType'] as String,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantedDate': plantedDate.toIso8601String(),
      'duration': duration,
      'isWithered': isWithered,
      'treeType': treeType,
    };
  }

  // 创建一个成功的树记录
  static TreeRecord createSuccess(int duration, String treeType) {
    return TreeRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      plantedDate: DateTime.now(),
      duration: duration,
      isWithered: false,
      treeType: treeType,
    );
  }

  // 创建一个枯萎的树记录
  static TreeRecord createWithered(int duration, String treeType) {
    return TreeRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      plantedDate: DateTime.now(),
      duration: duration,
      isWithered: true,
      treeType: treeType,
    );
  }
} 