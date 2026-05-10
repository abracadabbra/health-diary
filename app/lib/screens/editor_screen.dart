import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/diary_entry.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class EditorScreen extends StatefulWidget {
  final DiaryEntry? entry;

  const EditorScreen({super.key, this.entry});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late DateTime _date;
  String? _weather;
  int? _temperature;
  
  // 睡眠
  final _sleepTimeController = TextEditingController();
  final _wakeTimeController = TextEditingController();
  final _sleepHoursController = TextEditingController();
  int? _sleepQuality;
  
  // 饮食
  final _breakfastController = TextEditingController();
  final _lunchController = TextEditingController();
  final _dinnerController = TextEditingController();
  final _snacksController = TextEditingController();
  
  // 运动
  final _exerciseTypeController = TextEditingController();
  final _exerciseMinutesController = TextEditingController();
  String? _exerciseIntensity;
  
  // 身体状态
  int? _energyLevel;
  int? _moodIndex;
  final _discomfortController = TextEditingController();
  
  // 养生
  final _waterCupsController = TextEditingController();
  bool _footBath = false;
  final _meditationMinutesController = TextEditingController();
  final _otherHealthController = TextEditingController();
  
  // 其他
  final _notesController = TextEditingController();
  final _tomorrowPlanController = TextEditingController();
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _date = widget.entry?.date ?? DateTime.now();
    _initControllers();
  }

  void _initControllers() {
    if (widget.entry != null) {
      final entry = widget.entry!;
      _weather = entry.weather;
      _temperature = entry.temperature;
      _sleepTimeController.text = entry.sleepTime ?? '';
      _wakeTimeController.text = entry.wakeTime ?? '';
      _sleepHoursController.text = entry.sleepHours?.toString() ?? '';
      _sleepQuality = entry.sleepQuality;
      _breakfastController.text = entry.breakfast ?? '';
      _lunchController.text = entry.lunch ?? '';
      _dinnerController.text = entry.dinner ?? '';
      _snacksController.text = entry.snacks ?? '';
      _exerciseTypeController.text = entry.exerciseType ?? '';
      _exerciseMinutesController.text = entry.exerciseMinutes?.toString() ?? '';
      _exerciseIntensity = entry.exerciseIntensity;
      _energyLevel = entry.energyLevel;
      _moodIndex = entry.moodIndex;
      _discomfortController.text = entry.discomfort ?? '';
      _waterCupsController.text = entry.waterCups?.toString() ?? '';
      _footBath = entry.footBath ?? false;
      _meditationMinutesController.text = entry.meditationMinutes?.toString() ?? '';
      _otherHealthController.text = entry.otherHealth ?? '';
      _notesController.text = entry.notes ?? '';
      _tomorrowPlanController.text = entry.tomorrowPlan ?? '';
      _tags = List.from(entry.tags);
    }
  }

  @override
  void dispose() {
    _sleepTimeController.dispose();
    _wakeTimeController.dispose();
    _sleepHoursController.dispose();
    _breakfastController.dispose();
    _lunchController.dispose();
    _dinnerController.dispose();
    _snacksController.dispose();
    _exerciseTypeController.dispose();
    _exerciseMinutesController.dispose();
    _discomfortController.dispose();
    _waterCupsController.dispose();
    _meditationMinutesController.dispose();
    _otherHealthController.dispose();
    _notesController.dispose();
    _tomorrowPlanController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final entry = DiaryEntry(
      id: widget.entry?.id ?? const Uuid().v4(),
      date: _date,
      weather: _weather,
      temperature: _temperature,
      sleepTime: _sleepTimeController.text.isEmpty ? null : _sleepTimeController.text,
      wakeTime: _wakeTimeController.text.isEmpty ? null : _wakeTimeController.text,
      sleepHours: double.tryParse(_sleepHoursController.text),
      sleepQuality: _sleepQuality,
      breakfast: _breakfastController.text.isEmpty ? null : _breakfastController.text,
      lunch: _lunchController.text.isEmpty ? null : _lunchController.text,
      dinner: _dinnerController.text.isEmpty ? null : _dinnerController.text,
      snacks: _snacksController.text.isEmpty ? null : _snacksController.text,
      exerciseType: _exerciseTypeController.text.isEmpty ? null : _exerciseTypeController.text,
      exerciseMinutes: int.tryParse(_exerciseMinutesController.text),
      exerciseIntensity: _exerciseIntensity,
      energyLevel: _energyLevel,
      moodIndex: _moodIndex,
      discomfort: _discomfortController.text.isEmpty ? null : _discomfortController.text,
      waterCups: int.tryParse(_waterCupsController.text),
      footBath: _footBath,
      meditationMinutes: int.tryParse(_meditationMinutesController.text),
      otherHealth: _otherHealthController.text.isEmpty ? null : _otherHealthController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      tomorrowPlan: _tomorrowPlanController.text.isEmpty ? null : _tomorrowPlanController.text,
      tags: _tags,
    );

    final storage = await StorageService.getInstance();
    await storage.saveDiaryEntry(entry);
    
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _delete() async {
    if (widget.entry == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这篇日记吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final storage = await StorageService.getInstance();
      await storage.deleteEntry(widget.entry!.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? '新建日记' : '编辑日记'),
        actions: [
          if (widget.entry != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _delete,
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildDateSection(),
            const SizedBox(height: 16),
            _buildSleepSection(),
            const SizedBox(height: 16),
            _buildDietSection(),
            const SizedBox(height: 16),
            _buildExerciseSection(),
            const SizedBox(height: 16),
            _buildHealthSection(),
            const SizedBox(height: 16),
            _buildNotesSection(),
            const SizedBox(height: 16),
            _buildTagsSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('基本信息', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN').format(_date)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectDate,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _weather,
              decoration: const InputDecoration(
                labelText: '天气',
                border: OutlineInputBorder(),
              ),
              items: AppConstants.weatherIcons.keys.map((weather) {
                return DropdownMenuItem(value: weather, child: Text(weather));
              }).toList(),
              onChanged: (value) => setState(() => _weather = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('😴 睡眠记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sleepTimeController,
                    decoration: const InputDecoration(
                      labelText: '入睡时间',
                      hintText: '23:00',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _wakeTimeController,
                    decoration: const InputDecoration(
                      labelText: '起床时间',
                      hintText: '07:00',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sleepHoursController,
              decoration: const InputDecoration(
                labelText: '睡眠时长（小时）',
                hintText: '8',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            const Text('睡眠质量'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    color: _sleepQuality != null && _sleepQuality! > index
                        ? Colors.amber
                        : Colors.grey,
                  ),
                  onPressed: () => setState(() => _sleepQuality = index + 1),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🍽️ 饮食记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _breakfastController,
              decoration: const InputDecoration(
                labelText: '早餐',
                hintText: '牛奶、面包、鸡蛋',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lunchController,
              decoration: const InputDecoration(
                labelText: '午餐',
                hintText: '米饭、青菜、鱼',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dinnerController,
              decoration: const InputDecoration(
                labelText: '晚餐',
                hintText: '粥、馒头、蔬菜',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _snacksController,
              decoration: const InputDecoration(
                labelText: '零食/饮品',
                hintText: '水果、茶',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🏃 运动记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _exerciseTypeController,
              decoration: const InputDecoration(
                labelText: '运动类型',
                hintText: '跑步、瑜伽、散步',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _exerciseMinutesController,
                    decoration: const InputDecoration(
                      labelText: '运动时长（分钟）',
                      hintText: '30',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _exerciseIntensity,
                    decoration: const InputDecoration(
                      labelText: '运动强度',
                      border: OutlineInputBorder(),
                    ),
                    items: AppConstants.exerciseIntensities.map((intensity) {
                      return DropdownMenuItem(value: intensity, child: Text(intensity));
                    }).toList(),
                    onChanged: (value) => setState(() => _exerciseIntensity = value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💚 养生记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('精力水平'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.battery_charging_full,
                    color: _energyLevel != null && _energyLevel! > index
                        ? AppConstants.primaryColor
                        : Colors.grey,
                  ),
                  onPressed: () => setState(() => _energyLevel = index + 1),
                );
              }),
            ),
            const SizedBox(height: 12),
            const Text('心情指数'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.emoji_emotions,
                    color: _moodIndex != null && _moodIndex! > index
                        ? Colors.amber
                        : Colors.grey,
                  ),
                  onPressed: () => setState(() => _moodIndex = index + 1),
                );
              }),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _waterCupsController,
                    decoration: const InputDecoration(
                      labelText: '喝水量（杯）',
                      hintText: '8',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _meditationMinutesController,
                    decoration: const InputDecoration(
                      labelText: '冥想（分钟）',
                      hintText: '15',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('泡脚'),
              value: _footBath,
              onChanged: (value) => setState(() => _footBath = value),
              activeColor: AppConstants.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📝 今日感悟', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: '记录今天的养生心得...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            const Text('📅 明日计划'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tomorrowPlanController,
              decoration: const InputDecoration(
                hintText: '明天的养生计划...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🏷️ 标签', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: AppConstants.commonTags.map((tag) {
                final isSelected = _tags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _tags.add(tag);
                      } else {
                        _tags.remove(tag);
                      }
                    });
                  },
                  selectedColor: AppConstants.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppConstants.primaryColor,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
