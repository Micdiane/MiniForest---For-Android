# 专注树 (Focus Tree)

![专注树应用](assets/images/app_preview.png)

一个帮助用户集中注意力的Android应用程序，通过可视化树的生长来鼓励专注工作。当你专注工作时，树会茁壮成长；如果中途分心，树就会枯萎。

## 📱 功能特点

- ⏱️ 提供多种专注时长选项 (30分钟、45分钟、60分钟、120分钟)
- 🌱 专注过程中通过树的生长来可视化剩余时间
- 🍂 如果用户在专注期间离开应用或锁定屏幕，树会"枯萎"
- 📊 直观的进度条显示专注完成进度
- 📲 专注完成后，用户可以分享自己的专注成果

## 🛠️ 技术栈

- **框架**：Flutter 3.0+
- **编程语言**：Dart
- **状态管理**：Provider
- **本地存储**：path_provider
- **分享功能**：share_plus
- **截图功能**：screenshot
- **应用生命周期管理**：WidgetsBindingObserver
- **异步操作**：dart:async (Timer)

## 📋 系统要求

- Flutter SDK: 2.17.0 或更高
- Dart SDK: 2.17.0 或更高
- Android SDK: 21+ (Android 5.0 或更高)
- iOS: 11.0 或更高 (尚未测试)

## 📲 如何安装

### 开发环境设置

1. 安装 [Flutter SDK](https://flutter.dev/docs/get-started/install)
2. 使用以下命令验证安装：
   ```
   flutter doctor
   ```

### 项目设置

1. 克隆此仓库:
   ```
   git clone https://github.com/YOUR_USERNAME/focus-tree.git
   ```

2. 进入项目目录:
   ```
   cd focus-tree
   ```

3. 安装依赖:
   ```
   flutter pub get
   ```

4. 确保您已经在 `assets/images/` 目录中放置了所需的树图片:
   - tree_30min.png
   - tree_45min.png
   - tree_60min.png
   - tree_120min.png
   - withered_tree.png

5. 运行应用:
   ```
   flutter run
   ```

## 📱 如何使用

1. 打开应用，首页会显示不同的专注时长选项（30、45、60或120分钟）
2. 点击选择您想要专注的时长
3. 开始专注后，保持应用在前台运行，避免切换到其他应用或锁定屏幕
4. 倒计时结束后，若您未中断专注，树将保持健康生长状态
5. 如果您在专注期间离开应用或锁定屏幕，树将会枯萎
6. 专注结束后，点击"分享我的专注树"按钮，可以将您的专注成果分享给朋友

## 🧩 项目结构

```
lib/
  ├── main.dart                # 应用入口点
  ├── screens/                 # 页面
  │   ├── home_page.dart       # 主页面 (选择专注时长)
  │   └── focus_page.dart      # 专注页面 (显示专注树和倒计时)
  ├── providers/               # 状态管理
  │   └── focus_provider.dart  # 专注状态管理
  ├── models/                  # 数据模型
  └── widgets/                 # 公共组件
assets/
  └── images/                  # 树的图片资源
```

## 🚀 未来计划

- [ ] 支持自定义专注时长
- [ ] 添加声音提醒功能
- [ ] 增加专注历史记录统计
- [ ] 支持黑暗模式
- [ ] 添加主题定制选项
- [ ] 多语言支持

## 🔧 故障排除

**问题**: 运行 `flutter run` 后出现错误
**解决方案**: 确保您已正确安装Flutter SDK，并运行 `flutter doctor` 检查环境问题

**问题**: 树的图片无法显示
**解决方案**: 确保图片已放在正确的目录，且在 `pubspec.yaml` 中正确声明

## 🤝 贡献

欢迎提交问题和PR！如果您想为项目做出贡献，请：

1. Fork 本仓库
2. 创建您的功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交您的更改 (`git commit -m '添加一些惊人的功能'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 开启一个Pull Request

## 📄 开源协议

本项目采用 MIT 许可证 - 详情请参阅 [LICENSE](../LICENSE) 文件

## 📞 联系方式

如有问题或建议，请通过 GitHub Issues 联系我们。

---

⭐ 如果您喜欢这个项目，请给它一个星标！ 