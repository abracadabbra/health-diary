class DiaryEntry {
  final String id;
  final DateTime date;
  final String? weather;
  final int? temperature;
  
  // 睡眠
  final String? sleepTime;
  final String? wakeTime;
  final double? sleepHours;
  final int? sleepQuality; // 1-5
  
  // 饮食
  final String? breakfast;
  final String? lunch;
  final String? dinner;
  final String? snacks;
  
  // 运动
  final String? exerciseType;
  final int? exerciseMinutes;
  final String? exerciseIntensity; // 低/中/高
  
  // 身体状态
  final int? energyLevel; // 1-5
  final int? moodIndex; // 1-5
  final String? discomfort;
  
  // 养生
  final int? waterCups;
  final bool? footBath;
  final int? meditationMinutes;
  final String? otherHealth;
  
  // 其他
  final String? notes;
  final String? tomorrowPlan;
  final List<String> tags;

  DiaryEntry({
    required this.id,
    required this.date,
    this.weather,
    this.temperature,
    this.sleepTime,
    this.wakeTime,
    this.sleepHours,
    this.sleepQuality,
    this.breakfast,
    this.lunch,
    this.dinner,
    this.snacks,
    this.exerciseType,
    this.exerciseMinutes,
    this.exerciseIntensity,
    this.energyLevel,
    this.moodIndex,
    this.discomfort,
    this.waterCups,
    this.footBath,
    this.meditationMinutes,
    this.otherHealth,
    this.notes,
    this.tomorrowPlan,
    List<String>? tags,
  }) : tags = tags ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'weather': weather,
      'temperature': temperature,
      'sleepTime': sleepTime,
      'wakeTime': wakeTime,
      'sleepHours': sleepHours,
      'sleepQuality': sleepQuality,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'snacks': snacks,
      'exerciseType': exerciseType,
      'exerciseMinutes': exerciseMinutes,
      'exerciseIntensity': exerciseIntensity,
      'energyLevel': energyLevel,
      'moodIndex': moodIndex,
      'discomfort': discomfort,
      'waterCups': waterCups,
      'footBath': footBath,
      'meditationMinutes': meditationMinutes,
      'otherHealth': otherHealth,
      'notes': notes,
      'tomorrowPlan': tomorrowPlan,
      'tags': tags,
    };
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      weather: json['weather'] as String?,
      temperature: json['temperature'] as int?,
      sleepTime: json['sleepTime'] as String?,
      wakeTime: json['wakeTime'] as String?,
      sleepHours: json['sleepHours'] as double?,
      sleepQuality: json['sleepQuality'] as int?,
      breakfast: json['breakfast'] as String?,
      lunch: json['lunch'] as String?,
      dinner: json['dinner'] as String?,
      snacks: json['snacks'] as String?,
      exerciseType: json['exerciseType'] as String?,
      exerciseMinutes: json['exerciseMinutes'] as int?,
      exerciseIntensity: json['exerciseIntensity'] as String?,
      energyLevel: json['energyLevel'] as int?,
      moodIndex: json['moodIndex'] as int?,
      discomfort: json['discomfort'] as String?,
      waterCups: json['waterCups'] as int?,
      footBath: json['footBath'] as bool?,
      meditationMinutes: json['meditationMinutes'] as int?,
      otherHealth: json['otherHealth'] as String?,
      notes: json['notes'] as String?,
      tomorrowPlan: json['tomorrowPlan'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  DiaryEntry copyWith({
    String? id,
    DateTime? date,
    String? weather,
    int? temperature,
    String? sleepTime,
    String? wakeTime,
    double? sleepHours,
    int? sleepQuality,
    String? breakfast,
    String? lunch,
    String? dinner,
    String? snacks,
    String? exerciseType,
    int? exerciseMinutes,
    String? exerciseIntensity,
    int? energyLevel,
    int? moodIndex,
    String? discomfort,
    int? waterCups,
    bool? footBath,
    int? meditationMinutes,
    String? otherHealth,
    String? notes,
    String? tomorrowPlan,
    List<String>? tags,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      weather: weather ?? this.weather,
      temperature: temperature ?? this.temperature,
      sleepTime: sleepTime ?? this.sleepTime,
      wakeTime: wakeTime ?? this.wakeTime,
      sleepHours: sleepHours ?? this.sleepHours,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      snacks: snacks ?? this.snacks,
      exerciseType: exerciseType ?? this.exerciseType,
      exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
      exerciseIntensity: exerciseIntensity ?? this.exerciseIntensity,
      energyLevel: energyLevel ?? this.energyLevel,
      moodIndex: moodIndex ?? this.moodIndex,
      discomfort: discomfort ?? this.discomfort,
      waterCups: waterCups ?? this.waterCups,
      footBath: footBath ?? this.footBath,
      meditationMinutes: meditationMinutes ?? this.meditationMinutes,
      otherHealth: otherHealth ?? this.otherHealth,
      notes: notes ?? this.notes,
      tomorrowPlan: tomorrowPlan ?? this.tomorrowPlan,
      tags: tags ?? this.tags,
    );
  }
}
