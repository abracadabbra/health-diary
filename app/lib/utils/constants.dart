import 'package:flutter/material.dart';

class AppConstants {
  // 应用信息
  static const String appName = '养生日记';
  static const String appVersion = '1.0.0';
  
  // 颜色主题
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color secondaryColor = Color(0xFF8BC34A);
  static const Color accentColor = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  
  // 评分颜色
  static Color getQualityColor(int quality) {
    switch (quality) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.yellow;
      case 4: return Colors.lightGreen;
      case 5: return Colors.green;
      default: return Colors.grey;
    }
  }
  
  // 天气图标
  static const Map<String, IconData> weatherIcons = {
    '晴': Icons.wb_sunny,
    '多云': Icons.cloud,
    '阴': Icons.cloud_queue,
    '雨': Icons.beach_access,
    '雪': Icons.ac_unit,
    '雾': Icons.foggy,
  };
  
  // 运动强度
  static const List<String> exerciseIntensities = ['低', '中', '高'];
  
  // 常用标签
  static const List<String> commonTags = [
    '早起', '运动', '冥想', '阅读', '素食',
    '少油', '少盐', '多喝水', '泡脚', '早睡',
    '无糖', '散步', '跑步', '瑜伽', '太极',
  ];
}
