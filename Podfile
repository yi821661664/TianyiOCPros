# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'TianyiOCPros' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # 如果运行失败，报错CADebugPrintf.h找不到，则需要在子库中setting删除preprocessor的内容
  # Pods for TianyiOCPros
  pod 'TianyiAVManager', :path => '../TianyiAVManager'
  pod 'TianyiUIEngine', :path => '../TianyiUIEngine'
  pod 'Masonry'
  pod 'MJRefresh'
  pod 'MJExtension'
  pod 'SDWebImage'
  pod 'Colours'
  pod 'MBProgressHUD'
  pod 'LookinServer', :configurations => ['Debug']

  target 'TianyiOCProsTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'TianyiOCProsUITests' do
    # Pods for testing
  end

end
