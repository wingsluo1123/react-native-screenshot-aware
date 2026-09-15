/**
 * RNPackagesFactory
 *
 * ScreenshotAware 真机验证壳工程的 ArkTS Package 注册。
 */

import type { RNPackageContext } from '@rnoh/react-native-openharmony';
import { RNPackage, RNOHPackage, UITurboModuleFactory, UITurboModuleContext } from '@rnoh/react-native-openharmony';
import { ScreenshotAwarePackage } from '@rnoh/react-native-screenshot-aware';

class NestedScrollModulesFactory extends UITurboModuleFactory {
  createTurboModule(name: string) {
    // 场景二使用纯 C++ TurboModule，此处无 ArkTS 侧模块
    return null;
  }

  hasTurboModule(name: string): boolean {
    return false;
  }
}

class NestedScrollPackage extends RNOHPackage {
  createUITurboModuleFactory(ctx: UITurboModuleContext) {
    return new NestedScrollModulesFactory(ctx);
  }
}

export function createRNPackages(ctx: RNPackageContext): RNPackage[] {
  return [new NestedScrollPackage(ctx), new ScreenshotAwarePackage(ctx)];
}
