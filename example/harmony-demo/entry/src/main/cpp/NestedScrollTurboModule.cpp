#include "NestedScrollTurboModule.h"
#include "RNOH/RNInstanceCAPI.h"
#include <set>

using namespace facebook;
using namespace facebook::react;

namespace rnoh {

// ════════════════════════════════════════════════════════════════════════════
// NestedScrollTurboModule 实现
// ════════════════════════════════════════════════════════════════════════════

static ArkUI_ScrollNestedMode parseNestedMode(const std::string& mode) {
  if (mode == "PARENT_FIRST") {
    return ARKUI_SCROLL_NESTED_MODE_PARENT_FIRST;
  }
  if (mode == "SELF_ONLY") {
    return ARKUI_SCROLL_NESTED_MODE_SELF_ONLY;
  }
  if (mode == "PARALLEL") {
    return ARKUI_SCROLL_NESTED_MODE_PARALLEL;
  }
  return ARKUI_SCROLL_NESTED_MODE_SELF_FIRST;
}

static jsi::Value __hostFunction_setNestedScrollMode(
    jsi::Runtime& rt,
    react::TurboModule& turboModule,
    const jsi::Value* args,
    size_t count) {
  auto tag = args[0].asNumber();
  auto mode = args[1].asString(rt).utf8(rt);
  std::string backwardMode;
  if (count >= 3 && !args[2].isUndefined() && !args[2].isNull()) {
    backwardMode = args[2].asString(rt).utf8(rt);
  }
  auto& m = static_cast<NestedScrollTurboModule&>(turboModule);
  return createPromiseAsJSIValue(
      rt,
      [tag, mode, backwardMode, &m](
          jsi::Runtime& rt2, std::shared_ptr<react::Promise> p) {
        try {
          auto result = m.setNestedScrollMode(tag, mode, backwardMode);
          if (result.compare(0, 5, "ERROR") == 0) {
            p->reject(result);
          } else {
            p->resolve(jsi::String::createFromUtf8(rt2, result));
          }
        } catch (const std::exception& e) {
          p->reject(e.what());
        }
      });
}

NestedScrollTurboModule::NestedScrollTurboModule(
    const TurboModule::Context ctx,
    TaskExecutor::Shared taskExecutor,
    const std::string name)
    : TurboModule(ctx, name),
      m_ctx(ctx),
      m_taskExecutor(std::move(taskExecutor)) {
  methodMap_ = {
      {"setNestedScrollMode",
       MethodMetadata{3, __hostFunction_setNestedScrollMode}},
  };
}

std::string NestedScrollTurboModule::setNestedScrollMode(
    double tag,
    const std::string& mode,
    const std::string& backwardMode) {
  if (!m_taskExecutor) return "ERROR: taskExecutor unavailable";

  static const std::set<std::string> kValidModes = {
      "SELF_FIRST", "PARENT_FIRST", "SELF_ONLY", "PARALLEL"};
  if (kValidModes.find(mode) == kValidModes.end()) {
    return "ERROR: invalid mode '" + mode +
           "', valid values: SELF_FIRST | PARENT_FIRST | SELF_ONLY | "
           "PARALLEL";
  }
  const std::string& resolvedBackward =
      backwardMode.empty() ? mode : backwardMode;
  if (kValidModes.find(resolvedBackward) == kValidModes.end()) {
    return "ERROR: invalid backwardMode '" + resolvedBackward +
           "', valid values: SELF_FIRST | PARENT_FIRST | SELF_ONLY | "
           "PARALLEL";
  }

  std::string result;
  // ArkUI 属性操作必须在主线程执行
  m_taskExecutor->runSyncTask(TaskThread::MAIN, [&]() {
    auto rnInstance = m_ctx.safeInstance.lock();
    if (!rnInstance) {
      result = "ERROR: RNInstance expired";
      return;
    }

    auto rnInstanceCAPI =
        std::dynamic_pointer_cast<RNInstanceCAPI>(rnInstance);
    if (!rnInstanceCAPI) {
      result = "ERROR: not CAPI architecture";
      return;
    }

    auto componentInstance =
        rnInstanceCAPI->findComponentInstanceByTag(
            static_cast<Tag>(tag));
    if (!componentInstance) {
      result =
          "ERROR: component not found for tag " +
          std::to_string(static_cast<int>(tag));
      return;
    }

    // 递归查找 ScrollViewComponentInstance
    // FlatList/FlashList 内部嵌套 ScrollView
    auto scrollView = findScrollViewInChildren(componentInstance);
    if (!scrollView) {
      result = "ERROR: ScrollView not found in children of " +
               componentInstance->getComponentName();
      return;
    }

    auto forwardMode = parseNestedMode(mode);
    auto backMode = parseNestedMode(resolvedBackward);

    try {
      scrollView->setNestedScrollMode(forwardMode, backMode);
      result = "OK: nestedScroll forward='" + mode + "' backward='" +
               resolvedBackward + "' for tag " +
               std::to_string(static_cast<int>(tag));
    } catch (const std::exception& e) {
      result = std::string("ERROR: failed to set nestedScroll: ") +
               e.what();
    }
  });
  return result;
}

}  // namespace rnoh