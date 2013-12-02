Pod::Spec.new do |s|
  s.name         = "BCScanner"
  s.version      = "0.0.1"
  s.summary      = "A barcode and qr code scanner that wraps the iOS7 scanning capabilities in a UIViewController"
  s.homepage     = "https://github.com/michaelochs/BCScanner"
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author       = 'Michael Ochs'
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/michaelochs/BCScanner.git", :commit => "ae445da822b3058fe57f8c262ef8596326f31929" }
  s.source_files  = 'BCScanner', 'BCScanner/**/*.{h,m}'
  s.framework  = 'AVFoundation'
  s.requires_arc = true
end
