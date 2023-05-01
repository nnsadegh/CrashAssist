# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'CrashAssist' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CrashAssist
pod 'FirebaseAuth'
pod 'FirebaseFirestore'
pod 'FirebaseFirestoreSwift'
pod 'FirebaseStorage'
pod 'FirebaseUI/Auth'

pod 'FirebaseUI/Email'
pod 'FirebaseUI/Google'
pod 'FirebaseUI/Facebook'

pod 'GoogleSignIn'
pod 'FBSDKLoginKit' 

pod 'SDWebImage'
pod 'GooglePlaces'
pod 'GoogleMaps'
pod 'SwiftyFORM'

  target 'CrashAssistTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'CrashAssistUITests' do
    # Pods for testing
  end
post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
  installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
   end
  end
end

end
