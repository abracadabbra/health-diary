import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';

class StorageService {
  static const String _diaryKey = 'diary_entries';
  
  static StorageService? _instance;
  late SharedPreferences _prefs;
  
  StorageService._();
  
  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }
  
  // 保存日记
  Future<bool> saveDiaryEntry(DiaryEntry entry) async {
    final entries = await getAllEntries();
    final index = entries.indexWhere((e) => e.id == entry.id);
    
    if (index >= 0) {
      entries[index] = entry;
    } else {
      entries.add(entry);
    }
    
    final jsonList = entries.map((e) => e.toJson()).toList();
    return await _prefs.setString(_diaryKey, jsonEncode(jsonList));
  }
  
  // 获取所有日记
  Future<List<DiaryEntry>> getAllEntries() async {
    final String? jsonString = _prefs.getString(_diaryKey);
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => DiaryEntry.fromJson(json)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
  
  // 根据日期获取日记
  Future<DiaryEntry?> getEntryByDate(DateTime date) async {
    final entries = await getAllEntries();
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    try {
      return entries.firstWhere((entry) {
        final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
        return entryDate == dateOnly;
      });
    } catch (e) {
      return null;
    }
  }
  
  // 根据ID获取日记
  Future<DiaryEntry?> getEntryById(String id) async {
    final entries = await getAllEntries();
    try {
      return entries.firstWhere((entry) => entry.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // 删除日记
  Future<bool> deleteEntry(String id) async {
    final entries = await getAllEntries();
    entries.removeWhere((entry) => entry.id == id);
    
    final jsonList = entries.map((e) => e.toJson()).toList();
    return await _prefs.setString(_diaryKey, jsonEncode(jsonList));
  }
  
  // 获取指定月份的日记
  Future<List<DiaryEntry>> getEntriesByMonth(int year, int month) async {
    final entries = await getAllEntries();
    return entries.where((entry) {
      return entry.date.year == year && entry.date.month == month;
    }).toList();
  }
  
  // 获取最近N天的日记
  Future<List<DiaryEntry>> getRecentEntries(int days) async {
    final entries = await getAllEntries();
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return entries.where((entry) => entry.date.isAfter(cutoff)).toList();
  }
  
  // 清除所有数据
  Future<bool> clearAll() async {
    return await _prefs.remove(_diaryKey);
  }
}
