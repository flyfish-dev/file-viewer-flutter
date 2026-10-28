cmake_minimum_required(VERSION 3.19)
project(file_viewer_flutter LANGUAGES CXX)

set(PLUGIN_NAME file_viewer_flutter_plugin)
add_library(${PLUGIN_NAME} SHARED file_viewer_flutter_plugin.cpp)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES CXX_VISIBILITY_PRESET hidden)
target_compile_features(${PLUGIN_NAME} PRIVATE cxx_std_17)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)
set(file_viewer_flutter_bundled_libraries "" PARENT_SCOPE)

include("${CMAKE_CURRENT_SOURCE_DIR}/runtime.cmake")
file_viewer_prepare_webview2()

# The locked adapter's C++/WinRT headers select standard coroutines in C++20.
# Configure only that target after Flutter has added every plugin directory.
function(file_viewer_configure_windows_adapter)
  if(NOT TARGET flutter_inappwebview_windows_plugin)
    message(FATAL_ERROR "The locked Windows WebView adapter target is missing")
  endif()
  target_compile_features(flutter_inappwebview_windows_plugin PRIVATE cxx_std_20)
  if(MSVC)
    # This pinned adapter still relies on the MSVC extensions used by its
    # original C++17 build. Keep that lookup mode while using std coroutines.
    target_compile_options(flutter_inappwebview_windows_plugin PRIVATE /permissive)
  endif()
endfunction()
cmake_language(DEFER DIRECTORY "${CMAKE_SOURCE_DIR}" CALL file_viewer_configure_windows_adapter)

