platform :ios, '8.0'
# use_frameworks!
inhibit_all_warnings!

target :GpsPing do
    
    pod 'ReactiveCocoa', '~> 2.5'
    pod 'CocoaLumberjack', '~> 2.2.0'
    pod 'ErrorKit', '~> 0.3.1'
    pod 'libextobjc', '~> 0.4'
    pod 'ReactiveViewModel', '~> 0.3'
    pod 'Objection', '1.6.1'
    pod 'Masonry', '~> 0.6.1'
    pod 'StaticDataTableViewController', '~> 2.0.3'
    pod 'AFNetworking', '~> 2.5.0'
    pod 'SVProgressHUD'
    pod 'DTTableViewManager', '~>3.2.0'
    pod 'DTCollectionViewManager', '~>3.2.0'
    pod 'UINavigationBar+Addition'
    pod 'MMPReactiveCoreLocation', '~> 0.6'

    pod 'UIImage-ResizeMagick', :git => 'https://github.com/lazarev/UIImage-ResizeMagick'
    pod 'JPSKeyboardLayoutGuide', :git => 'https://github.com/jpsim/JPSKeyboardLayoutGuide.git'
    
    pod 'Mantle', '~> 2.0.6'
    pod 'Underscore.m', '~> 0.2.1'
    pod 'THCalendarDatePicker', '~> 1.2.5'
    pod 'Google/CloudMessaging'
    pod 'mgrs', '~> 0.1.0'
    pod 'DateTools', '~> 1.7.0'
    pod 'TPKeyboardAvoiding', '~> 1.2'
    pod 'FCOverlay', '~>1.0.1'
    pod 'YYWebImage'
    pod 'AWSS3'
    pod 'Fabric'
    pod 'Crashlytics'
end


post_install do |installer|
    installer.aggregate_targets.each do |target|
        copy_pods_resources_path = "Pods/Target Support Files/#{target.name}/#{target.name}-resources.sh"
        string_to_replace = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"'
        assets_compile_with_app_icon_arguments = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${BUILD_DIR}/assetcatalog_generated_info.plist"'
        text = File.read(copy_pods_resources_path)
        new_contents = text.gsub(string_to_replace, assets_compile_with_app_icon_arguments)
        File.open(copy_pods_resources_path, "w") {|file| file.puts new_contents }
    end
end
