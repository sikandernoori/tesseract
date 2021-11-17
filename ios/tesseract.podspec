Pod::Spec.new do |s|
  s.name             = 'tesseract'
  s.version          = '0.0.6'
  s.summary          = 'Tesseract Implementation Plugin'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://hunaindev.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Skandar Munir' => 'skandar_munir@yahoo.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'SwiftyTesseract'
  s.platform = :ios, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.3'
end
