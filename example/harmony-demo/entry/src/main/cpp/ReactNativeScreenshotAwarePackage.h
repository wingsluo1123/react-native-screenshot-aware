// Copyright (c) 2026 react-native-screenshot-aware contributors.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

#pragma once

#include "RNOH/Package.h"
#include "RNOH/ArkTSTurboModule.h"
#include "RNOH/TurboModuleFactory.h"

namespace rnoh {

class ScreenshotAwareTurboModuleFactoryDelegate : public TurboModuleFactoryDelegate {
 public:
  SharedTurboModule createTurboModule(Context ctx, const std::string& name) const override {
    if (name == "ScreenshotAware") {
      return std::make_shared<ArkTSTurboModule>(ctx, name);
    }
    return nullptr;
  }
};

// This library is implemented purely in ArkTS. The C++ package class only
// exists to satisfy RNOH autolinking's contract (it expects a package class
// matching the autolinking configuration) and to bridge the ArkTS turbo
// module through an ArkTSTurboModule wrapper.
class ReactNativeScreenshotAwarePackage : public rnoh::Package {
  using Super = rnoh::Package;

 public:
  using Super::Super;

  std::unique_ptr<TurboModuleFactoryDelegate> createTurboModuleFactoryDelegate()
      override {
    return std::make_unique<ScreenshotAwareTurboModuleFactoryDelegate>();
  }
};
} // namespace rnoh
