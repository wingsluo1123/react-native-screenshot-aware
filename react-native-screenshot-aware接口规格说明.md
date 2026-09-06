# react-native-screenshot-aware 接口规格说明

## 1. 三方库概述

react-native-screenshot-aware 是一个 React Native 实时截图检测库，可检测用户对设备屏幕的截图行为并触发回调。支持 iOS（`UIApplicationUserDidTakeScreenshotNotification`）、Android 14+（`DETECT_SCREEN_CAPTURE` 权限 + `registerScreenCaptureCallback`）以及 HarmonyOS/OpenHarmony（RNOH 0.84 适配，基于 `display.on('captureStatusChange')`）。

- 版本：2.1.3
- 仅支持 React Native New Architecture（TurboModule）
- 对外事件名：`ScreenshotAwareEvent`
- 原生 TurboModule 名：`ScreenshotAware`

## 2. 对外导出的函数/钩子

### 2.1 useScreenshotAware

| 序号 | 名称 | 类型 | 参数 | 返回值 | 功能描述 |
|------|------|------|------|--------|----------|
| 1 | useScreenshotAware | hook | callback: () => void | void | React 钩子：挂载时订阅截图事件，卸载时自动移除订阅 |

### 2.2 ScreenshotAware 默认导出对象

| 序号 | 名称 | 类型 | 参数 | 返回值 | 功能描述 |
|------|------|------|------|--------|----------|
| 1 | addListener | method | callback: () => void | EmitterSubscription | 添加截图事件监听器，返回可移除的订阅对象 |
| 2 | removeAllListeners | method | 无 | void | 移除全部截图事件监听器 |

## 3. 对外导出的接口/类型（TypeScript）

### 3.1 Spec（src/NativeScreenshotAware.ts 导出的 TurboModule 规格）

| 序号 | 接口/类型名 | 字段 | 类型 | 必填 | 描述 |
|------|------------|------|------|------|------|
| 1 | Spec | addListener | (eventName: string) => void | 是 | 原生侧事件监听注册（RNOH/Android/iOS 为满足 TurboModule 契约的空实现） |
| 2 | Spec | removeListeners | (count: number) => void | 是 | 原生侧批量移除监听（空实现） |

> Spec 继承自 `react-native` 的 `TurboModule`，通过 `TurboModuleRegistry.getEnforcing<Spec>('ScreenshotAware')` 获取。

## 4. 对外导出的变量/常量

| 序号 | 变量名称 | 变量类型 | 功能描述 |
|------|----------|----------|----------|
| 1 | ScreenshotAwareEvent | string（常量，事件名） | 原生侧通过 `emitDeviceEvent('ScreenshotAwareEvent')` 上报的截图事件名 |

## 5. Expo 配置插件

| 序号 | 插件名称 | 功能描述 |
|------|----------|----------|
| 1 | withReactNativeScreenshotAware | Expo config plugin：向 AndroidManifest.xml 添加 `android.permission.DETECT_SCREEN_CAPTURE` 权限（仅 Android 需要；鸿蒙无需权限声明） |

## 6. 各平台原生实现对照

| 平台 | 监听机制 | 事件上报方式 | 最低版本 |
|------|----------|--------------|----------|
| iOS | `UIApplicationUserDidTakeScreenshotNotification` | `RCTEventEmitter` / `supportedEvents` | iOS 14+ |
| Android | `Activity.registerScreenCaptureCallback` | `DeviceEventManagerModule` emit | Android 14（API 34+） |
| HarmonyOS/OpenHarmony | `display.on('captureStatusChange')`（`@ohos.display`） | RNOH `emitDeviceEvent('ScreenshotAwareEvent', null)` | API 12+（RNOH 0.84 要求 Compile SDK API 17） |

## 7. 注意事项

- v2 仅支持 New Architecture（TurboModule），不支持旧架构；
- Android 低于 14 的设备回调永不触发；鸿蒙低版本 API（<12）或模拟器上同样不触发；
- 鸿蒙侧 `captureStatusChange` 在截屏、投屏、录屏时均会触发（回调 true），无法单独区分截屏与录屏；
- JS 侧 `NativeScreenshotAware.ts` 的 `Spec` 与各平台原生 `addListener`/`removeListeners` 签名保持一致（均为空实现，事件传递由各平台事件机制完成）；
- 鸿蒙适配模块位于 `harmony/screenshot_aware/`，通过 `package.json` 的 `harmony.autolinking` 配置接入 RNOH 自动链接。
