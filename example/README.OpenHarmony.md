# HarmonyOS / OpenHarmony 示例

本目录的 `src/App.tsx` 是一个可运行的跨平台示例：它使用库的
`useScreenshotAware` Hook 显示屏幕捕获事件计数和最近一次事件时间。

## 版本与环境

- RN 与 RNOH 使用同一版本线；当前仓库的鸿蒙适配基于 RN/RNOH `0.84.x`，建议 `0.84.3`。
- 使用 DevEco Studio 6.1.0 或更高版本，并安装 RNOH 所需的 HarmonyOS SDK（Compile SDK API 17）。
- `captureStatusChange` 需要 API 12 及以上；事件可能来自截屏、录屏或投屏，不能仅按“用户截屏”理解。
- 适配只支持 New Architecture/TurboModule。

根目录 Expo 示例依赖 RN `0.87.1`，用于 iOS/Android 开发体验；不要将该 Expo 工程与 RNOH `0.84.x` 工程混用。鸿蒙端应使用单独的 RNOH 壳工程，并复用这里的 `App.tsx`。

## 在 RNOH 工程中接入

1. 在 RNOH 工程的 `oh-package.json5` 中添加库依赖。路径应指向本仓库的 HAR 目录：

   ```json5
   {
     "dependencies": {
       "@rnoh/react-native-openharmony": "0.84.3",
       "@rnoh/react-native-screenshot-aware": "file:../../harmony/screenshot_aware"
     }
   }
   ```

   根据 RNOH 壳工程位置调整 `file:` 相对路径。

2. 在壳工程目录执行 `ohpm install`，再执行 RNOH 工程定义的 `link-harmony` 命令，使 `ScreenshotAwarePackage` 出现在自动生成的包工厂中。
3. 按 RNOH 文档生成 RN bundle，并将 `App.tsx` 作为应用入口。以仓库示例为例，bundle 应放在 `entry/src/main/resources/rawfile/`。
4. 用 DevEco Studio 构建并运行 `entry` 模块。在 API 12+ 真机上截屏、录屏或投屏，页面中的 `capture events detected` 计数应增加。

没有 API 12+ 鸿蒙真机时，可以运行 TypeScript、Lint 和 Jest 检查，但不能据此宣称鸿蒙事件已经验证。

更多环境和版本说明请参阅仓库根目录的 `README.OpenHarmony_CN.md` 以及 [CPF-RN 文档](https://atomgit.com/CPF-RN/docs)。
