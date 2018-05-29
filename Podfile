platform :ios, '9.0'

use_frameworks!

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end

target "Push" do
    pod 'AFNetworking'
    pod 'Masonry'
    pod 'SVPullToRefresh'
    pod 'MBProgressHUD'
    pod 'FBSDKCoreKit'
    pod 'FBSDKLoginKit'
    pod 'FBSDKShareKit'
    pod 'Fabric'
    pod 'Crashlytics'
    #pod 'HockeySDK'
    pod 'youtube-ios-player-helper', '~> 0.1.5'
    pod 'DateTools', :git => 'https://github.com/PushOCCRP/DateTools.git'#, :commit => 'f50ae33def9b8b50a5fbf9e3dadcbf19796f3f35'
    #pod 'DateTools', :path => '~/Repositories/DateTools'
    pod 'HTMLKit', '~> 0.9'
    #pod 'CPAProxy', :git => 'https://github.com/ursachec/CPAProxy.git'
    #pod 'CPAProxy', :path => '../CPAProxy'
    pod 'CPAProxy', :git => 'https://github.com/ursachec/CPAProxy.git', :branch => 'master'
    pod 'YAML-Framework'
    pod '1PasswordExtension', '~> 1.8.5'
end

