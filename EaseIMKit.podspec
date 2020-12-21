#
# Be sure to run `pod lib lint EaseIMKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EaseIMKit'
  s.version          = '0.1.0'
  s.summary          = 'easemob im sdk UIKit'

  s.description      = 'easemob sdk ui kit'

  s.homepage         = 'https://github.com/dujiepeng/EaseIMKit'
  s.license = 'MIT'
  s.author           = { 'dujiepeng' => '347302029@qq.com' }
  s.source           = { :git => 'https://github.com/dujiepeng/EaseIMKit.git', :branch => 'test' }

  s.ios.deployment_target = '11.0'

  s.source_files = 'EaseIMKit/Classes/**/*.{h,m,mm}'
  
  s.public_header_files = 'EaseIMKit/**/PublicHeaders/*.h'
  
  s.xcconfig = {
    'ARCHS' => ['arm64, x86_64'],
#    'VALID_ARCHS' => ['arm64, x86_64'],
#    'EXCLUDED_ARCHS' => ['arm64, x86_64'],
    'OTHER_LDFLAGS' => '-ObjC'
  }


   s.resource_bundles = {
     'EaseIMKit' => ['EaseIMKit/Assets/**/*.{png,jpeg,gif,jpg}']
   }
   
   s.frameworks = 'UIKit'
   s.libraries = 'stdc++'
   
   s.dependency 'Hyphenate'
   

   s.dependency 'SDWebImage'
   s.dependency 'Masonry'
#   s.dependency 'FLAnimatedImage'
#   s.dependency 'MBProgressHUD'

  s.subspec 'VoiceConvert' do |v|
    v.dependency 'EMVoiceConvert'
    v.xcconfig = {
      'EXCLUDED_ARCHS' => ['arm64, x86_64'],
      'OTHER_LDFLAGS' => '-ObjC'
    }
  end
     
end
