#pragma once

#include "RNOH/TurboModule.h"
#include "RNOH/TaskExecutor/TaskExecutor.h"
#include "RNOH/RNInstanceCAPI.h"
#include "RNOHCorePackage/ComponentInstances/ScrollViewComponentInstance.h"

namespace rnoh {

// ── 公共工具 ──────────────────────────────────────────────────────────────

/**
 * 递归查找子组件树中的 ScrollViewComponentInstance。
 * FlatList/FlashList 内部嵌套 ScrollView，findNodeHandle 返回外层容器 tag，
 * 需要遍历子树找到内部的 ScrollViewComponentInstance。
 */
inline std::shared_ptr<ScrollViewComponentInstance> findScrollViewInChildren(
    const ComponentInstance::Shared& instance) {
  auto sv =
      std::dynamic_pointer_cast<ScrollViewComponentInstance>(instance);
  if (sv) return sv;
  for (const auto& child : instance->getChildren()) {
    auto found = findScrollViewInChildren(child);
    if (found) return found;
  }
  return nullptr;
}

// ── NestedScroll TurboModule ─────────────────────────────────────────────

/**
 * 嵌套滚动 TurboModule。
 *
 * 通过 CAPI 查找 RN ScrollView 的底层 ArkUI 节点，
 * 设置 nestedScroll 属性来控制嵌套滚动优先级。
 *
 * 支持四种模式：
 *   SELF_FIRST  - 自身优先滚动
 *   PARENT_FIRST - 父级优先滚动
 *   SELF_ONLY   - 仅自身滚动
 *   PARALLEL    - 与父级同时滚动
 *
 * 使用 runSyncTask(MAIN) 同步阻塞 JS 线程等待主线程执行。
 * 嵌套滚动配置通常在组件挂载时调用一次，阻塞时间极短。
 */
class NestedScrollTurboModule : public TurboModule {
 public:
  NestedScrollTurboModule(
      const TurboModule::Context ctx,
      TaskExecutor::Shared taskExecutor,
      const std::string name);

  // backwardMode 为空时与 mode 相同；常见外层先滚场景用 PARENT_FIRST + SELF_FIRST
  std::string setNestedScrollMode(
      double tag,
      const std::string& mode,
      const std::string& backwardMode = "");

 private:
  TurboModule::Context m_ctx;
  TaskExecutor::Shared m_taskExecutor;
};

}  // namespace rnoh