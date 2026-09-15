#include "RNOH/PackageProvider.h"
#include "NestedScrollPackage.h"
#include "generated/RNOHGeneratedPackage.h"
#include "ReactNativeScreenshotAwarePackage.h"

using namespace rnoh;

std::vector<std::shared_ptr<Package>> PackageProvider::getPackages(
    Package::Context ctx) {
  return {
      std::make_shared<RNOHGeneratedPackage>(ctx),
      std::make_shared<NestedScrollPackage>(ctx),
      std::make_shared<ReactNativeScreenshotAwarePackage>(ctx),
  };
}
