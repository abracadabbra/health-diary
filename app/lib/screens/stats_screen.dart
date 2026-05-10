import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/diary_entry.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<DiaryEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final storage = await StorageService.getInstance();
    final entries = await storage.getRecentEntries(30);
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_entries.isEmpty) {
      return const Center(
        child: Text('暂无数据', style: TextStyle(color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 24),
          _buildSleepChart(),
          const SizedBox(height: 24),
          _buildMoodChart(),
          const SizedBox(height: 24),
          _buildExerciseChart(),
          const SizedBox(height: 24),
          _buildWaterChart(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalDays = _entries.length;
    final avgSleep = _entries.where((e) => e.sleepHours != null).map((e) => e.sleepHours!).toList();
    final avgMood = _entries.where((e) => e.moodIndex != null).map((e) => e.moodIndex!).toList();
    final totalExercise = _entries.where((e) => e.exerciseMinutes != null).fold(0, (sum, e) => sum + e.exerciseMinutes!);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          '记录天数',
          '$totalDays 天',
          Icons.calendar_today,
          AppConstants.primaryColor,
        ),
        _buildStatCard(
          '平均睡眠',
          avgSleep.isEmpty ? '-' : '${(avgSleep.reduce((a, b) => a + b) / avgSleep.length).toStringAsFixed(1)} 小时',
          Icons.bedtime,
          Colors.blue,
        ),
        _buildStatCard(
          '平均心情',
          avgMood.isEmpty ? '-' : '${(avgMood.reduce((a, b) => a + b) / avgMood.length).toStringAsFixed(1)} 分',
          Icons.emoji_emotions,
          Colors.amber,
        ),
        _buildStatCard(
          '运动时长',
          '$totalExercise 分钟',
          Icons.fitness_center,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepChart() {
    final sleepData = _entries
        .where((e) => e.sleepHours != null)
        .map((e) => FlSpot(
              e.date.day.toDouble(),
              e.sleepHours!,
            ))
        .toList();

    if (sleepData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('😴 睡眠趋势', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: sleepData,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodChart() {
    final moodData = _entries
        .where((e) => e.moodIndex != null)
        .map((e) => FlSpot(
              e.date.day.toDouble(),
              e.moodIndex!.toDouble(),
            ))
        .toList();

    if (moodData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('😊 心情趋势', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  minY: 0,
                  maxY: 5,
                  lineBarsData: [
                    LineChartBarData(
                      spots: moodData,
                      isCurved: true,
                      color: Colors.amber,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseChart() {
    final exerciseData = _entries
        .where((e) => e.exerciseMinutes != null)
        .map((e) => FlSpot(
              e.date.day.toDouble(),
              e.exerciseMinutes!.toDouble(),
            ))
        .toList();

    if (exerciseData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🏃 运动趋势', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  barGroups: exerciseData.map((spot) {
                    return BarChartGroupData(
                      x: spot.x.toInt(),
                      barRods: [
                        BarChartRodData(
                          toY: spot.y,
                          color: Colors.orange,
                          width: 16,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterChart() {
    final waterData = _entries
        .where((e) => e.waterCups != null)
        .map((e) => FlSpot(
              e.date.day.toDouble(),
              e.waterCups!.toDouble(),
            ))
        .toList();

    if (waterData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💧 喝水趋势', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: waterData,
                      isCurved: true,
                      color: Colors.cyan,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
