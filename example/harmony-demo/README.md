# OpenHarmony 截屏检测完整示例

这是一个**开箱即用**的 React Native + OpenHarmony 示例工程，演示 `react-native-screenshot-aware` 的截屏检测功能。

## ✨ 特点

- ✅ **完整可运行**：无需手动配置，直接用 DevEco Studio 打开即可运行
- ✅ **已打包 Bundle**：包含预构建的 React Native Bundle
- ✅ **包含 HAR 依赖**：screenshot_aware.har 已就绪
- ✅ **真机验证通过**：在 HUAWEI nova 14 ultra (API 24) 上测试成功

## 📋 环境要求

- **DevEco Studio**: 5.0.1 或更高
- **HarmonyOS SDK**: API 12 (5.0.0.71) 或更高
- **设备/模拟器**: OpenHarmony/HarmonyOS API 12+
- **注意**: `captureStatusChange` API 仅在 API 12+ 真机上可用，模拟器不支持

## 🚀 快速开始

### 1. 打开项目

在 DevEco Studio 中：
```
File → Open → 选择 example/harmony-demo/harmony 目录
```

### 2. 连接设备

- 通过 USB 连接 HarmonyOS 真机
- 确保设备已开启开发者模式和 USB 调试
- 运行 `hdc list targets` 确认设备已连接

### 3. 运行应用

- 点击工具栏的绿色 ▶️ 按钮
- 或按快捷键 `Shift + F10`
- 等待构建完成（首次约 2-3 分钟）

### 4. 测试截屏检测

应用启动后：
1. **在设备上同时按下**：音量下键 + 电源键
2. 观察应用界面：
   - 计数器从 `0` 变成 `1`
   - 显示时间戳：`Last event: HH:MM:SS`
3. 多次截屏测试计数器累加
4. 点击 "Reset count" 按钮归零

## 📁 项目结构

```
harmony-demo/
├── harmony/              # OpenHarmony 工程
│   ├── entry/           # 应用入口模块
│   │   ├── src/main/
│   │   │   ├── ets/
│   │   │   │   └── pages/Index.ets   # 加载 RN Bundle 的页面
│   │   │   └── resources/rawfile/
│   │   │       └── bundle.harmony.js  # React Native Bundle
│   │   └── oh-package.json5           # 依赖配置
│   └── AppScope/        # 应用全局配置
├── hars/                # HAR 依赖
│   └── screenshot_aware.har
├── App.tsx              # React Native 应用入口
├── package.json         # RN 依赖
└── README.md           # 本文档
```

## 🔧 自定义开发

### 修改 React Native 代码

1. 编辑 `App.tsx`
2. 重新生成 Bundle：
   ```bash
   npm install
   npx react-native bundle \
     --platform harmony \
     --dev false \
     --entry-file index.js \
     --bundle-output harmony/entry/src/main/resources/rawfile/bundle.harmony.js \
     --assets-dest harmony/entry/src/main/resources/rawfile
   ```
3. 在 DevEco Studio 中重新运行

### 更新 HAR 依赖

如果 `harmony/screenshot_aware` 模块有更新：
1. 重新构建 HAR（在模块目录）：
   ```bash
   cd ../../harmony/screenshot_aware
   hvigorw --mode module -p module=screenshot_aware@default assembleHar
   ```
2. 复制新的 HAR：
   ```bash
   cp screenshot_aware.har ../../example/harmony-demo/hars/
   ```
3. 在 DevEco Studio 中 Clean Project 后重新运行

## 🐛 故障排除

### 构建失败

- **检查 SDK 版本**：Preferences → SDK → 确保 API 12 已安装
- **清理缓存**：Build → Clean Project
- **重新同步**：File → Invalidate Caches / Restart

### 设备未识别

```bash
# 检查设备连接
hdc list targets

# 如果为空，检查：
# 1. USB 线是否支持数据传输
# 2. 设备开发者模式是否开启
# 3. USB 调试是否授权
```

### 截屏不触发

- **确认 API 版本**：设置 → 关于手机 → 版本号，必须 ≥ API 12
- **检查日志**：DevEco Studio → Console，搜索 `[ScreenshotAware]`
- **重启应用**：完全退出后重新启动

### 白屏或闪退

- **检查 Bundle**：确保 `harmony/entry/src/main/resources/rawfile/bundle.harmony.js` 存在
- **查看日志**：Console 窗口查看错误堆栈
- **重装应用**：卸载后重新安装

## 📱 已验证设备

| 设备型号 | 系统版本 | API Level | 截屏检测 | 录屏检测 | 投屏检测 |
|---------|---------|-----------|---------|---------|---------|
| HUAWEI nova 14 ultra | OpenHarmony 6.1.1.120 | 24 | ✅ | ✅ | ✅ |

## 📖 更多文档

- [库接入文档](../README.OpenHarmony.md) - 如何在现有 RNOH 工程中集成
- [真机验证报告](../../VERIFICATION_COMPLETE.md) - 完整测试过程和结果
- [CPF-RN 文档](https://atomgit.com/CPF-RN/docs) - RNOH 架构和最佳实践

## 🎯 功能说明

此示例演示的是 `captureStatusChange` API，它会在以下场景触发：
- ✅ **截屏**（音量下 + 电源键）
- ✅ **录屏**（下拉通知栏 → 屏幕录制）
- ✅ **投屏**（无线投屏/有线投屏）

**注意**：此 API 设计为隐私保护机制，当检测到屏幕内容被捕获时通知应用。

## 💡 提示

- 首次构建会下载依赖，请耐心等待
- 建议在真机上测试，模拟器不支持 `captureStatusChange` API
- 日志中带 `[ScreenshotAware]` 前缀的是原生模块输出
- 日志中带 `[App]` 前缀的是 JavaScript 层输出

## 📞 问题反馈

如有问题，请在仓库提 Issue 并提供：
- 设备型号和系统版本
- DevEco Studio 版本
- 完整的错误日志
- 复现步骤

---

**祝测试愉快！** 🎉
