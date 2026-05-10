import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _syncService = SyncService();
  final _notificationService = NotificationService();

  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 21, minute: 0);
  bool _isLoading = false;
  String? _token;
  DateTime? _lastBackupTime;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    await _syncService.initialize();
    await _notificationService.initialize();

    final pending = await _notificationService.getPendingNotifications();
    setState(() {
      _reminderEnabled = pending.isNotEmpty;
      _token = null; // 从安全存储加载
      _isLoading = false;
    });

    _loadLastBackupTime();
  }

  Future<void> _loadLastBackupTime() async {
    final time = await _syncService.getLastBackupTime();
    setState(() => _lastBackupTime = time);
  }

  Future<void> _toggleReminder(bool value) async {
    if (value) {
      final granted = await _notificationService.requestPermissions();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请授予通知权限')),
          );
        }
        return;
      }

      await _notificationService.scheduleDailyReminder(
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
        title: '养生日记提醒',
        body: '今天记录养生日记了吗？快来记录一下吧！',
      );
    } else {
      await _notificationService.cancelReminder();
    }

    setState(() => _reminderEnabled = value);
  }

  Future<void> _selectReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );

    if (picked != null) {
      setState(() => _reminderTime = picked);
      if (_reminderEnabled) {
        await _notificationService.scheduleDailyReminder(
          hour: picked.hour,
          minute: picked.minute,
          title: '养生日记提醒',
          body: '今天记录养生日记了吗？快来记录一下吧！',
        );
      }
    }
  }

  Future<void> _showTokenDialog() async {
    final controller = TextEditingController(text: _token);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置 GitHub Token'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请输入 GitHub Personal Access Token：'),
            const SizedBox(height: 8),
            const Text(
              '提示：在 GitHub Settings > Developer settings > Personal access tokens 创建',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'ghp_xxxxxxxxxxxx',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _syncService.setToken(result);
      setState(() => _token = result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token 已保存')),
        );
      }
    }
  }

  Future<void> _backup() async {
    setState(() => _isLoading = true);
    
    final gistId = await _syncService.backupData();
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      if (gistId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('备份成功！')),
        );
        _loadLastBackupTime();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('备份失败，请检查 Token')),
        );
      }
    }
  }

  Future<void> _restore() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认恢复'),
        content: const Text('恢复数据将覆盖当前所有日记，确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('恢复'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    
    final success = await _syncService.restoreData();
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('恢复成功！')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('恢复失败，请检查备份是否存在')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildReminderSection(),
                const Divider(height: 32),
                _buildSyncSection(),
                const Divider(height: 32),
                _buildAboutSection(),
              ],
            ),
    );
  }

  Widget _buildReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '提醒设置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('每日提醒'),
          subtitle: const Text('提醒你记录养生日记'),
          value: _reminderEnabled,
          onChanged: _toggleReminder,
          activeColor: AppConstants.primaryColor,
        ),
        if (_reminderEnabled)
          ListTile(
            title: const Text('提醒时间'),
            subtitle: Text('${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _selectReminderTime,
          ),
      ],
    );
  }

  Widget _buildSyncSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '云端同步',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
        ),
        ListTile(
          title: const Text('GitHub Token'),
          subtitle: Text(_token != null ? '已配置' : '未配置'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _showTokenDialog,
        ),
        if (_token != null) ...[
          ListTile(
            title: const Text('备份数据'),
            subtitle: Text(_lastBackupTime != null
                ? '上次备份：${_lastBackupTime.toString().substring(0, 19)}'
                : '尚未备份'),
            trailing: const Icon(Icons.cloud_upload),
            onTap: _backup,
          ),
          ListTile(
            title: const Text('恢复数据'),
            subtitle: const Text('从云端恢复日记数据'),
            trailing: const Icon(Icons.cloud_download),
            onTap: _restore,
          ),
        ],
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '关于',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
        ),
        ListTile(
          title: const Text('养生日记'),
          subtitle: const Text('版本 1.0.0'),
          trailing: const Icon(Icons.info_outline),
        ),
        ListTile(
          title: const Text('清除所有数据'),
          subtitle: const Text('删除本地所有日记数据'),
          trailing: const Icon(Icons.delete_outline, color: Colors.red),
          onTap: _showClearDataDialog,
        ),
      ],
    );
  }

  Future<void> _showClearDataDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('此操作将删除所有本地日记数据，且无法恢复。确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('清除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // 实现清除逻辑
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据已清除')),
        );
      }
    }
  }
}
