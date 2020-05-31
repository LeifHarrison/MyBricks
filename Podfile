# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

# Hide warnings in dependent pods
inhibit_all_warnings!

target 'MyBricks' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MyBricks
  pod 'Alamofire'
  pod 'AlamofireImage'
  pod 'AlamofireNetworkActivityIndicator'
  pod 'AlamofireNetworkActivityLogger'
  pod 'AlamofireRSSParser'
  pod 'Cosmos'
  pod 'KeychainAccess'
  pod 'SwiftLint'

end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
