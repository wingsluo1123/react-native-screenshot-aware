import { RNOHPackage, AnyThreadTurboModule, AnyThreadTurboModuleContext } from '@rnoh/react-native-openharmony';
import { ScreenshotAwareTurboModule } from './ScreenshotAwareTurboModule';

export class ScreenshotAwarePackage extends RNOHPackage {
  override getAnyThreadTurboModuleFactoryByNameMap(): Map<string, (ctx: AnyThreadTurboModuleContext) => AnyThreadTurboModule | null> {
    return new Map<string, (ctx: AnyThreadTurboModuleContext) => AnyThreadTurboModule | null>([
      [ScreenshotAwareTurboModule.NAME, (ctx) => new ScreenshotAwareTurboModule(ctx)],
    ]);
  }
}
