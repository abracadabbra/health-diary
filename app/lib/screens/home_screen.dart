import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import 'editor_screen.dart';
import 'calendar_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DiaryEntry> _entries = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    final storage = await StorageService.getInstance();
    final entries = await storage.getRecentEntries(30);
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  void _createNewEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditorScreen(),
      ),
    );
    if (result == true) {
      _loadEntries();
    }
  }

  void _editEntry(DiaryEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditorScreen(entry: entry),
      ),
    );
    if (result == true) {
      _loadEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
        elevation: 0,
      ),
      body: _currentIndex == 0 ? _buildDiaryList() : _buildOtherPages(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppConstants.primaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: '日记',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: '日历',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '统计',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _createNewEntry,
              backgroundColor: AppConstants.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildDiaryList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              '还没有日记',
              style: TextStyle(fontSize: 18, color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            Text(
              '点击 + 开始记录养生生活',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEntries,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final entry = _entries[index];
          return _buildDiaryCard(entry);
        },
      ),
    );
  }

  Widget _buildDiaryCard(DiaryEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _editEntry(entry),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN').format(entry.date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (entry.weather != null)
                    Icon(
                      AppConstants.weatherIcons[entry.weather] ?? Icons.cloud,
                      color: AppConstants.primaryColor,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (entry.sleepQuality != null)
                _buildInfoRow('睡眠质量', '${'⭐' * entry.sleepQuality!}'),
              if (entry.moodIndex != null)
                _buildInfoRow('心情指数', '${'⭐' * entry.moodIndex!}'),
              if (entry.exerciseType != null)
                _buildInfoRow('运动', '${entry.exerciseType} ${entry.exerciseMinutes ?? 0}分钟'),
              if (entry.waterCups != null)
                _buildInfoRow('喝水', '${entry.waterCups} 杯'),
              if (entry.notes != null && entry.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    entry.notes!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              if (entry.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 6,
                    children: entry.tags.take(3).map((tag) {
                      return Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildOtherPages() {
    switch (_currentIndex) {
      case 1:
        return const CalendarScreen();
      case 2:
        return const StatsScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}
