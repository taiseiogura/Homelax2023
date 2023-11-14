# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'homelax-ultra' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for homelax-ultra
  pod 'PKHUD', '~> 5.0'
  pod 'Firebase'
  pod 'FirebaseCore'
  pod 'FirebaseAnalytics'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'IQKeyboardManagerSwift'
  pod 'DropDown'
  pod 'FirebaseMessaging'

end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
  
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end
end

