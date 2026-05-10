# 养日记 Flutter App

记录每日健康生活的跨平台应用，支持 iOS、Android 和 Web。

## 功能特性

- 📝 每日日记记录（睡眠、饮食、运动、心情等）
- 📅 日历视图，快速查看和创建日记
- 📊 数据统计图表，追踪健康趋势
- 🏷️ 标签系统，方便分类管理
- 💾 本地存储，数据安全

## 技术栈

- Flutter 3.x
- Dart 3.x
- shared_preferences（本地存储）
- table_calendar（日历组件）
- fl_chart（图表组件）

## 快速开始

### 1. 安装 Flutter

请参考 [Flutter 官方文档](https://docs.flutter.dev/get-started/install) 安装 Flutter SDK。

### 2. 克隆项目

```bash
git clone https://github.com/abracadabbra/health-diary.git
cd health-diary/app
```

### 3. 安装依赖

```bash
flutter pub get
```

### 4. 运行应用

```bash
# iOS 模拟器
flutter run -d iPhone

# Android 模拟器
flutter run -d android

# Web
flutter run -d chrome

# 查看所有可用设备
flutter devices
```

## 项目结构

```
app/
├── lib/
│   ├── main.dart              # 应用入口
│   ├── models/
│   │   └── diary_entry.dart   # 日记数据模型
│   ├── screens/
│   │   ├── home_screen.dart   # 主页面（日记列表）
│   │   ├── editor_screen.dart # 编辑页面
│   │   ├── calendar_screen.dart # 日历页面
│   │   └── stats_screen.dart  # 统计页面
│   ├── services/
│   │   └── storage_service.dart # 本地存储服务
│   └── utils/
│       └── constants.dart     # 常量定义
├── pubspec.yaml               # 项目配置
└── assets/                    # 资源文件
```

## 开发说明

### 添加新功能

1. 在 `models/` 中添加数据模型
2. 在 `services/` 中添加业务逻辑
3. 在 `screens/` 中添加页面
4. 在 `widgets/` 中添加可复用组件

### 构建发布

```bash
# Android APK
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

## 许可证

MIT License
