#pragma once

#include "RNOH/Package.h"
#include "NestedScrollTurboModule.h"

namespace rnoh {

/**
 * NestedScroll Package
 *
 * 注册 NestedScrollTurboModule，用于场景二（RN 嵌套原生）：
 * JS 侧通过 TurboModule 调用 CAPI 设置 RN ScrollView 底层的
 * ArkUI nestedScroll 属性。
 */
class NestedScrollPackage : public Package {
 public:
  NestedScrollPackage(Package::Context ctx) : Package(ctx){};

  std::unique_ptr<TurboModuleFactoryDelegate>
  createTurboModuleFactoryDelegate() override {
    class Delegate : public TurboModuleFactoryDelegate {
     public:
      SharedTurboModule createTurboModule(
          Context ctx,
          const std::string& name) const override {
        if (name == "NestedScrollTurboModule") {
          TurboModule::Context tmCtx{
              ctx.jsInvoker,
              ctx.instance,
              ctx.safeInstance,
              ctx.arkTSMessageHub};
          return std::make_shared<NestedScrollTurboModule>(
              tmCtx, ctx.taskExecutor, name);
        }
        return nullptr;
      }
    };
    return std::make_unique<Delegate>();
  }
};

}  // namespace rnoh