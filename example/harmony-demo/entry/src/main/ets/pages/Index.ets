/**
 * NestedScrollDemo - Index 页面
 *
 * 外层 ArkUI Scroll 包裹：原生 Banner + 网格 + RNApp。
 *
 * nestedScroll 必须配在【子滚动容器】上（由 RN 侧 TurboModule 注入），
 * 配在此外层 Scroll 上无效——手指落在 FlashList 上时由子组件决定是否把偏移交给父级。
 *
 * 场景一：FlatList → PARENT_FIRST（条目区手势外层先滚）
 * 场景二：ScrollView → PARENT_FIRST（条目区手势外层先滚）
 */

import {
  AnyJSBundleProvider,
  ComponentBuilderContext,
  FileJSBundleProvider,
  MetroJSBundleProvider,
  ResourceJSBundleProvider,
  RNApp,
  RNOHErrorDialog,
  RNOHLogger,
  TraceJSBundleProviderDecorator,
  RNOHCoreContext
} from '@rnoh/react-native-openharmony';
import { createRNPackages } from '../RNPackagesFactory';

@Builder
export function buildCustomRNComponent(ctx: ComponentBuilderContext) {}

const wrappedCustomRNComponentBuilder =
  wrapBuilder(buildCustomRNComponent);

@Entry
@Component
struct Index {
  @StorageLink('RNOHCoreContext')
  private rnohCoreContext: RNOHCoreContext | undefined = undefined;
  @State shouldShow: boolean = false;
  private logger!: RNOHLogger;
  private outerScroller: Scroller = new Scroller();

  aboutToAppear() {
    this.logger = this.rnohCoreContext!.logger.clone("NestedScrollIndex");
    const stopTracing = this.logger
      .clone("aboutToAppear")
      .startTracing();

    this.shouldShow = true;
    stopTracing();
  }

  onBackPress(): boolean | undefined {
    this.rnohCoreContext!.dispatchBackPress();
    return true;
  }

  build() {
    Column() {
      if (this.rnohCoreContext && this.shouldShow) {
        if (this.rnohCoreContext?.isDebugModeEnabled) {
          RNOHErrorDialog({ ctx: this.rnohCoreContext });
        }

        // ═══════════════════════════════════════════════
        // 外层 ArkUI Scroll：原生 header + RN 内容区
        // 嵌套优先级由 RN 侧子滚动容器的 nestedScroll 决定
        // ═══════════════════════════════════════════════
        Scroll(this.outerScroller) {
          Column() {
            // ── 原生 Banner 区 ──
            this.BannerSection()

            // ── 原生网格区 ──
            this.GridSection()

            // ── RN 内容区（内部 FlashList/ScrollView 配置 nestedScroll）──
            Column() {
              RNApp({
                rnInstanceConfig: {
                  createRNPackages,
                  enableNDKTextMeasuring: true,
                  enableBackgroundExecutor: false,
                  enableCAPIArchitecture: true,
                  arkTsComponentNames: []
                },
                initialProps: { "scene": "nested_scroll" } as Record<string, string>,
                appKey: "nested_scroll_demo",
                wrappedCustomRNComponentBuilder:
                  wrappedCustomRNComponentBuilder,
                onSetUp: (rnInstance) => {
                  rnInstance.enableFeatureFlag(
                    "ENABLE_RN_INSTANCE_CLEAN_UP");
                },
                jsBundleProvider: new TraceJSBundleProviderDecorator(
                  new AnyJSBundleProvider([
                    new MetroJSBundleProvider(),
                    new FileJSBundleProvider(
                      '/data/storage/el2/base/files/bundle.harmony.js'),
                    new ResourceJSBundleProvider(
                      this.rnohCoreContext.uiAbilityContext
                        .resourceManager,
                      'hermes_bundle.hbc'),
                    new ResourceJSBundleProvider(
                      this.rnohCoreContext.uiAbilityContext
                        .resourceManager,
                      'bundle.harmony.js')
                  ]),
                  this.rnohCoreContext.logger),
              })
            }
            .height('100%') // 确保 RN 区撑满剩余高度
          }
        }
        .scrollBar(BarState.Off)
      }
    }
    .height('100%')
    .width('100%')
  }

  /**
   * 原生 Banner 轮播区域（先滚动内容）
   */
  @Builder
  BannerSection() {
    Column() {
      Swiper() {
        ForEach(
          ['#FF6B6B', '#4ECDC4', '#45B7D1'],
          (color: string, index: number) => {
            Column() {
              Text(`Banner ${index + 1}`)
                .fontSize(18)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
              Text('热点内容推荐')
                .fontSize(12)
                .fontColor('rgba(255,255,255,0.85)')
                .margin({ top: 4 })
            }
            .width('100%')
            .height(96)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(color)
          }
        )
      }
      .autoPlay(true)
      .loop(true)
      .height(96)
      .indicator(
        Indicator.dot()
          .color('rgba(255,255,255,0.5)')
          .selectedColor(Color.White)
      )
    }
  }

  /** 分类网格：仅一行 4 项 */
  @Builder
  GridSection() {
    Column() {
      Text('热门分类')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .padding({ left: 16, top: 8, bottom: 6 })
        .width('100%')

      Grid() {
        ForEach(
          [
            ['数码', '📱'],
            ['服饰', '👗'],
            ['美食', '🍜'],
            ['家居', '🏠']
          ],
          (item: string[]) => {
            GridItem() {
              Column() {
                Text(item[1])
                  .fontSize(24)
                Text(item[0])
                  .fontSize(11)
                  .fontColor('#666666')
                  .margin({ top: 4 })
              }
              .width('100%')
              .height(64)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
            }
          }
        )
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(8)
      .height(72)
      .padding({ left: 12, right: 12, bottom: 8 })
    }
  }
}