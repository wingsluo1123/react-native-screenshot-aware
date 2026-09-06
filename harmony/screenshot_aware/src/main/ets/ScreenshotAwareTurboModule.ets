import { AnyThreadTurboModule, AnyThreadTurboModuleContext } from '@rnoh/react-native-openharmony';
import display from '@ohos.display';

/**
 * ScreenshotAware TurboModule for HarmonyOS / OpenHarmony.
 *
 * HarmonyOS does not expose the `@ohos.screenshot` module (system API only) to
 * third-party applications, so this implementation listens to the
 * `captureStatusChange` event of the display service (available since API 12),
 * which is fired when the screen is being captured (screenshot / projection /
 * screen recording). Once a capture starts, a `ScreenshotAwareEvent` is emitted
 * to the JS side, keeping the same event contract as the Android and iOS
 * implementations.
 */
export class ScreenshotAwareTurboModule extends AnyThreadTurboModule {
  public static readonly NAME = 'ScreenshotAware';
  public static readonly EVENT_NAME = 'ScreenshotAwareEvent';

  private captureStatusCallback: (captureStatus: boolean) => void;

  constructor(ctx: AnyThreadTurboModuleContext) {
    super(ctx);
    this.captureStatusCallback = (captureStatus: boolean): void => {
      if (captureStatus) {
        this.ctx.rnInstance.emitDeviceEvent(ScreenshotAwareTurboModule.EVENT_NAME, null);
      }
    };
    this.registerCaptureStatusChange();
  }

  private registerCaptureStatusChange(): void {
    try {
      display.on('captureStatusChange', this.captureStatusCallback);
    } catch (err) {
      console.error(`[ScreenshotAware] register captureStatusChange failed: ${JSON.stringify(err)}`);
    }
  }

  private unregisterCaptureStatusChange(): void {
    try {
      display.off('captureStatusChange', this.captureStatusCallback);
    } catch (err) {
      console.error(`[ScreenshotAware] unregister captureStatusChange failed: ${JSON.stringify(err)}`);
    }
  }

  // The Spec requires these methods, but event delivery is handled by the
  // RNOH event emitter, so they are implemented as no-ops (same as the
  // Android implementation).
  addListener(eventName: string): void {
  }

  removeListeners(count: number): void {
  }

  __onDestroy__(): void {
    super.__onDestroy__();
    this.unregisterCaptureStatusChange();
  }
}
