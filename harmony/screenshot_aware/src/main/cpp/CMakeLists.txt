# Copyright (c) 2026 react-native-screenshot-aware contributors.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

cmake_minimum_required(VERSION 3.4.1)
set(CMAKE_VERBOSE_MAKEFILE on)

file(GLOB screenshot_aware_SRC CONFIGURE_DEPENDS *.cpp)

add_library(rnoh__react_native_screenshot_aware SHARED ${screenshot_aware_SRC})
target_include_directories(rnoh__react_native_screenshot_aware PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(rnoh__react_native_screenshot_aware PUBLIC rnoh)
