Pod::Spec.new do |s|
  s.name             = 'smart_liveliness_detection'
  s.version          = '0.3.5'
  s.summary          = 'Flutter face liveness detection package with anti-spoofing.'
  s.description      = <<-DESC
    Verify that a real person is present in front of the camera using ML Kit face
    detection, optional ARKit 3-D depth analysis, screen-flash anti-spoofing, and
    face quality scoring.
  DESC
  s.homepage         = 'https://github.com/demola234/smart_liveliness_detection'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Demola' => 'oluwasegun.kolawole@moniepoint.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*.swift'
  s.dependency       'Flutter'
  s.platform         = :ios, '14.0'
  s.swift_version    = '5.0'
  s.frameworks       = 'ARKit'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
end
