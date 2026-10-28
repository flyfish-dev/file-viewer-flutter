#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint file_viewer_flutter_macos.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'file_viewer_flutter_macos'
  s.version          = '0.1.0'
  s.summary          = 'Retained WKWebView adapter for File Viewer Flutter.'
  s.description      = <<-DESC
Retained WKWebView adapter for File Viewer Flutter.
                       DESC
  s.homepage         = 'https://github.com/flyfish-dev/file-viewer-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flyfish Dev' => 'https://github.com/flyfish-dev' }

  s.source           = { :path => '.' }
  s.source_files     = 'file_viewer_flutter_macos/Sources/file_viewer_flutter_macos/**/*.swift'
  s.dependency 'FlutterMacOS'
  s.resource_bundles = {'file_viewer_flutter_macos_privacy' => ['file_viewer_flutter_macos/Sources/file_viewer_flutter_macos/Resources/PrivacyInfo.xcprivacy']}

  # swift-collections podspec doesn't declare macOS support, so we must use OrderedSet library
  # s.dependency 'swift-collections', '~>1.1.1'
  s.dependency 'OrderedSet', '~>6.0.3'

  s.platform = :osx, '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
  }
  s.swift_version = '5.0'
end
