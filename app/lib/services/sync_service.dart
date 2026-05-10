import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';
import 'storage_service.dart';

class SyncService {
  static const String _tokenKey = 'github_token';
  static const String _gistIdKey = 'gist_id';
  static const String _gistDescription = '养生日记数据备份';

  static final SyncService _instance = SyncService._();
  factory SyncService() => _instance;
  SyncService._();

  String? _token;
  String? _gistId;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _gistId = prefs.getString(_gistIdKey);
  }

  bool get isAuthenticated => _token != null && _token!.isAuthenticated;

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Map<String, String> get _headers => {
    'Authorization': 'token $_token',
    'Accept': 'application/vnd.github.v3+json',
    'Content-Type': 'application/json',
  };

  Future<bool> testConnection() async {
    if (!isAuthenticated) return false;

    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/user'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String?> backupData() async {
    if (!isAuthenticated) return null;

    final storage = await StorageService.getInstance();
    final entries = await storage.getAllEntries();
    final data = entries.map((e) => e.toJson()).toList();
    final jsonStr = jsonEncode(data);

    final body = {
      'description': _gistDescription,
      'public': false,
      'files': {
        'health_diary_backup.json': {
          'content': jsonStr,
        },
      },
    };

    try {
      http.Response response;

      if (_gistId != null) {
        // 更新现有 Gist
        response = await http.patch(
          Uri.parse('https://api.github.com/gists/$_gistId'),
          headers: _headers,
          body: jsonEncode(body),
        );
      } else {
        // 创建新 Gist
        response = await http.post(
          Uri.parse('https://api.github.com/gists'),
          headers: _headers,
          body: jsonEncode(body),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final gistData = jsonDecode(response.body);
        _gistId = gistData['id'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_gistIdKey, _gistId!);
        return _gistId;
      }
    } catch (e) {
      print('备份失败: $e');
    }

    return null;
  }

  Future<bool> restoreData() async {
    if (!isAuthenticated || _gistId == null) return false;

    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/gists/$_gistId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final gistData = jsonDecode(response.body);
        final files = gistData['files'] as Map<String, dynamic>;
        
        if (files.containsKey('health_diary_backup.json')) {
          final content = files['health_diary_backup.json']['content'] as String;
          final List<dynamic> data = jsonDecode(content);
          
          final storage = await StorageService.getInstance();
          await storage.clearAll();
          
          for (final item in data) {
            final entry = DiaryEntry.fromJson(item as Map<String, dynamic>);
            await storage.saveDiaryEntry(entry);
          }
          
          return true;
        }
      }
    } catch (e) {
      print('恢复失败: $e');
    }

    return false;
  }

  Future<DateTime?> getLastBackupTime() async {
    if (!isAuthenticated || _gistId == null) return null;

    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/gists/$_gistId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final gistData = jsonDecode(response.body);
        return DateTime.parse(gistData['updated_at'] as String);
      }
    } catch (e) {
      print('获取备份时间失败: $e');
    }

    return null;
  }

  Future<bool> deleteBackup() async {
    if (!isAuthenticated || _gistId == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('https://api.github.com/gists/$_gistId'),
        headers: _headers,
      );

      if (response.statusCode == 204) {
        _gistId = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_gistIdKey);
        return true;
      }
    } catch (e) {
      print('删除备份失败: $e');
    }

    return false;
  }
}
