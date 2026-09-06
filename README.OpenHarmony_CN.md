# react-native-screenshot-aware 鸿蒙（OpenHarmony/HarmonyOS）适配

> 本文档说明 react-native-screenshot-aware 在 OpenHarmony / HarmonyOS 平台上的适配方式、版本配套与接入步骤。英文版见 [README.OpenHarmony.md](./README.OpenHarmony.md)。

## 一、能力说明

本库用于在 React Native 应用中**实时检测屏幕截图事件**。鸿蒙适配版保持了与 iOS / Android 完全一致的对外 API（`useScreenshotAware`、`addListener`、`removeAllListeners`），事件名统一为 `ScreenshotAwareEvent`。

### 平台实现对比

| 平台 | 实现机制 | 说明 |
| ---- | -------- | ---- |
| iOS | `UIApplicationUserDidTakeScreenshotNotification` 系统通知 | 系统级截图事件 |
| Android（14+） | `Activity.registerScreenCaptureCallback` + `DETECT_SCREEN_CAPTURE` 权限 | Android 14 专用 API，仅 API 34+ |
| **OpenHarmony/HarmonyOS** | `display.on('captureStatusChange')`（API 12+） | 屏幕内容被获取（截屏 / 投屏 / 录屏）状态变化监听 |

> ⚠️ **能力差异说明**：鸿蒙侧 `@ohos.screenshot` 为系统接口，仅系统应用可用（需要 `ohos.permission.CAPTURE_SCREEN`），三方应用无法直接使用。因此适配版采用 `@ohos.display` 的 `captureStatusChange` 事件（API 12+，三方应用可用），该事件在**截屏、投屏、录屏**发生时回调 `true`。即：鸿蒙上触发截图事件的**同时也会覆盖投屏/录屏场景**（这与 iOS 通知机制类似，但与 Android 14 的截图专属 API 存在差异），接入时请按此语义设计业务逻辑。

## 二、版本配套

| 组件 | 版本要求 |
| ---- | -------- |
| React Native | 0.84.x（对应 RNOH 0.84 版本线） |
| RNOH（@react-native-oh/react-native-harmony） | 0.84.x（建议使用最新 0.84.3） |
| ohos 侧依赖（@rnoh/react-native-openharmony） | 与前端包版本对齐（0.84.x） |
| HarmonyOS API | API 12+（`captureStatusChange` 最低要求；RNOH 0.84 要求 Compile SDK API 17） |
| DevEco Studio | 6.1.0 及以上 |
| 架构 | 仅支持 New Architecture（TurboModule） |

## 三、目录结构

```
harmony/
└── screenshot_aware/                    # 鸿蒙适配 HAR 模块
    ├── oh-package.json5                 # 依赖 @rnoh/react-native-openharmony
    ├── build-profile.json5
    ├── hvigorfile.ts
    ├── Index.ets                        # 导出 ScreenshotAwarePackage
    └── src/main/
        ├── module.json5
        └── ets/
            ├── ScreenshotAwareTurboModule.ets   # TurboModule 实现（display 监听 + 事件上报）
            └── ScreenshotAwarePackage.ets       # RNOHPackage 注册
```

## 四、接入步骤

### 4.1 安装依赖

```bash
npm install react-native-screenshot-aware
# 鸿蒙工程需额外安装 RNOH（与前端版本配套）
npm install @react-native-oh/react-native-harmony@0.84.3 @react-native-oh/react-native-harmony-cli@0.84.3
```

在鸿蒙工程 `entry` 目录执行（版本与前端包对齐）：

```bash
ohpm i @rnoh/react-native-openharmony@0.84.3
```

### 4.2 自动链接（Autolinking，推荐）

本库已在 `package.json` 中配置 `harmony.autolinking`：

```json
{
  "harmony": {
    "autolinking": {
      "ohPackageName": "@rnoh/react-native-screenshot-aware",
      "etsPackageClassName": "ScreenshotAwarePackage"
    }
  }
}
```

在 RNOH 工程中执行 `link-harmony`（通常由 hvigor 插件在构建时自动执行，也可手动运行）：

```bash
npx @react-native-oh/react-native-harmony-cli link-harmony
```

该命令会自动完成：HAR 安装、`RNOHPackagesFactory.ets` 中注册 `ScreenshotAwarePackage`。

### 4.3 手动接入（不使用 Autolinking 时）

1. 在鸿蒙工程 `oh-package.json5` 中增加依赖：

   ```json5
   {
     "dependencies": {
       "@rnoh/react-native-screenshot-aware": "file:../node_modules/react-native-screenshot-aware/harmony/screenshot_aware"
     }
   }
   ```

2. 在 `entry/src/main/ets/RNPackagesFactory.ets` 中注册包：

   ```typescript
   import { RNPackageContext, RNPackage } from '@rnoh/react-native-openharmony/ts';
   import { ScreenshotAwarePackage } from '@rnoh/react-native-screenshot-aware';

   export function createRNPackages(ctx: RNPackageContext): RNPackage[] {
     return [new ScreenshotAwarePackage(ctx)];
   }
   ```

> 注：Autolinking 场景下 `RNOHPackagesFactory.ets` 由 `link-harmony` 自动生成，无需手改。

## 五、使用示例

API 与 iOS / Android 完全一致：

```tsx
import { useScreenshotAware } from 'react-native-screenshot-aware';

function MyComponent() {
  useScreenshotAware(() => {
    console.log('检测到截屏/录屏事件！');
  });
  return <View />;
}
```

类组件或非 React 场景：

```tsx
import ScreenshotAware from 'react-native-screenshot-aware';

useEffect(() => {
  const subscription = ScreenshotAware.addListener(() => {
    console.log('A screenshot was taken!');
  });
  return () => subscription.remove();
}, []);
```

## 六、注意事项

- 鸿蒙平台不支持 `DETECT_SCREEN_CAPTURE` 权限与 `@ohos.screenshot`（系统接口），无需也不能在 `module.json5` 中申请相关权限；
- `captureStatusChange` 回调 `true` 表示屏幕内容开始被获取（截屏 / 投屏 / 录屏），与 iOS 的系统通知语义接近，但**无法单独区分截屏与录屏**；
- 事件回调通过 RNOH 的 `emitDeviceEvent` 机制上报，TurboModule 生命周期结束（`__onDestroy__`）时会自动注销监听，避免泄漏；
- 建议在真机（API 12+）上验证；模拟器/低版本 API 下不会触发事件。

## 七、文档索引

- [英文适配文档](./README.OpenHarmony.md)
- 版本信息：https://atomgit.com/CPF-RN/ohos_react_native （RNOH 0.84 版本线，npm 包 @react-native-oh/react-native-harmony@0.84.x）
- RNOH 技能集：https://atomgit.com/CPF-RN/skills
