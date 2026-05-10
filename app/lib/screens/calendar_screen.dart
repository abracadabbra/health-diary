import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import 'editor_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<DiaryEntry>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final storage = await StorageService.getInstance();
    final entries = await storage.getEntriesByMonth(
      _focusedDay.year,
      _focusedDay.month,
    );

    final Map<DateTime, List<DiaryEntry>> events = {};
    for (final entry in entries) {
      final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
      events[date] = [...(events[date] ?? []), entry];
    }

    setState(() => _events = events);
  }

  List<DiaryEntry> _getEventsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _events[date] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _createEntryForDay(DateTime date) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditorScreen(
          entry: DiaryEntry(id: '', date: date),
        ),
      ),
    );
    if (result == true) {
      _loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          locale: 'zh_CN',
          firstDay: DateTime(2020),
          lastDay: DateTime.now(),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: _onDaySelected,
          onFormatChanged: (format) => setState(() => _calendarFormat = format),
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
            _loadEvents();
          },
          eventLoader: _getEventsForDay,
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppConstants.primaryColor,
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: AppConstants.accentColor,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonDecoration: BoxDecoration(
              color: AppConstants.primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            formatButtonTextStyle: TextStyle(color: Colors.white),
          ),
        ),
        const Divider(),
        Expanded(
          child: _selectedDay == null
              ? const Center(child: Text('选择一天查看日记'))
              : _buildSelectedDayContent(),
        ),
      ],
    );
  }

  Widget _buildSelectedDayContent() {
    final events = _getEventsForDay(_selectedDay!);

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('MM月dd日').format(_selectedDay!),
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text('暂无日记', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _createEntryForDay(_selectedDay!),
              icon: const Icon(Icons.add),
              label: const Text('添加日记'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final entry = events[index];
        return Card(
          child: ListTile(
            title: Text(DateFormat('yyyy年MM月dd日').format(entry.date)),
            subtitle: entry.notes != null
                ? Text(entry.notes!, maxLines: 2, overflow: TextOverflow.ellipsis)
                : null,
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditorScreen(entry: entry),
                ),
              );
              if (result == true) {
                _loadEvents();
              }
            },
          ),
        );
      },
    );
  }
}
